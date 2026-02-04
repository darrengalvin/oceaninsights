import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Content item from the database
class ContentItem {
  final String id;
  final String slug;
  final String label;
  final String? microcopy;
  final String pillar;
  final String audience;
  final String sensitivity;
  final int disclosureLevel;
  final List<String> keywords;
  final String domainSlug;
  final String domainName;
  final String domainIcon;
  
  // Deep content
  final String? understandTitle;
  final String? understandBody;
  final List<String> understandInsights;
  final List<String> reflectPrompts;
  final String? growTitle;
  final List<Map<String, dynamic>> growSteps;
  final String? supportIntro;
  final List<Map<String, dynamic>> supportResources;
  final String? affirmation;

  ContentItem({
    required this.id,
    required this.slug,
    required this.label,
    this.microcopy,
    required this.pillar,
    required this.audience,
    required this.sensitivity,
    required this.disclosureLevel,
    required this.keywords,
    required this.domainSlug,
    required this.domainName,
    required this.domainIcon,
    this.understandTitle,
    this.understandBody,
    this.understandInsights = const [],
    this.reflectPrompts = const [],
    this.growTitle,
    this.growSteps = const [],
    this.supportIntro,
    this.supportResources = const [],
    this.affirmation,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      label: json['label'] ?? '',
      microcopy: json['microcopy'],
      pillar: json['pillar'] ?? 'understand',
      audience: json['audience'] ?? 'any',
      sensitivity: json['sensitivity'] ?? 'normal',
      disclosureLevel: json['disclosure_level'] ?? 1,
      keywords: List<String>.from(json['keywords'] ?? []),
      domainSlug: json['domain_slug'] ?? '',
      domainName: json['domain_name'] ?? '',
      domainIcon: json['domain_icon'] ?? 'circle',
      understandTitle: json['understand_title'],
      understandBody: json['understand_body'],
      understandInsights: List<String>.from(json['understand_insights'] ?? []),
      reflectPrompts: List<String>.from(json['reflect_prompts'] ?? []),
      growTitle: json['grow_title'],
      growSteps: List<Map<String, dynamic>>.from(
        (json['grow_steps'] ?? []).map((s) => Map<String, dynamic>.from(s)),
      ),
      supportIntro: json['support_intro'],
      supportResources: List<Map<String, dynamic>>.from(
        (json['support_resources'] ?? []).map((s) => Map<String, dynamic>.from(s)),
      ),
      affirmation: json['affirmation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'label': label,
      'microcopy': microcopy,
      'pillar': pillar,
      'audience': audience,
      'sensitivity': sensitivity,
      'disclosure_level': disclosureLevel,
      'keywords': keywords,
      'domain_slug': domainSlug,
      'domain_name': domainName,
      'domain_icon': domainIcon,
      'understand_title': understandTitle,
      'understand_body': understandBody,
      'understand_insights': understandInsights,
      'reflect_prompts': reflectPrompts,
      'grow_title': growTitle,
      'grow_steps': growSteps,
      'support_intro': supportIntro,
      'support_resources': supportResources,
      'affirmation': affirmation,
    };
  }
}

/// Domain (life area)
class ContentDomain {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String icon;
  final int displayOrder;

  ContentDomain({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.icon,
    required this.displayOrder,
  });

  factory ContentDomain.fromJson(Map<String, dynamic> json) {
    return ContentDomain(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'] ?? 'circle',
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'icon': icon,
      'display_order': displayOrder,
    };
  }
}

/// Content Service - handles syncing with Supabase and local caching
class ContentService {
  static ContentService? _instance;
  static ContentService get instance => _instance ??= ContentService._();
  
  ContentService._();

  late Box _contentBox;
  bool _isInitialised = false;
  
  static const String _domainsKey = 'domains';
  static const String _contentKey = 'content';
  static const String _lastSyncKey = 'last_sync';
  static const String _contentVersionKey = 'content_version';

  /// Initialise the service
  Future<void> init() async {
    if (_isInitialised) return;
    
    _contentBox = await Hive.openBox('navigate_content');
    
    // Initialise Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    
    _isInitialised = true;
    
    // Try to sync in background (don't block)
    _syncInBackground();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Sync content in background
  Future<void> _syncInBackground() async {
    try {
      await syncContent();
    } catch (e) {
      debugPrint('Background sync failed: $e');
      // Silent fail - we have local cache
    }
  }

  /// Check if we need to sync
  Future<bool> needsSync() async {
    try {
      final response = await _supabase
          .from('sync_metadata')
          .select('content_version')
          .single();
      
      final serverVersion = response['content_version'] as int;
      final localVersion = _contentBox.get(_contentVersionKey, defaultValue: 0) as int;
      
      return serverVersion > localVersion;
    } catch (e) {
      return false; // Can't check, assume we're fine
    }
  }

  /// Sync content from Supabase
  Future<bool> syncContent() async {
    try {
      // Check if we need to sync
      if (!await needsSync()) {
        debugPrint('Content is up to date');
        return true;
      }

      debugPrint('Syncing content from Supabase...');

      // Fetch domains
      final domainsResponse = await _supabase
          .from('domains')
          .select()
          .eq('is_active', true)
          .order('display_order');
      
      final domains = (domainsResponse as List)
          .map((d) => ContentDomain.fromJson(d))
          .toList();

      // Fetch full content (using the view)
      final contentResponse = await _supabase
          .from('content_full')
          .select()
          .eq('is_published', true);
      
      final content = (contentResponse as List)
          .map((c) => ContentItem.fromJson(c))
          .toList();

      // Get server version
      final syncResponse = await _supabase
          .from('sync_metadata')
          .select('content_version')
          .single();
      final serverVersion = syncResponse['content_version'] as int;

      // Cache locally
      await _contentBox.put(_domainsKey, domains.map((d) => d.toJson()).toList());
      await _contentBox.put(_contentKey, content.map((c) => c.toJson()).toList());
      await _contentBox.put(_lastSyncKey, DateTime.now().toIso8601String());
      await _contentBox.put(_contentVersionKey, serverVersion);

      debugPrint('Synced ${domains.length} domains and ${content.length} content items');
      return true;
    } catch (e) {
      debugPrint('Sync failed: $e');
      return false;
    }
  }

  /// Get all domains
  List<ContentDomain> getDomains() {
    final cached = _contentBox.get(_domainsKey) as List?;
    if (cached == null) return [];
    
    return cached
        .map((d) => ContentDomain.fromJson(Map<String, dynamic>.from(d)))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Get all content items
  List<ContentItem> getAllContent() {
    final cached = _contentBox.get(_contentKey) as List?;
    if (cached == null) return [];
    
    return cached
        .map((c) => ContentItem.fromJson(Map<String, dynamic>.from(c)))
        .toList();
  }

  /// Get content items for a domain
  List<ContentItem> getContentForDomain(String domainSlug) {
    return getAllContent()
        .where((c) => c.domainSlug == domainSlug)
        .toList();
  }

  /// Get content items by pillar
  List<ContentItem> getContentByPillar(String domainSlug, String pillar) {
    return getContentForDomain(domainSlug)
        .where((c) => c.pillar == pillar)
        .toList();
  }

  /// Get content filtered by audience
  List<ContentItem> getContentForAudience(String domainSlug, String? audience) {
    return getContentForDomain(domainSlug).where((c) {
      if (c.audience == 'any') return true;
      if (audience == null) return c.audience == 'any';
      return c.audience == audience;
    }).toList();
  }

  /// Get a single content item by slug
  ContentItem? getContentBySlug(String slug) {
    try {
      return getAllContent().firstWhere((c) => c.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Get a single content item by ID
  ContentItem? getContentById(String id) {
    try {
      return getAllContent().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search content by keyword
  List<ContentItem> searchContent(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllContent().where((c) {
      return c.label.toLowerCase().contains(lowerQuery) ||
          c.keywords.any((k) => k.contains(lowerQuery)) ||
          (c.microcopy?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final stored = _contentBox.get(_lastSyncKey) as String?;
    if (stored == null) return null;
    return DateTime.tryParse(stored);
  }

  /// Check if we have any cached content
  bool hasContent() {
    final cached = _contentBox.get(_contentKey) as List?;
    return cached != null && cached.isNotEmpty;
  }

  /// Force refresh content
  Future<bool> forceRefresh() async {
    await _contentBox.delete(_contentVersionKey);
    return syncContent();
  }
}



