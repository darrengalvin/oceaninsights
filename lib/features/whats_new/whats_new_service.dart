import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages "What's New" release notes.
///
/// On each app launch, compares the current app version against the
/// last version the user saw the What's New sheet for.
/// If there are newer releases, returns them for display.
class WhatsNewService {
  static final WhatsNewService _instance = WhatsNewService._internal();
  factory WhatsNewService() => _instance;
  WhatsNewService._internal();

  static const String _keyLastSeenVersion = 'whats_new_last_seen';
  static const String _keyCachedReleases = 'whats_new_cached';

  /// Check if there are unseen releases and return them.
  /// Returns empty list if user has seen the latest.
  Future<List<WhatsNewRelease>> getUnseenReleases() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString(_keyLastSeenVersion) ?? '0.0.0';
    final releases = await _getReleases(prefs);

    // Filter releases newer than lastSeen
    final unseen = releases.where((r) => _isNewer(r.version, lastSeen)).toList();
    unseen.sort((a, b) => _compareVersions(b.version, a.version));
    return unseen;
  }

  /// Mark releases as seen up to current app version.
  Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final info = await PackageInfo.fromPlatform();
      await prefs.setString(_keyLastSeenVersion, info.version);
    } catch (e) {
      // Fallback: just mark the latest release as seen
      final releases = await _getReleases(prefs);
      if (releases.isNotEmpty) {
        await prefs.setString(_keyLastSeenVersion, releases.first.version);
      }
    }
  }

  /// Fetch releases from Supabase and cache locally.
  Future<void> syncReleases() async {
    try {
      final supabase = Supabase.instance.client;
      final releasesData = await supabase
          .from('whats_new_releases')
          .select('*')
          .eq('is_active', true)
          .order('release_date', ascending: false);

      final List<Map<String, dynamic>> fullReleases = [];
      for (final r in releasesData) {
        final itemsData = await supabase
            .from('whats_new_items')
            .select('*')
            .eq('release_id', r['id'])
            .eq('is_active', true)
            .order('sort_order');

        fullReleases.add({
          ...r,
          'items': itemsData,
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCachedReleases, jsonEncode(fullReleases));
      debugPrint('Synced ${fullReleases.length} What\'s New releases');
    } catch (e) {
      debugPrint('Error syncing What\'s New: $e');
    }
  }

  /// Get releases from cache (or empty).
  Future<List<WhatsNewRelease>> _getReleases(SharedPreferences prefs) async {
    final data = prefs.getString(_keyCachedReleases);
    if (data == null) return _getDefaultReleases();

    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((r) => WhatsNewRelease.fromJson(r as Map<String, dynamic>)).toList();
    } catch (e) {
      return _getDefaultReleases();
    }
  }

  /// Hardcoded fallback for first install (before any sync).
  List<WhatsNewRelease> _getDefaultReleases() {
    return [
      WhatsNewRelease(
        version: '1.0.0',
        title: 'Welcome to Below the Surface',
        subtitle: 'Your journey starts here.',
        items: [
          WhatsNewItem(emoji: '🧘', title: 'Breathing Exercises', description: 'Guided breathing techniques to help you stay calm and focused.'),
          WhatsNewItem(emoji: '🎯', title: 'Mission Planner', description: 'Set daily objectives and track your progress.'),
          WhatsNewItem(emoji: '🛡️', title: 'Service Women Support', description: 'Harassment support wizard and health tracker — private and on-device.'),
          WhatsNewItem(emoji: '👨‍👩‍👧‍👦', title: 'Service Family', description: 'Deployment support, coping tools, and guidance for families.'),
          WhatsNewItem(emoji: '📚', title: 'Young Person Education', description: 'Body education, sex education, and bullying support — all tap-based.'),
          WhatsNewItem(emoji: '🎮', title: 'Mindful Games', description: 'Zen garden, block stacking, memory match, and more.'),
        ],
      ),
    ];
  }

  /// Compare two semver strings. Returns true if a > b.
  bool _isNewer(String a, String b) {
    return _compareVersions(a, b) > 0;
  }

  int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final partsB = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }
}

/// A version release with its highlight items.
class WhatsNewRelease {
  final String version;
  final String title;
  final String? subtitle;
  final List<WhatsNewItem> items;

  WhatsNewRelease({
    required this.version,
    required this.title,
    this.subtitle,
    required this.items,
  });

  factory WhatsNewRelease.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    return WhatsNewRelease(
      version: json['version'] ?? '0.0.0',
      title: json['title'] ?? "What's New",
      subtitle: json['subtitle'],
      items: itemsList.map((i) => WhatsNewItem.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

class WhatsNewItem {
  final String emoji;
  final String title;
  final String description;

  WhatsNewItem({required this.emoji, required this.title, required this.description});

  factory WhatsNewItem.fromJson(Map<String, dynamic> json) {
    return WhatsNewItem(
      emoji: json['emoji'] ?? '✨',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
