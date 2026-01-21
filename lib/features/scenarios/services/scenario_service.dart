import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/scenario.dart';
import '../models/protocol.dart';
import '../models/user_response_profile.dart';

/// Service for managing scenarios, protocols, and user progress
/// Syncs from Supabase when online, works offline from Hive
class ScenarioService extends ChangeNotifier {
  static final ScenarioService instance = ScenarioService._internal();
  ScenarioService._internal();
  
  factory ScenarioService() => instance;
  static const String _scenariosBox = 'scenarios';
  static const String _protocolsBox = 'protocols';
  static const String _contentPacksBox = 'content_packs';
  static const String _userProfileBox = 'user_response_profile';
  static const String _syncMetaKey = 'scenario_sync_version';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Initialize scenario service and open Hive boxes
  Future<void> initialize() async {
    await Hive.openBox(_scenariosBox);
    await Hive.openBox(_protocolsBox);
    await Hive.openBox(_contentPacksBox);
    await Hive.openBox(_userProfileBox);
    debugPrint('✅ Scenario service initialized');
    
    // Auto-sync on startup if online
    try {
      final synced = await syncScenarios();
      if (synced) {
        debugPrint('✅ Auto-sync completed on startup');
        notifyListeners();
      } else {
        debugPrint('ℹ️ Auto-sync skipped (offline or up to date)');
      }
    } catch (e) {
      debugPrint('ℹ️ Auto-sync failed (likely offline): $e');
    }
  }

  /// Get user's response profile (create if doesn't exist)
  UserResponseProfile getUserProfile() {
    final box = Hive.box(_userProfileBox);
    UserResponseProfile? profile = box.get('profile');
    
    if (profile == null) {
      profile = UserResponseProfile();
      box.put('profile', profile);
      debugPrint('✅ Created new user response profile');
    }
    
    return profile;
  }

  /// Record a scenario choice
  void recordChoice({
    required String scenarioId,
    required String optionId,
    required String context,
    required List<String> tags,
    required String riskLevel,
  }) {
    final profile = getUserProfile();
    profile.recordChoice(
      scenarioId: scenarioId,
      context: context,
      tags: tags,
      riskLevel: riskLevel,
    );
    debugPrint('✅ Recorded choice: $optionId for scenario $scenarioId');
  }

  /// Sync scenarios from Supabase (when online)
  Future<bool> syncScenarios({bool force = false}) async {
    try {
      debugPrint('🔄 Syncing scenarios from Supabase...');

      // Check if we need to sync
      final localVersion = _getLocalSyncVersion();
      final remoteVersion = await _getRemoteSyncVersion();

      debugPrint('📊 Sync versions: local=$localVersion, remote=$remoteVersion');

      if (!force && localVersion >= remoteVersion) {
        debugPrint('✅ Scenarios already up to date (v$localVersion)');
        return true;
      }
      
      if (force) {
        debugPrint('🔄 Force sync requested, bypassing version check');
      }

      // Fetch content packs
      final packsResponse = await _supabase
          .from('content_packs')
          .select()
          .eq('published', true)
          .order('sort_order');

      final packs = (packsResponse as List)
          .map((json) => ContentPack.fromJson(json))
          .toList();

      // Fetch scenarios with options and perspective shifts
      final scenariosResponse = await _supabase
          .from('scenarios')
          .select('''
            *,
            options:scenario_options(
              *,
              perspective_shifts(*)
            )
          ''')
          .eq('published', true);

      final scenarios = (scenariosResponse as List).map((json) {
        // Flatten the options structure
        final optionsData = json['options'] as List<dynamic>?;
        final options = optionsData?.map((optionJson) {
          final shiftsData = optionJson['perspective_shifts'] as List<dynamic>?;
          optionJson['perspective_shifts'] = shiftsData ?? [];
          return ScenarioOption.fromJson(optionJson);
        }).toList() ?? [];

        json['options'] = options.map((o) => o.toJson()).toList();
        return Scenario.fromJson(json);
      }).toList();

      // Fetch protocols
      final protocolsResponse = await _supabase
          .from('protocols')
          .select()
          .eq('published', true);

      final protocols = (protocolsResponse as List)
          .map((json) => Protocol.fromJson(json))
          .toList();

      // Save to local storage
      await _saveContentPacksLocally(packs);
      await _saveScenariosLocally(scenarios);
      await _saveProtocolsLocally(protocols);

      // Update sync version
      _setLocalSyncVersion(remoteVersion);

      debugPrint('✅ Synced ${scenarios.length} scenarios, ${protocols.length} protocols');
      return true;
    } catch (e) {
      debugPrint('❌ Error syncing scenarios: $e');
      return false;
    }
  }

  /// Get all content packs (from local storage)
  List<ContentPack> getContentPacks() {
    final box = Hive.box(_contentPacksBox);
    return box.values
        .map((data) {
          // Handle both old format (Map) and new format (JSON string)
          final json = data is String
              ? jsonDecode(data) as Map<String, dynamic>
              : data as Map<String, dynamic>;
          return ContentPack.fromJson(json);
        })
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get scenarios by content pack
  List<Scenario> getScenariosByPack(String packId) {
    final box = Hive.box(_scenariosBox);
    return box.values
        .map((data) {
          final json = data is String
              ? jsonDecode(data) as Map<String, dynamic>
              : data as Map<String, dynamic>;
          return Scenario.fromJson(json);
        })
        .where((s) => s.contentPackId == packId)
        .toList()
      ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
  }

  /// Get all scenarios
  List<Scenario> getAllScenarios() {
    final box = Hive.box(_scenariosBox);
    return box.values
        .where((data) => data is String || data is Map) // Skip non-data entries like sync version
        .map((data) {
          try {
            final json = data is String
                ? jsonDecode(data) as Map<String, dynamic>
                : data as Map<String, dynamic>;
            return Scenario.fromJson(json);
          } catch (e) {
            debugPrint('Error parsing scenario: $e');
            return null;
          }
        })
        .where((s) => s != null)
        .cast<Scenario>()
        .toList();
  }

  /// Get scenario by ID
  Scenario? getScenario(String id) {
    final box = Hive.box(_scenariosBox);
    final data = box.get(id);
    if (data == null) return null;
    final json = data is String
        ? jsonDecode(data) as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return Scenario.fromJson(json);
  }

  /// Get random scenario (for daily drill)
  Scenario? getRandomScenario({String? context, int? difficulty}) {
    final scenarios = getAllScenarios();
    if (scenarios.isEmpty) return null;

    var filtered = scenarios;
    if (context != null) {
      filtered = filtered.where((s) => s.context.name == context).toList();
    }
    if (difficulty != null) {
      filtered = filtered.where((s) => s.difficulty == difficulty).toList();
    }

    if (filtered.isEmpty) return null;
    filtered.shuffle();
    return filtered.first;
  }

  /// Get all protocols
  List<Protocol> getAllProtocols() {
    final box = Hive.box(_protocolsBox);
    return box.values
        .map((data) {
          final json = data is String
              ? jsonDecode(data) as Map<String, dynamic>
              : data as Map<String, dynamic>;
          return Protocol.fromJson(json);
        })
        .toList();
  }

  /// Get protocols by category
  List<Protocol> getProtocolsByCategory(ProtocolCategory category) {
    final box = Hive.box(_protocolsBox);
    return box.values
        .map((data) {
          final json = data is String
              ? jsonDecode(data) as Map<String, dynamic>
              : data as Map<String, dynamic>;
          return Protocol.fromJson(json);
        })
        .where((p) => p.category == category)
        .toList();
  }

  /// Get protocol by ID
  Protocol? getProtocol(String id) {
    final box = Hive.box(_protocolsBox);
    final data = box.get(id);
    if (data == null) return null;
    final json = data is String
        ? jsonDecode(data) as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return Protocol.fromJson(json);
  }

  /// Get random protocol (for daily drill)
  Protocol? getRandomProtocol({ProtocolCategory? category}) {
    final protocols = getAllProtocols();
    if (protocols.isEmpty) return null;

    var filtered = protocols;
    if (category != null) {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    if (filtered.isEmpty) return null;
    filtered.shuffle();
    return filtered.first;
  }

  /// Check if content needs syncing
  bool needsSync() {
    try {
      final box = Hive.box(_scenariosBox);
      return box.isEmpty;
    } catch (e) {
      return true;
    }
  }

  // Private helper methods

  Future<void> _saveContentPacksLocally(List<ContentPack> packs) async {
    final box = Hive.box(_contentPacksBox);
    await box.clear();
    for (final pack in packs) {
      await box.put(pack.id, jsonEncode(pack.toJson()));
    }
  }

  Future<void> _saveScenariosLocally(List<Scenario> scenarios) async {
    final box = Hive.box(_scenariosBox);
    await box.clear();
    for (final scenario in scenarios) {
      await box.put(scenario.id, jsonEncode(scenario.toJson()));
    }
  }

  Future<void> _saveProtocolsLocally(List<Protocol> protocols) async {
    final box = Hive.box(_protocolsBox);
    await box.clear();
    for (final protocol in protocols) {
      await box.put(protocol.id, jsonEncode(protocol.toJson()));
    }
  }

  int _getLocalSyncVersion() {
    final box = Hive.box(_scenariosBox);
    return box.get(_syncMetaKey, defaultValue: 0) as int;
  }

  void _setLocalSyncVersion(int version) {
    final box = Hive.box(_scenariosBox);
    box.put(_syncMetaKey, version);
  }

  Future<int> _getRemoteSyncVersion() async {
    try {
      final response = await _supabase
          .from('scenario_sync_metadata')
          .select('version')
          .single();
      return response['version'] as int;
    } catch (e) {
      debugPrint('Error getting remote sync version: $e');
      return 0;
    }
  }
}

