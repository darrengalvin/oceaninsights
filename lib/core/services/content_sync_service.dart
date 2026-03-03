import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/whats_new/whats_new_service.dart';

/// Service that syncs all admin-managed content from Supabase
/// and caches it locally for offline use.
/// 
/// Submariners can use the app offline - all content is cached
/// and synced when they have internet access.
class ContentSyncService {
  static final ContentSyncService _instance = ContentSyncService._internal();
  factory ContentSyncService() => _instance;
  ContentSyncService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;
  DateTime? _lastSyncTime;

  // Cache keys
  static const String _keyLastSync = 'content_last_sync';
  static const String _keyMissionObjectives = 'content_mission_objectives';
  static const String _keyMoodReasons = 'content_mood_reasons';
  static const String _keyDailyBriefEnergy = 'content_daily_brief_energy';
  static const String _keyDailyBriefObjectives = 'content_daily_brief_objectives';
  static const String _keyDailyBriefChallenges = 'content_daily_brief_challenges';
  static const String _keyAarWentWell = 'content_aar_went_well';
  static const String _keyAarImprove = 'content_aar_improve';
  static const String _keyAarTakeaway = 'content_aar_takeaway';
  static const String _keyMilitaryRoles = 'content_military_roles';
  static const String _keyCivilianJobs = 'content_civilian_jobs';
  static const String _keyFeelings = 'content_feelings';
  static const String _keyCopingTools = 'content_coping_tools';
  static const String _keyCareerPaths = 'content_career_paths';
  static const String _keyLearningStyles = 'content_learning_styles';
  static const String _keyStudyStrategies = 'content_study_strategies';
  static const String _keyAffirmations = 'content_affirmations';
  static const String _keyConfidenceChallenges = 'content_confidence_challenges';
  static const String _keyConfidenceActions = 'content_confidence_actions';
  static const String _keyInterestCategories = 'content_interest_categories';
  static const String _keyInterestActivities = 'content_interest_activities';
  static const String _keyTipCategories = 'content_tip_categories';
  static const String _keyTips = 'content_tips';
  static const String _keyQuizzes = 'content_quizzes';
  static const String _keyQuizQuestions = 'content_quiz_questions';
  static const String _keyQuizOptions = 'content_quiz_options';
  static const String _keyQuizResults = 'content_quiz_results';
  static const String _keyResourceCategories = 'content_resource_categories';
  static const String _keyResourceSections = 'content_resource_sections';
  static const String _keyResources = 'content_resources';
  static const String _keyChecklistTemplates = 'content_checklist_templates';
  static const String _keyChecklistSections = 'content_checklist_sections';
  static const String _keyChecklistItems = 'content_checklist_items';
  static const String _keyUserTypeScreens = 'content_user_type_screens';
  static const String _keyUserTypeSections = 'content_user_type_sections';
  static const String _keyUserTypeItems = 'content_user_type_items';
  static const String _keyAppSettings = 'content_app_settings';
  // Harassment Wizard
  static const String _keyHarassmentSteps = 'content_harassment_steps';
  static const String _keyHarassmentOptions = 'content_harassment_options';
  static const String _keyHarassmentGuidance = 'content_harassment_guidance';
  static const String _keyHarassmentContacts = 'content_harassment_contacts';
  // Body Education
  static const String _keyBodyTopics = 'content_body_topics';
  static const String _keyBodyQuiz = 'content_body_quiz';
  // Sex Education
  static const String _keySexEdSti = 'content_sex_ed_sti';
  static const String _keySexEdKeyFacts = 'content_sex_ed_key_facts';
  // Bullying Support
  static const String _keyBullyingGuidance = 'content_bullying_guidance';
  static const String _keyBullyingBystander = 'content_bullying_bystander';
  static const String _keyBullyingCoping = 'content_bullying_coping';
  static const String _keyBullyingSupportOrgs = 'content_bullying_support_orgs';
  // Health Education
  static const String _keyContraceptionMethods = 'content_contraception_methods';
  static const String _keyPregnancyTopics = 'content_pregnancy_topics';
  // Learning to be Kind
  static const String _keyKindnessFlipCards = 'content_kindness_flip_cards';
  static const String _keyKindnessScenarios = 'content_kindness_scenarios';
  static const String _keyKindnessOptions = 'content_kindness_options';
  // Service Culture (C2 Drill)
  static const String _keyCultureValues = 'content_culture_values';
  static const String _keyCultureScenarios = 'content_culture_scenarios';
  // Military Perks
  static const String _keyPerksFacts = 'content_perks_facts';
  static const String _keyPerksRegretStories = 'content_perks_regret_stories';
  // Brain Science
  static const String _keyBrainMyths = 'content_brain_myths';
  static const String _keyBrainBiases = 'content_brain_biases';
  static const String _keyBrainBiasOptions = 'content_brain_bias_options';
  static const String _keyBrainExperiments = 'content_brain_experiments';
  static const String _keyBrainExperimentSteps = 'content_brain_experiment_steps';
  // Donations
  static const String _keyDonationImpacts = 'content_donation_impacts';
  static const String _keyDonationSettings = 'content_donation_settings';
  // LGBTQ+ Support
  static const String _keyLgbtqTimeline = 'content_lgbtq_timeline';
  static const String _keyLgbtqMyths = 'content_lgbtq_myths';
  static const String _keyLgbtqTerms = 'content_lgbtq_terms';
  static const String _keyLgbtqAllyScenarios = 'content_lgbtq_ally_scenarios';
  static const String _keyLgbtqAllyOptions = 'content_lgbtq_ally_options';
  static const String _keyLgbtqDeployRegions = 'content_lgbtq_deploy_regions';
  static const String _keyLgbtqSupportOrgs = 'content_lgbtq_support_orgs';
  static const String _keyLgbtqAffirmations = 'content_lgbtq_affirmations';
  // Service Family
  static const String _keySFPhases = 'content_sf_phases';
  static const String _keySFTips = 'content_sf_tips';
  static const String _keySFUnderstand = 'content_sf_understand';
  static const String _keySFSelfcare = 'content_sf_selfcare';
  static const String _keySFAffirmations = 'content_sf_affirmations';
  static const String _keySFChildrenAges = 'content_sf_children_ages';
  static const String _keySFChildrenTips = 'content_sf_children_tips';
  static const String _keySFHelpSigns = 'content_sf_help_signs';
  static const String _keySFSupportOrgs = 'content_sf_support_orgs';

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Initialize the service
  Future<void> init() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    final lastSyncStr = _prefs?.getString(_keyLastSync);
    if (lastSyncStr != null) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }
    
    _initialized = true;
    debugPrint('ContentSyncService initialized. Last sync: $_lastSyncTime');
  }

  /// Check if we have any cached content
  bool get hasCache => _prefs?.containsKey(_keyMissionObjectives) ?? false;

  /// Get the last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Sync all content from Supabase
  /// Call this when the app has internet access
  Future<bool> syncAll() async {
    await init();
    
    try {
      debugPrint('Starting content sync...');
      
      // Sync all content types in parallel
      await Future.wait([
        _syncMissionObjectives(),
        _syncMoodReasons(),
        _syncDailyBrief(),
        _syncAfterActionReview(),
        _syncSkillsTranslator(),
        _syncFeelings(),
        _syncCareerPaths(),
        _syncLearning(),
        _syncAffirmations(),
        _syncInterests(),
        _syncTips(),
        _syncQuizzes(),
        _syncResources(),
        _syncChecklists(),
        _syncUserTypeScreens(),
        _syncAppSettings(),
        _syncHarassmentWizard(),
        _syncBodyEducation(),
        _syncSexEducation(),
        _syncBullyingSupport(),
        _syncHealthEducation(),
        _syncServiceFamily(),
        _syncKindness(),
        _syncServiceCulture(),
        _syncMilitaryPerks(),
        _syncBrainScience(),
        _syncDonations(),
        _syncLgbtqSupport(),
        WhatsNewService().syncReleases(),
      ]);
      
      // Update last sync time
      _lastSyncTime = DateTime.now();
      await _prefs?.setString(_keyLastSync, _lastSyncTime!.toIso8601String());
      
      debugPrint('Content sync completed at $_lastSyncTime');
      return true;
    } catch (e) {
      debugPrint('Content sync failed: $e');
      return false;
    }
  }

  // ============================================================
  // MISSION OBJECTIVES
  // ============================================================

  Future<void> _syncMissionObjectives() async {
    try {
      final response = await _supabase
          .from('mission_objectives')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      
      await _prefs?.setString(_keyMissionObjectives, jsonEncode(response));
      debugPrint('Synced ${response.length} mission objectives');
    } catch (e) {
      debugPrint('Failed to sync mission objectives: $e');
    }
  }

  List<MissionObjective> getMissionObjectives({String? type}) {
    final data = _prefs?.getString(_keyMissionObjectives);
    if (data == null) return _getDefaultMissionObjectives(type);
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var objectives = list.map((e) => MissionObjective.fromJson(e)).toList();
      
      if (type != null) {
        objectives = objectives.where((o) => o.objectiveType == type).toList();
      }
      
      return objectives.isEmpty ? _getDefaultMissionObjectives(type) : objectives;
    } catch (e) {
      return _getDefaultMissionObjectives(type);
    }
  }

  List<MissionObjective> _getDefaultMissionObjectives(String? type) {
    // Fallback defaults if no cache
    final defaults = <MissionObjective>[
      MissionObjective(id: '1', text: 'Complete my main work task', category: 'Work', objectiveType: 'primary'),
      MissionObjective(id: '2', text: 'Have an important conversation', category: 'Communication', objectiveType: 'primary'),
      MissionObjective(id: '3', text: 'Make a key decision', category: 'Leadership', objectiveType: 'primary'),
      MissionObjective(id: '4', text: 'Focus on deep work', category: 'Focus', objectiveType: 'primary'),
      MissionObjective(id: '5', text: 'Exercise or physical training', category: 'Health', objectiveType: 'primary'),
      MissionObjective(id: '11', text: 'Make progress on secondary task', category: 'Work', objectiveType: 'secondary'),
      MissionObjective(id: '12', text: 'Prepare for tomorrow', category: 'Planning', objectiveType: 'secondary'),
      MissionObjective(id: '13', text: 'Follow up on pending items', category: 'Admin', objectiveType: 'secondary'),
      MissionObjective(id: '21', text: 'At minimum, stay present', category: 'Mindset', objectiveType: 'contingency'),
      MissionObjective(id: '22', text: 'Focus on self-care', category: 'Health', objectiveType: 'contingency'),
      MissionObjective(id: '23', text: 'Just get through the day', category: 'Mindset', objectiveType: 'contingency'),
    ];
    
    if (type != null) {
      return defaults.where((o) => o.objectiveType == type).toList();
    }
    return defaults;
  }

  // ============================================================
  // MOOD REASONS
  // ============================================================

  Future<void> _syncMoodReasons() async {
    try {
      final response = await _supabase
          .from('mood_reasons')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      
      await _prefs?.setString(_keyMoodReasons, jsonEncode(response));
      debugPrint('Synced ${response.length} mood reasons');
    } catch (e) {
      debugPrint('Failed to sync mood reasons: $e');
    }
  }

  List<MoodReason> getMoodReasons({String? moodType}) {
    final data = _prefs?.getString(_keyMoodReasons);
    if (data == null) return _getDefaultMoodReasons(moodType);
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var reasons = list.map((e) => MoodReason.fromJson(e)).toList();
      
      if (moodType != null) {
        reasons = reasons.where((r) => r.moodType == moodType).toList();
      }
      
      return reasons.isEmpty ? _getDefaultMoodReasons(moodType) : reasons;
    } catch (e) {
      return _getDefaultMoodReasons(moodType);
    }
  }

  List<MoodReason> _getDefaultMoodReasons(String? moodType) {
    final defaults = <MoodReason>[
      MoodReason(id: '1', text: 'Good sleep', moodType: 'positive', icon: 'bedtime'),
      MoodReason(id: '2', text: 'Accomplished something', moodType: 'positive', icon: 'check_circle'),
      MoodReason(id: '3', text: 'Connected with someone', moodType: 'positive', icon: 'people'),
      MoodReason(id: '10', text: 'Just woke up', moodType: 'neutral', icon: 'wb_sunny'),
      MoodReason(id: '11', text: 'Busy day ahead', moodType: 'neutral', icon: 'schedule'),
      MoodReason(id: '20', text: 'Poor sleep', moodType: 'negative', icon: 'bedtime'),
      MoodReason(id: '21', text: 'Anxiety/worry', moodType: 'negative', icon: 'psychology'),
      MoodReason(id: '22', text: 'Stress', moodType: 'negative', icon: 'warning'),
    ];
    
    if (moodType != null) {
      return defaults.where((r) => r.moodType == moodType).toList();
    }
    return defaults;
  }

  // ============================================================
  // DAILY BRIEF
  // ============================================================

  Future<void> _syncDailyBrief() async {
    try {
      final energyResponse = await _supabase
          .from('daily_brief_energy_levels')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyDailyBriefEnergy, jsonEncode(energyResponse));
      
      final objectivesResponse = await _supabase
          .from('daily_brief_objectives')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyDailyBriefObjectives, jsonEncode(objectivesResponse));
      
      final challengesResponse = await _supabase
          .from('daily_brief_challenges')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyDailyBriefChallenges, jsonEncode(challengesResponse));
      
      debugPrint('Synced daily brief content');
    } catch (e) {
      debugPrint('Failed to sync daily brief: $e');
    }
  }

  List<EnergyLevel> getEnergyLevels() {
    final data = _prefs?.getString(_keyDailyBriefEnergy);
    if (data == null) return _getDefaultEnergyLevels();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final levels = list.map((e) => EnergyLevel.fromJson(e)).toList();
      return levels.isEmpty ? _getDefaultEnergyLevels() : levels;
    } catch (e) {
      return _getDefaultEnergyLevels();
    }
  }

  List<EnergyLevel> _getDefaultEnergyLevels() {
    return [
      EnergyLevel(id: '1', label: 'Fully Charged', emoji: '⚡', description: 'Ready to take on anything'),
      EnergyLevel(id: '2', label: 'Good to Go', emoji: '✓', description: 'Feeling capable and focused'),
      EnergyLevel(id: '3', label: 'Moderate', emoji: '~', description: 'Steady but not peak'),
      EnergyLevel(id: '4', label: 'Low Battery', emoji: '↓', description: 'Need to pace myself'),
      EnergyLevel(id: '5', label: 'Running on Empty', emoji: '○', description: 'Minimal capacity today'),
    ];
  }

  List<BriefOption> getDailyBriefObjectives() {
    final data = _prefs?.getString(_keyDailyBriefObjectives);
    if (data == null) return _getDefaultBriefObjectives();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final options = list.map((e) => BriefOption.fromJson(e)).toList();
      return options.isEmpty ? _getDefaultBriefObjectives() : options;
    } catch (e) {
      return _getDefaultBriefObjectives();
    }
  }

  List<BriefOption> _getDefaultBriefObjectives() {
    return [
      BriefOption(id: '1', text: 'Stay focused on one priority', category: 'Focus'),
      BriefOption(id: '2', text: 'Practice patience today', category: 'Mindset'),
      BriefOption(id: '3', text: 'Connect with someone important', category: 'Relationships'),
      BriefOption(id: '4', text: 'Take care of my health', category: 'Health'),
      BriefOption(id: '5', text: 'Make progress on a goal', category: 'Goals'),
    ];
  }

  List<BriefOption> getDailyBriefChallenges() {
    final data = _prefs?.getString(_keyDailyBriefChallenges);
    if (data == null) return _getDefaultBriefChallenges();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final options = list.map((e) => BriefOption.fromJson(e)).toList();
      return options.isEmpty ? _getDefaultBriefChallenges() : options;
    } catch (e) {
      return _getDefaultBriefChallenges();
    }
  }

  List<BriefOption> _getDefaultBriefChallenges() {
    return [
      BriefOption(id: '1', text: 'Distractions and interruptions', category: 'Focus'),
      BriefOption(id: '2', text: 'Low energy or motivation', category: 'Energy'),
      BriefOption(id: '3', text: 'Difficult conversations', category: 'Relationships'),
      BriefOption(id: '4', text: 'Time pressure', category: 'Work'),
      BriefOption(id: '5', text: 'Negative thoughts', category: 'Mindset'),
    ];
  }

  // ============================================================
  // AFTER ACTION REVIEW
  // ============================================================

  Future<void> _syncAfterActionReview() async {
    try {
      final wentWellResponse = await _supabase
          .from('aar_went_well_options')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyAarWentWell, jsonEncode(wentWellResponse));
      
      final improveResponse = await _supabase
          .from('aar_improve_options')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyAarImprove, jsonEncode(improveResponse));
      
      final takeawayResponse = await _supabase
          .from('aar_takeaway_options')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyAarTakeaway, jsonEncode(takeawayResponse));
      
      debugPrint('Synced AAR content');
    } catch (e) {
      debugPrint('Failed to sync AAR: $e');
    }
  }

  List<String> getAarWentWellOptions() => _getStringList(_keyAarWentWell, [
    'Stayed focused on priorities',
    'Handled stress well',
    'Connected with others',
    'Completed important tasks',
    'Practiced self-care',
  ]);

  List<String> getAarImproveOptions() => _getStringList(_keyAarImprove, [
    'Better time management',
    'More focus, less distraction',
    'Earlier start to the day',
    'More breaks and rest',
    'Better communication',
  ]);

  List<String> getAarTakeawayOptions() => _getStringList(_keyAarTakeaway, [
    'Small steps lead to big progress',
    'I am capable of more than I think',
    'Connection matters',
    'Rest is productive too',
    'Tomorrow is a fresh start',
  ]);

  List<String> _getStringList(String key, List<String> defaults) {
    final data = _prefs?.getString(key);
    if (data == null) return defaults;
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final texts = list.map((e) => e['text'] as String).toList();
      return texts.isEmpty ? defaults : texts;
    } catch (e) {
      return defaults;
    }
  }

  // ============================================================
  // SKILLS TRANSLATOR
  // ============================================================

  Future<void> _syncSkillsTranslator() async {
    try {
      final rolesResponse = await _supabase
          .from('military_roles')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyMilitaryRoles, jsonEncode(rolesResponse));
      
      final jobsResponse = await _supabase
          .from('civilian_jobs')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyCivilianJobs, jsonEncode(jobsResponse));
      
      debugPrint('Synced skills translator content');
    } catch (e) {
      debugPrint('Failed to sync skills translator: $e');
    }
  }

  List<MilitaryRole> getMilitaryRoles() {
    final data = _prefs?.getString(_keyMilitaryRoles);
    if (data == null) return _getDefaultMilitaryRoles();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final roles = list.map((e) => MilitaryRole.fromJson(e)).toList();
      return roles.isEmpty ? _getDefaultMilitaryRoles() : roles;
    } catch (e) {
      return _getDefaultMilitaryRoles();
    }
  }

  List<MilitaryRole> _getDefaultMilitaryRoles() {
    return [
      MilitaryRole(id: '1', title: 'Infantry', branch: 'Army'),
      MilitaryRole(id: '2', title: 'Medic/Corpsman', branch: 'All'),
      MilitaryRole(id: '3', title: 'Intelligence Analyst', branch: 'All'),
      MilitaryRole(id: '4', title: 'Logistics/Supply', branch: 'All'),
      MilitaryRole(id: '5', title: 'Communications', branch: 'All'),
    ];
  }

  List<CivilianJob> getCivilianJobs() {
    final data = _prefs?.getString(_keyCivilianJobs);
    if (data == null) return _getDefaultCivilianJobs();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final jobs = list.map((e) => CivilianJob.fromJson(e)).toList();
      return jobs.isEmpty ? _getDefaultCivilianJobs() : jobs;
    } catch (e) {
      return _getDefaultCivilianJobs();
    }
  }

  List<CivilianJob> _getDefaultCivilianJobs() {
    return [
      CivilianJob(id: '1', title: 'Security Manager', description: 'Oversee security operations', salaryRange: '\$60K-\$100K', growthOutlook: 'High'),
      CivilianJob(id: '2', title: 'Project Manager', description: 'Lead teams and manage projects', salaryRange: '\$70K-\$120K', growthOutlook: 'High'),
      CivilianJob(id: '3', title: 'Healthcare Administrator', description: 'Manage healthcare facilities', salaryRange: '\$65K-\$110K', growthOutlook: 'High'),
    ];
  }

  // ============================================================
  // FEELINGS & COPING TOOLS
  // ============================================================

  Future<void> _syncFeelings() async {
    try {
      final feelingsResponse = await _supabase
          .from('feelings')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyFeelings, jsonEncode(feelingsResponse));
      
      final toolsResponse = await _supabase
          .from('coping_tools')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyCopingTools, jsonEncode(toolsResponse));
      
      debugPrint('Synced feelings content');
    } catch (e) {
      debugPrint('Failed to sync feelings: $e');
    }
  }

  List<Feeling> getFeelings() {
    final data = _prefs?.getString(_keyFeelings);
    if (data == null) return _getDefaultFeelings();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final feelings = list.map((e) => Feeling.fromJson(e)).toList();
      return feelings.isEmpty ? _getDefaultFeelings() : feelings;
    } catch (e) {
      return _getDefaultFeelings();
    }
  }

  List<Feeling> _getDefaultFeelings() {
    return [
      Feeling(id: '1', name: 'Anxious', emoji: '😰', color: '#F59E0B'),
      Feeling(id: '2', name: 'Angry', emoji: '😠', color: '#EF4444'),
      Feeling(id: '3', name: 'Sad', emoji: '😢', color: '#3B82F6'),
      Feeling(id: '4', name: 'Overwhelmed', emoji: '🤯', color: '#8B5CF6'),
      Feeling(id: '5', name: 'Lonely', emoji: '😔', color: '#6366F1'),
      Feeling(id: '6', name: 'Scared', emoji: '😨', color: '#EC4899'),
    ];
  }

  List<CopingTool> getCopingTools({String? feelingId}) {
    final data = _prefs?.getString(_keyCopingTools);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var tools = list.map((e) => CopingTool.fromJson(e)).toList();
      
      if (feelingId != null) {
        tools = tools.where((t) => t.feelingId == feelingId).toList();
      }
      
      return tools;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // CAREER PATHS
  // ============================================================

  Future<void> _syncCareerPaths() async {
    try {
      final response = await _supabase
          .from('career_paths')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyCareerPaths, jsonEncode(response));
      debugPrint('Synced ${response.length} career paths');
    } catch (e) {
      debugPrint('Failed to sync career paths: $e');
    }
  }

  List<CareerPath> getCareerPaths() {
    final data = _prefs?.getString(_keyCareerPaths);
    if (data == null) return _getDefaultCareerPaths();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final careers = list.map((e) => CareerPath.fromJson(e)).toList();
      return careers.isEmpty ? _getDefaultCareerPaths() : careers;
    } catch (e) {
      return _getDefaultCareerPaths();
    }
  }

  List<CareerPath> _getDefaultCareerPaths() {
    return [
      CareerPath(id: '1', title: 'Software Developer', emoji: '💻', tagline: 'Build the future with code', description: 'Create apps and software.', salaryRange: '\$70K-\$150K'),
      CareerPath(id: '2', title: 'Healthcare Professional', emoji: '🏥', tagline: 'Help people heal', description: 'Make a direct impact on lives.', salaryRange: '\$50K-\$200K'),
      CareerPath(id: '3', title: 'Creative Designer', emoji: '🎨', tagline: 'Turn ideas into visuals', description: 'Design experiences.', salaryRange: '\$45K-\$100K'),
    ];
  }

  // ============================================================
  // LEARNING & STUDY
  // ============================================================

  Future<void> _syncLearning() async {
    try {
      final stylesResponse = await _supabase
          .from('learning_styles')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyLearningStyles, jsonEncode(stylesResponse));
      
      final strategiesResponse = await _supabase
          .from('study_strategies')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyStudyStrategies, jsonEncode(strategiesResponse));
      
      debugPrint('Synced learning content');
    } catch (e) {
      debugPrint('Failed to sync learning: $e');
    }
  }

  List<LearningStyle> getLearningStyles() {
    final data = _prefs?.getString(_keyLearningStyles);
    if (data == null) return _getDefaultLearningStyles();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final styles = list.map((e) => LearningStyle.fromJson(e)).toList();
      return styles.isEmpty ? _getDefaultLearningStyles() : styles;
    } catch (e) {
      return _getDefaultLearningStyles();
    }
  }

  List<LearningStyle> _getDefaultLearningStyles() {
    return [
      LearningStyle(id: '1', name: 'Visual', emoji: '👁️', description: 'You learn best by seeing', tips: ['Use diagrams', 'Color-code notes', 'Watch videos']),
      LearningStyle(id: '2', name: 'Auditory', emoji: '👂', description: 'You learn best by hearing', tips: ['Record lectures', 'Discuss topics', 'Use podcasts']),
      LearningStyle(id: '3', name: 'Reading/Writing', emoji: '📝', description: 'You learn best through text', tips: ['Take notes', 'Rewrite concepts', 'Create summaries']),
      LearningStyle(id: '4', name: 'Kinesthetic', emoji: '🤲', description: 'You learn best by doing', tips: ['Hands-on practice', 'Take breaks', 'Act out scenarios']),
    ];
  }

  List<StudyStrategy> getStudyStrategies() {
    final data = _prefs?.getString(_keyStudyStrategies);
    if (data == null) return _getDefaultStudyStrategies();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final strategies = list.map((e) => StudyStrategy.fromJson(e)).toList();
      return strategies.isEmpty ? _getDefaultStudyStrategies() : strategies;
    } catch (e) {
      return _getDefaultStudyStrategies();
    }
  }

  List<StudyStrategy> _getDefaultStudyStrategies() {
    return [
      StudyStrategy(id: '1', name: 'Pomodoro Technique', description: '25 min focus, 5 min break', bestFor: ['All styles']),
      StudyStrategy(id: '2', name: 'Mind Mapping', description: 'Visual diagram of ideas', bestFor: ['Visual', 'Kinesthetic']),
      StudyStrategy(id: '3', name: 'Teach Someone', description: 'Explain concepts to others', bestFor: ['Auditory', 'Kinesthetic']),
    ];
  }

  // ============================================================
  // AFFIRMATIONS & CONFIDENCE
  // ============================================================

  Future<void> _syncAffirmations() async {
    try {
      final affirmationsResponse = await _supabase
          .from('affirmations')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyAffirmations, jsonEncode(affirmationsResponse));
      
      final challengesResponse = await _supabase
          .from('confidence_challenges')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyConfidenceChallenges, jsonEncode(challengesResponse));
      
      final actionsResponse = await _supabase
          .from('confidence_actions')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyConfidenceActions, jsonEncode(actionsResponse));
      
      debugPrint('Synced affirmations content');
    } catch (e) {
      debugPrint('Failed to sync affirmations: $e');
    }
  }

  List<String> getAffirmations() => _getStringList(_keyAffirmations, [
    'I am capable and strong',
    'My voice matters',
    'I learn from every experience',
    'I am enough exactly as I am',
    'I can handle whatever comes',
  ]);

  List<String> getConfidenceChallenges() => _getStringList(_keyConfidenceChallenges, [
    'Speaking up in groups',
    'Trying new things',
    'Meeting new people',
    'Handling criticism',
    'Making decisions',
  ]);

  List<ConfidenceAction> getConfidenceActions() {
    final data = _prefs?.getString(_keyConfidenceActions);
    if (data == null) return _getDefaultConfidenceActions();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final actions = list.map((e) => ConfidenceAction.fromJson(e)).toList();
      return actions.isEmpty ? _getDefaultConfidenceActions() : actions;
    } catch (e) {
      return _getDefaultConfidenceActions();
    }
  }

  List<ConfidenceAction> _getDefaultConfidenceActions() {
    return [
      ConfidenceAction(id: '1', text: 'Give someone a genuine compliment', difficulty: 'easy'),
      ConfidenceAction(id: '2', text: 'Share an idea in a group', difficulty: 'medium'),
      ConfidenceAction(id: '3', text: 'Try something new', difficulty: 'medium'),
      ConfidenceAction(id: '4', text: 'Start a conversation with someone new', difficulty: 'hard'),
    ];
  }

  // ============================================================
  // INTERESTS
  // ============================================================

  Future<void> _syncInterests() async {
    try {
      final categoriesResponse = await _supabase
          .from('interest_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyInterestCategories, jsonEncode(categoriesResponse));
      
      final activitiesResponse = await _supabase
          .from('interest_activities')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyInterestActivities, jsonEncode(activitiesResponse));
      
      debugPrint('Synced interests content');
    } catch (e) {
      debugPrint('Failed to sync interests: $e');
    }
  }

  List<InterestCategory> getInterestCategories() {
    final data = _prefs?.getString(_keyInterestCategories);
    if (data == null) return _getDefaultInterestCategories();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final categories = list.map((e) => InterestCategory.fromJson(e)).toList();
      return categories.isEmpty ? _getDefaultInterestCategories() : categories;
    } catch (e) {
      return _getDefaultInterestCategories();
    }
  }

  List<InterestCategory> _getDefaultInterestCategories() {
    return [
      InterestCategory(id: '1', name: 'Creative', emoji: '🎨', color: '#EC4899'),
      InterestCategory(id: '2', name: 'Tech', emoji: '💻', color: '#3B82F6'),
      InterestCategory(id: '3', name: 'Active', emoji: '⚽', color: '#22C55E'),
      InterestCategory(id: '4', name: 'Nature', emoji: '🌿', color: '#10B981'),
      InterestCategory(id: '5', name: 'Social', emoji: '👥', color: '#F59E0B'),
      InterestCategory(id: '6', name: 'Learning', emoji: '📚', color: '#8B5CF6'),
    ];
  }

  List<InterestActivity> getInterestActivities({String? categoryId}) {
    final data = _prefs?.getString(_keyInterestActivities);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var activities = list.map((e) => InterestActivity.fromJson(e)).toList();
      
      if (categoryId != null) {
        activities = activities.where((a) => a.categoryId == categoryId).toList();
      }
      
      return activities;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // TIPS
  // ============================================================

  Future<void> _syncTips() async {
    try {
      final categoriesResponse = await _supabase
          .from('tip_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyTipCategories, jsonEncode(categoriesResponse));
      
      final tipsResponse = await _supabase
          .from('tips')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyTips, jsonEncode(tipsResponse));
      
      debugPrint('Synced tips content');
    } catch (e) {
      debugPrint('Failed to sync tips: $e');
    }
  }

  List<TipCategory> getTipCategories() {
    final data = _prefs?.getString(_keyTipCategories);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => TipCategory.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  List<Tip> getTips({String? categoryId}) {
    final data = _prefs?.getString(_keyTips);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var tips = list.map((e) => Tip.fromJson(e)).toList();
      
      if (categoryId != null) {
        tips = tips.where((t) => t.categoryId == categoryId).toList();
      }
      
      return tips;
    } catch (e) {
      return [];
    }
  }

  /// Get a tip category by its slug
  TipCategory? getTipCategoryBySlug(String slug) {
    final categories = getTipCategories();
    try {
      return categories.firstWhere((c) => c.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Get tips for a category slug
  List<Tip> getTipsBySlug(String slug) {
    final category = getTipCategoryBySlug(slug);
    if (category == null) return [];
    return getTips(categoryId: category.id);
  }

  // ============================================================
  // QUIZZES
  // ============================================================

  Future<void> _syncQuizzes() async {
    try {
      final quizzesResponse = await _supabase
          .from('quizzes')
          .select()
          .eq('is_active', true);
      await _prefs?.setString(_keyQuizzes, jsonEncode(quizzesResponse));
      
      final questionsResponse = await _supabase
          .from('quiz_questions')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyQuizQuestions, jsonEncode(questionsResponse));
      
      final optionsResponse = await _supabase
          .from('quiz_options')
          .select()
          .order('sort_order');
      await _prefs?.setString(_keyQuizOptions, jsonEncode(optionsResponse));
      
      final resultsResponse = await _supabase
          .from('quiz_results')
          .select();
      await _prefs?.setString(_keyQuizResults, jsonEncode(resultsResponse));
      
      debugPrint('Synced quizzes content');
    } catch (e) {
      debugPrint('Failed to sync quizzes: $e');
    }
  }

  List<Quiz> getQuizzes() {
    final data = _prefs?.getString(_keyQuizzes);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => Quiz.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  List<QuizQuestion> getQuizQuestions(String quizId) {
    final data = _prefs?.getString(_keyQuizQuestions);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list
          .map((e) => QuizQuestion.fromJson(e))
          .where((q) => q.quizId == quizId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<QuizOption> getQuizOptions(String questionId) {
    final data = _prefs?.getString(_keyQuizOptions);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list
          .map((e) => QuizOption.fromJson(e))
          .where((o) => o.questionId == questionId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  QuizResult? getQuizResult(String quizId, String resultKey) {
    final data = _prefs?.getString(_keyQuizResults);
    if (data == null) return null;
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final results = list.map((e) => QuizResult.fromJson(e)).toList();
      return results.firstWhere(
        (r) => r.quizId == quizId && r.resultKey == resultKey,
        orElse: () => results.first,
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // RESOURCES
  // ============================================================

  Future<void> _syncResources() async {
    try {
      final categoriesResponse = await _supabase
          .from('resource_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyResourceCategories, jsonEncode(categoriesResponse));
      
      final sectionsResponse = await _supabase
          .from('resource_sections')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyResourceSections, jsonEncode(sectionsResponse));
      
      final resourcesResponse = await _supabase
          .from('resources')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyResources, jsonEncode(resourcesResponse));
      
      debugPrint('Synced resources content');
    } catch (e) {
      debugPrint('Failed to sync resources: $e');
    }
  }

  List<ResourceCategory> getResourceCategories() {
    final data = _prefs?.getString(_keyResourceCategories);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => ResourceCategory.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  List<ResourceSection> getResourceSections({String? categoryId}) {
    final data = _prefs?.getString(_keyResourceSections);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var sections = list.map((e) => ResourceSection.fromJson(e)).toList();
      
      if (categoryId != null) {
        sections = sections.where((s) => s.categoryId == categoryId).toList();
      }
      
      return sections;
    } catch (e) {
      return [];
    }
  }

  List<Resource> getResources({String? sectionId}) {
    final data = _prefs?.getString(_keyResources);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var resources = list.map((e) => Resource.fromJson(e)).toList();
      
      if (sectionId != null) {
        resources = resources.where((r) => r.sectionId == sectionId).toList();
      }
      
      return resources;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // CHECKLISTS
  // ============================================================

  Future<void> _syncChecklists() async {
    try {
      final templatesResponse = await _supabase
          .from('checklist_templates')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyChecklistTemplates, jsonEncode(templatesResponse));
      
      final sectionsResponse = await _supabase
          .from('checklist_sections')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyChecklistSections, jsonEncode(sectionsResponse));
      
      final itemsResponse = await _supabase
          .from('checklist_items')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyChecklistItems, jsonEncode(itemsResponse));
      
      debugPrint('Synced checklists content');
    } catch (e) {
      debugPrint('Failed to sync checklists: $e');
    }
  }

  List<ChecklistTemplate> getChecklistTemplates() {
    final data = _prefs?.getString(_keyChecklistTemplates);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => ChecklistTemplate.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  List<ChecklistSection> getChecklistSections({String? templateId}) {
    final data = _prefs?.getString(_keyChecklistSections);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var sections = list.map((e) => ChecklistSection.fromJson(e)).toList();
      
      if (templateId != null) {
        sections = sections.where((s) => s.templateId == templateId).toList();
      }
      
      return sections;
    } catch (e) {
      return [];
    }
  }

  List<ChecklistItem> getChecklistItems({String? sectionId}) {
    final data = _prefs?.getString(_keyChecklistItems);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var items = list.map((e) => ChecklistItem.fromJson(e)).toList();
      
      if (sectionId != null) {
        items = items.where((i) => i.sectionId == sectionId).toList();
      }
      
      return items;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // USER TYPE SCREENS (Military, Veteran, Youth)
  // ============================================================

  Future<void> _syncUserTypeScreens() async {
    try {
      final screensResponse = await _supabase
          .from('user_type_screens')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyUserTypeScreens, jsonEncode(screensResponse));
      
      final sectionsResponse = await _supabase
          .from('user_type_sections')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyUserTypeSections, jsonEncode(sectionsResponse));
      
      final itemsResponse = await _supabase
          .from('user_type_items')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyUserTypeItems, jsonEncode(itemsResponse));
      
      debugPrint('Synced user type screens content');
    } catch (e) {
      debugPrint('Failed to sync user type screens: $e');
    }
  }

  List<UserTypeScreen> getUserTypeScreens() {
    final data = _prefs?.getString(_keyUserTypeScreens);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => UserTypeScreen.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  UserTypeScreen? getUserTypeScreen(String slug) {
    final screens = getUserTypeScreens();
    try {
      return screens.firstWhere((s) => s.slug == slug);
    } catch (e) {
      return null;
    }
  }

  List<UserTypeSection> getUserTypeSections({String? screenId}) {
    final data = _prefs?.getString(_keyUserTypeSections);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var sections = list.map((e) => UserTypeSection.fromJson(e)).toList();
      
      if (screenId != null) {
        sections = sections.where((s) => s.screenId == screenId).toList();
      }
      
      return sections;
    } catch (e) {
      return [];
    }
  }

  List<UserTypeItem> getUserTypeItems({String? sectionId}) {
    final data = _prefs?.getString(_keyUserTypeItems);
    if (data == null) return [];
    
    try {
      final List<dynamic> list = jsonDecode(data);
      var items = list.map((e) => UserTypeItem.fromJson(e)).toList();
      
      if (sectionId != null) {
        items = items.where((i) => i.sectionId == sectionId).toList();
      }
      
      return items;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // APP SETTINGS
  // ============================================================

  Future<void> _syncAppSettings() async {
    try {
      // Use RPC to get secret settings (only accessible via service role or RPC)
      final response = await _supabase
          .rpc('get_setting', params: {'setting_key': 'developer_phrase'});
      
      if (response != null) {
        final settings = {'developer_phrase': response};
        await _prefs?.setString(_keyAppSettings, jsonEncode(settings));
        debugPrint('Synced app settings');
      }
    } catch (e) {
      debugPrint('Failed to sync app settings: $e');
    }
  }

  /// Get the developer phrase for secret access
  /// Returns cached value or default if not synced
  String getDeveloperPhrase() {
    final data = _prefs?.getString(_keyAppSettings);
    if (data == null) return 'deepblue'; // Default fallback
    
    try {
      final Map<String, dynamic> settings = jsonDecode(data);
      return settings['developer_phrase'] ?? 'deepblue';
    } catch (e) {
      return 'deepblue';
    }
  }

  // ============================================================
  // HARASSMENT WIZARD
  // ============================================================

  Future<void> _syncHarassmentWizard() async {
    try {
      final stepsResponse = await _supabase
          .from('harassment_wizard_steps')
          .select()
          .eq('is_active', true)
          .order('step_number');
      await _prefs?.setString(_keyHarassmentSteps, jsonEncode(stepsResponse));
      
      final optionsResponse = await _supabase
          .from('harassment_wizard_options')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyHarassmentOptions, jsonEncode(optionsResponse));
      
      final guidanceResponse = await _supabase
          .from('harassment_wizard_guidance')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyHarassmentGuidance, jsonEncode(guidanceResponse));
      
      final contactsResponse = await _supabase
          .from('harassment_wizard_contacts')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      await _prefs?.setString(_keyHarassmentContacts, jsonEncode(contactsResponse));
      
      debugPrint('Synced harassment wizard content');
    } catch (e) {
      debugPrint('Failed to sync harassment wizard: $e');
    }
  }

  List<HarassmentWizardStep> getHarassmentWizardSteps() {
    final data = _prefs?.getString(_keyHarassmentSteps);
    if (data == null) return _getDefaultHarassmentSteps();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final steps = list.map((e) => HarassmentWizardStep.fromJson(e)).toList();
      return steps.isEmpty ? _getDefaultHarassmentSteps() : steps;
    } catch (e) {
      return _getDefaultHarassmentSteps();
    }
  }

  List<HarassmentWizardStep> _getDefaultHarassmentSteps() {
    return [
      HarassmentWizardStep(id: '1', title: 'What are you experiencing?', subtitle: 'Select the option that best describes your situation.', stepNumber: 1),
      HarassmentWizardStep(id: '2', title: 'Where is this happening?', subtitle: 'This helps us provide the most relevant guidance.', stepNumber: 2),
      HarassmentWizardStep(id: '3', title: 'How often is this happening?', subtitle: 'There is no wrong answer. Your experience is valid.', stepNumber: 3),
      HarassmentWizardStep(id: '4', title: 'How is this affecting you?', subtitle: 'Select all that apply.', stepNumber: 4),
    ];
  }

  List<HarassmentWizardOption> getHarassmentWizardOptions() {
    final data = _prefs?.getString(_keyHarassmentOptions);
    if (data == null) return _getDefaultHarassmentOptions();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final options = list.map((e) => HarassmentWizardOption.fromJson(e)).toList();
      return options.isEmpty ? _getDefaultHarassmentOptions() : options;
    } catch (e) {
      return _getDefaultHarassmentOptions();
    }
  }

  List<HarassmentWizardOption> _getDefaultHarassmentOptions() {
    return [
      HarassmentWizardOption(id: '1', stepId: '1', text: 'Unwanted comments or remarks', description: 'Comments about your appearance, gender, or personal life', tag: 'verbal'),
      HarassmentWizardOption(id: '2', stepId: '1', text: 'Unwanted physical contact', description: 'Any physical contact you did not welcome', tag: 'physical'),
      HarassmentWizardOption(id: '3', stepId: '1', text: 'Being excluded or isolated', description: 'Deliberately left out of activities or briefings', tag: 'exclusion'),
      HarassmentWizardOption(id: '4', stepId: '1', text: 'Inappropriate messages or images', description: 'Unwanted sexual or demeaning content', tag: 'digital'),
      HarassmentWizardOption(id: '5', stepId: '1', text: 'Pressure for relationship or favours', tag: 'coercion'),
      HarassmentWizardOption(id: '6', stepId: '1', text: 'Feeling unsafe', tag: 'safety'),
      HarassmentWizardOption(id: '7', stepId: '1', text: 'Bullying related to gender', tag: 'gender_bullying'),
      HarassmentWizardOption(id: '8', stepId: '1', text: 'Something else that feels wrong', tag: 'other'),
      HarassmentWizardOption(id: '10', stepId: '2', text: 'In the workplace', tag: 'workplace'),
      HarassmentWizardOption(id: '11', stepId: '2', text: 'In accommodation or barracks', tag: 'accommodation'),
      HarassmentWizardOption(id: '12', stepId: '2', text: 'Online or social media', tag: 'online'),
      HarassmentWizardOption(id: '13', stepId: '2', text: 'During deployment or exercise', tag: 'deployment'),
      HarassmentWizardOption(id: '14', stepId: '2', text: 'During training', tag: 'training'),
      HarassmentWizardOption(id: '15', stepId: '2', text: 'At social events', tag: 'social'),
      HarassmentWizardOption(id: '20', stepId: '3', text: 'It happened once', tag: 'once'),
      HarassmentWizardOption(id: '21', stepId: '3', text: 'A few times', tag: 'few_times'),
      HarassmentWizardOption(id: '22', stepId: '3', text: 'Regularly', tag: 'regular'),
      HarassmentWizardOption(id: '23', stepId: '3', text: 'Constantly', tag: 'constant'),
      HarassmentWizardOption(id: '30', stepId: '4', text: 'Anxiety or worry', tag: 'impact_anxiety'),
      HarassmentWizardOption(id: '31', stepId: '4', text: 'Difficulty sleeping', tag: 'impact_sleep'),
      HarassmentWizardOption(id: '32', stepId: '4', text: 'Loss of confidence', tag: 'impact_confidence'),
      HarassmentWizardOption(id: '33', stepId: '4', text: 'Avoiding certain people or places', tag: 'impact_avoidance'),
      HarassmentWizardOption(id: '34', stepId: '4', text: 'Affecting my work performance', tag: 'impact_work'),
      HarassmentWizardOption(id: '35', stepId: '4', text: 'Thinking about leaving the service', tag: 'impact_leaving'),
    ];
  }

  List<HarassmentGuidanceCard> getHarassmentWizardGuidance() {
    final data = _prefs?.getString(_keyHarassmentGuidance);
    if (data == null) return _getDefaultHarassmentGuidance();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final guidance = list.map((e) => HarassmentGuidanceCard.fromJson(e)).toList();
      return guidance.isEmpty ? _getDefaultHarassmentGuidance() : guidance;
    } catch (e) {
      return _getDefaultHarassmentGuidance();
    }
  }

  List<HarassmentGuidanceCard> _getDefaultHarassmentGuidance() {
    return [
      HarassmentGuidanceCard(id: '1', title: 'You are not alone', message: 'What you are experiencing is not your fault, and you do not have to deal with it alone.', guidanceType: 'info', priority: 100, matchTags: [], isUniversal: true),
      HarassmentGuidanceCard(id: '2', title: 'Your rights', message: 'Under the Armed Forces Act and the Equality Act 2010, you are protected from harassment, bullying, and discrimination.', guidanceType: 'rights', priority: 90, matchTags: [], isUniversal: true),
      HarassmentGuidanceCard(id: '3', title: 'Formal complaint process', message: 'You have the right to make a formal Service Complaint. Contact your Unit Welfare Officer to begin the process.', guidanceType: 'action_formal', priority: 70, matchTags: [], isUniversal: true),
      HarassmentGuidanceCard(id: '4', title: 'Informal options', message: 'Not ready for a formal complaint? Speak to a trusted colleague, contact SSAFA, or use the Confidential Support Line.', guidanceType: 'action_informal', priority: 65, matchTags: [], isUniversal: true),
    ];
  }

  List<HarassmentContact> getHarassmentWizardContacts() {
    final data = _prefs?.getString(_keyHarassmentContacts);
    if (data == null) return _getDefaultHarassmentContacts();
    
    try {
      final List<dynamic> list = jsonDecode(data);
      final contacts = list.map((e) => HarassmentContact.fromJson(e)).toList();
      return contacts.isEmpty ? _getDefaultHarassmentContacts() : contacts;
    } catch (e) {
      return _getDefaultHarassmentContacts();
    }
  }

  List<HarassmentContact> _getDefaultHarassmentContacts() {
    return [
      HarassmentContact(id: '1', name: 'Local Emergency Services', description: 'If you are in immediate danger, call your local emergency number. UK: 999. International: 112. On base: contact the Guardroom or Duty Officer.', isEmergency: true),
      HarassmentContact(id: '2', name: 'Your Unit Welfare Officer', description: 'Your first point of contact for confidential support within your unit.', availability: 'During working hours or via Duty Officer', isEmergency: false),
      HarassmentContact(id: '3', name: 'Unit Padre / Chaplain', description: 'Completely confidential support. Conversations with a Padre are privileged.', availability: 'Available at all times', isEmergency: false),
      HarassmentContact(id: '4', name: 'SSAFA', description: 'Forces charity providing confidential support worldwide.', website: 'https://www.ssafa.org.uk', availability: 'Online support available worldwide', isEmergency: false),
    ];
  }

  // ============================================================
  // BODY EDUCATION SYNC
  // ============================================================

  Future<void> _syncBodyEducation() async {
    try {
      final topics = await _supabase.from('body_education_topics').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBodyTopics, jsonEncode(topics));
      final quiz = await _supabase.from('body_education_quiz').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBodyQuiz, jsonEncode(quiz));
      debugPrint('Synced body education content');
    } catch (e) { debugPrint('Error syncing body education: $e'); }
  }

  List<Map<String, dynamic>> getBodyTopics(String tab) {
    final data = _prefs?.getString(_keyBodyTopics);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>().where((t) => t['tab'] == tab).toList();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getBodyQuiz() {
    final data = _prefs?.getString(_keyBodyQuiz);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  // ============================================================
  // SEX EDUCATION SYNC
  // ============================================================

  Future<void> _syncSexEducation() async {
    try {
      final sti = await _supabase.from('sex_ed_sti_info').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySexEdSti, jsonEncode(sti));
      final facts = await _supabase.from('sex_ed_key_facts').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySexEdKeyFacts, jsonEncode(facts));
      debugPrint('Synced sex education content');
    } catch (e) { debugPrint('Error syncing sex education: $e'); }
  }

  List<Map<String, dynamic>> getSexEdStiInfo() {
    final data = _prefs?.getString(_keySexEdSti);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSexEdKeyFacts() {
    final data = _prefs?.getString(_keySexEdKeyFacts);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  // ============================================================
  // BULLYING SUPPORT SYNC
  // ============================================================

  Future<void> _syncBullyingSupport() async {
    try {
      final guidance = await _supabase.from('bullying_guidance_cards').select('*').eq('is_active', true).order('priority', ascending: false);
      await _prefs?.setString(_keyBullyingGuidance, jsonEncode(guidance));
      final bystander = await _supabase.from('bullying_bystander_actions').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBullyingBystander, jsonEncode(bystander));
      final coping = await _supabase.from('bullying_coping_strategies').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBullyingCoping, jsonEncode(coping));
      final orgs = await _supabase.from('bullying_support_orgs').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBullyingSupportOrgs, jsonEncode(orgs));
      debugPrint('Synced bullying support content');
    } catch (e) { debugPrint('Error syncing bullying support: $e'); }
  }

  List<Map<String, dynamic>> getBullyingGuidanceCards() {
    final data = _prefs?.getString(_keyBullyingGuidance);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getBullyingBystanderActions() {
    final data = _prefs?.getString(_keyBullyingBystander);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getBullyingCopingStrategies() {
    final data = _prefs?.getString(_keyBullyingCoping);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getBullyingSupportOrgs() {
    final data = _prefs?.getString(_keyBullyingSupportOrgs);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  // ============================================================
  // HEALTH EDUCATION SYNC
  // ============================================================

  Future<void> _syncHealthEducation() async {
    try {
      final methods = await _supabase.from('health_contraception_methods').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyContraceptionMethods, jsonEncode(methods));
      final pregnancy = await _supabase.from('health_pregnancy_topics').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyPregnancyTopics, jsonEncode(pregnancy));
      debugPrint('Synced health education content');
    } catch (e) { debugPrint('Error syncing health education: $e'); }
  }

  List<Map<String, dynamic>> getContraceptionMethods() {
    final data = _prefs?.getString(_keyContraceptionMethods);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getPregnancyTopics() {
    final data = _prefs?.getString(_keyPregnancyTopics);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  // ============================================================
  // SERVICE FAMILY SYNC
  // ============================================================

  Future<void> _syncServiceFamily() async {
    try {
      final phases = await _supabase.from('service_family_deployment_phases').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFPhases, jsonEncode(phases));

      final tips = await _supabase.from('service_family_deployment_tips').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFTips, jsonEncode(tips));

      final understand = await _supabase.from('service_family_understand_topics').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFUnderstand, jsonEncode(understand));

      final selfcare = await _supabase.from('service_family_selfcare_strategies').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFSelfcare, jsonEncode(selfcare));

      final affirmations = await _supabase.from('service_family_affirmations').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFAffirmations, jsonEncode(affirmations));

      final childAges = await _supabase.from('service_family_children_age_groups').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFChildrenAges, jsonEncode(childAges));

      final childTips = await _supabase.from('service_family_children_tips').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFChildrenTips, jsonEncode(childTips));

      final helpSigns = await _supabase.from('service_family_help_signs').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFHelpSigns, jsonEncode(helpSigns));

      final orgs = await _supabase.from('service_family_support_orgs').select('*').eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keySFSupportOrgs, jsonEncode(orgs));

      debugPrint('Synced service family content');
    } catch (e) { debugPrint('Error syncing service family: $e'); }
  }

  List<Map<String, dynamic>> getSFDeploymentPhases() {
    final data = _prefs?.getString(_keySFPhases);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFDeploymentTips() {
    final data = _prefs?.getString(_keySFTips);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFUnderstandTopics() {
    final data = _prefs?.getString(_keySFUnderstand);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFSelfcareStrategies() {
    final data = _prefs?.getString(_keySFSelfcare);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFAffirmations() {
    final data = _prefs?.getString(_keySFAffirmations);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFChildrenAgeGroups() {
    final data = _prefs?.getString(_keySFChildrenAges);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFChildrenTips() {
    final data = _prefs?.getString(_keySFChildrenTips);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFHelpSigns() {
    final data = _prefs?.getString(_keySFHelpSigns);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getSFSupportOrgs() {
    final data = _prefs?.getString(_keySFSupportOrgs);
    if (data == null) return [];
    try { return (jsonDecode(data) as List).cast<Map<String, dynamic>>(); } catch (e) { return []; }
  }
  // ============================================================
  // LEARNING TO BE KIND SYNC
  // ============================================================

  Future<void> _syncKindness() async {
    try {
      final flipRes = await _supabase.from('kindness_flip_cards').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyKindnessFlipCards, jsonEncode(flipRes));
      debugPrint('Synced ${flipRes.length} kindness flip cards');

      final scenRes = await _supabase.from('kindness_react_scenarios').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyKindnessScenarios, jsonEncode(scenRes));
      debugPrint('Synced ${scenRes.length} kindness scenarios');

      final optRes = await _supabase.from('kindness_react_options').select().order('sort_order');
      await _prefs?.setString(_keyKindnessOptions, jsonEncode(optRes));
      debugPrint('Synced ${optRes.length} kindness reaction options');
    } catch (e) {
      debugPrint('Failed to sync kindness content: $e');
    }
  }

  List<Map<String, dynamic>> getKindnessFlipCards() {
    final data = _prefs?.getString(_keyKindnessFlipCards);
    if (data == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getKindnessScenarios() {
    final data = _prefs?.getString(_keyKindnessScenarios);
    if (data == null) return [];
    try {
      final scenarios = List<Map<String, dynamic>>.from(jsonDecode(data));
      final optionsData = _prefs?.getString(_keyKindnessOptions);
      final options = optionsData != null ? List<Map<String, dynamic>>.from(jsonDecode(optionsData)) : <Map<String, dynamic>>[];

      return scenarios.map((s) {
        final sOpts = options.where((o) => o['scenario_id'] == s['id']).toList();
        return {...s, 'options': sOpts};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // SERVICE CULTURE (C2 DRILL) SYNC
  // ============================================================

  Future<void> _syncServiceCulture() async {
    try {
      final valRes = await _supabase.from('culture_values').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyCultureValues, jsonEncode(valRes));
      debugPrint('Synced ${valRes.length} culture values');

      final scenRes = await _supabase.from('culture_scenarios').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyCultureScenarios, jsonEncode(scenRes));
      debugPrint('Synced ${scenRes.length} culture scenarios');
    } catch (e) {
      debugPrint('Failed to sync service culture content: $e');
    }
  }

  List<Map<String, dynamic>> getCultureValues() {
    final data = _prefs?.getString(_keyCultureValues);
    if (data == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getCultureScenarios() {
    final data = _prefs?.getString(_keyCultureScenarios);
    if (data == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // MILITARY PERKS SYNC
  // ============================================================

  Future<void> _syncMilitaryPerks() async {
    try {
      final factsRes = await _supabase.from('perks_facts').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyPerksFacts, jsonEncode(factsRes));
      debugPrint('Synced ${factsRes.length} perks facts');

      final storiesRes = await _supabase.from('perks_regret_stories').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyPerksRegretStories, jsonEncode(storiesRes));
      debugPrint('Synced ${storiesRes.length} perks regret stories');
    } catch (e) {
      debugPrint('Failed to sync military perks: $e');
    }
  }

  List<Map<String, dynamic>> getPerksFacts() {
    final data = _prefs?.getString(_keyPerksFacts);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getPerksRegretStories() {
    final data = _prefs?.getString(_keyPerksRegretStories);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  // ============================================================
  // BRAIN SCIENCE SYNC
  // ============================================================

  Future<void> _syncBrainScience() async {
    try {
      final mythsRes = await _supabase.from('brain_myths').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBrainMyths, jsonEncode(mythsRes));
      debugPrint('Synced ${mythsRes.length} brain myths');

      final biasesRes = await _supabase.from('brain_biases').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBrainBiases, jsonEncode(biasesRes));

      final biasOptsRes = await _supabase.from('brain_bias_options').select().order('sort_order');
      await _prefs?.setString(_keyBrainBiasOptions, jsonEncode(biasOptsRes));

      final expsRes = await _supabase.from('brain_experiments').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyBrainExperiments, jsonEncode(expsRes));

      final stepsRes = await _supabase.from('brain_experiment_steps').select().order('sort_order');
      await _prefs?.setString(_keyBrainExperimentSteps, jsonEncode(stepsRes));

      debugPrint('Synced brain science content');
    } catch (e) {
      debugPrint('Failed to sync brain science: $e');
    }
  }

  List<Map<String, dynamic>> getBrainMyths() {
    final data = _prefs?.getString(_keyBrainMyths);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getBrainBiases() {
    final data = _prefs?.getString(_keyBrainBiases);
    if (data == null) return [];
    try {
      final biases = List<Map<String, dynamic>>.from(jsonDecode(data));
      final optsData = _prefs?.getString(_keyBrainBiasOptions);
      final opts = optsData != null ? List<Map<String, dynamic>>.from(jsonDecode(optsData)) : <Map<String, dynamic>>[];
      return biases.map((b) => {...b, 'options': opts.where((o) => o['bias_id'] == b['id']).toList()}).toList();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getBrainExperiments() {
    final data = _prefs?.getString(_keyBrainExperiments);
    if (data == null) return [];
    try {
      final exps = List<Map<String, dynamic>>.from(jsonDecode(data));
      final stepsData = _prefs?.getString(_keyBrainExperimentSteps);
      final steps = stepsData != null ? List<Map<String, dynamic>>.from(jsonDecode(stepsData)) : <Map<String, dynamic>>[];
      return exps.map((e) => {...e, 'steps': steps.where((s) => s['experiment_id'] == e['id']).toList()}).toList();
    } catch (e) { return []; }
  }

  // ============================================================
  // DONATIONS SYNC
  // ============================================================

  Future<void> _syncDonations() async {
    try {
      final impactsRes = await _supabase.from('donation_impacts').select().eq('is_active', true).order('sort_order');
      await _prefs?.setString(_keyDonationImpacts, jsonEncode(impactsRes));

      final settingsRes = await _supabase.from('donation_settings').select();
      await _prefs?.setString(_keyDonationSettings, jsonEncode(settingsRes));

      debugPrint('Synced donations content');
    } catch (e) {
      debugPrint('Failed to sync donations: $e');
    }
  }

  List<Map<String, dynamic>> getDonationImpacts() {
    final data = _prefs?.getString(_keyDonationImpacts);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  String getDonationSetting(String key, {String defaultValue = ''}) {
    final data = _prefs?.getString(_keyDonationSettings);
    if (data == null) return defaultValue;
    try {
      final settings = List<Map<String, dynamic>>.from(jsonDecode(data));
      final match = settings.firstWhere((s) => s['key'] == key, orElse: () => {});
      return (match['value'] as String?) ?? defaultValue;
    } catch (e) { return defaultValue; }
  }

  // ============================================================
  // LGBTQ+ SUPPORT SYNC
  // ============================================================

  Future<void> _syncLgbtqSupport() async {
    try {
      final timeline = await _supabase.from('lgbtq_timeline').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqTimeline, jsonEncode(timeline));

      final myths = await _supabase.from('lgbtq_myths').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqMyths, jsonEncode(myths));

      final terms = await _supabase.from('lgbtq_terms').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqTerms, jsonEncode(terms));

      final scenarios = await _supabase.from('lgbtq_ally_scenarios').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqAllyScenarios, jsonEncode(scenarios));

      final options = await _supabase.from('lgbtq_ally_options').select().order('option_index');
      await _prefs?.setString(_keyLgbtqAllyOptions, jsonEncode(options));

      final regions = await _supabase.from('lgbtq_deploy_regions').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqDeployRegions, jsonEncode(regions));

      final orgs = await _supabase.from('lgbtq_support_orgs').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqSupportOrgs, jsonEncode(orgs));

      final affirmations = await _supabase.from('lgbtq_affirmations').select().order('sort_order');
      await _prefs?.setString(_keyLgbtqAffirmations, jsonEncode(affirmations));

      debugPrint('Synced LGBTQ+ support content');
    } catch (e) {
      debugPrint('Failed to sync LGBTQ+ support: $e');
    }
  }

  List<Map<String, dynamic>> getLgbtqTimeline() {
    final data = _prefs?.getString(_keyLgbtqTimeline);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getLgbtqMyths() {
    final data = _prefs?.getString(_keyLgbtqMyths);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getLgbtqTerms() {
    final data = _prefs?.getString(_keyLgbtqTerms);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getLgbtqAllyScenarios() {
    final data = _prefs?.getString(_keyLgbtqAllyScenarios);
    if (data == null) return [];
    try {
      final scenarios = List<Map<String, dynamic>>.from(jsonDecode(data));
      final optsData = _prefs?.getString(_keyLgbtqAllyOptions);
      final opts = optsData != null ? List<Map<String, dynamic>>.from(jsonDecode(optsData)) : <Map<String, dynamic>>[];
      return scenarios.map((s) => {...s, 'options': opts.where((o) => o['scenario_id'] == s['id']).toList()}).toList();
    } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getLgbtqDeployRegions() {
    final data = _prefs?.getString(_keyLgbtqDeployRegions);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getLgbtqSupportOrgs() {
    final data = _prefs?.getString(_keyLgbtqSupportOrgs);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }

  List<Map<String, dynamic>> getLgbtqAffirmations() {
    final data = _prefs?.getString(_keyLgbtqAffirmations);
    if (data == null) return [];
    try { return List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (e) { return []; }
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class MissionObjective {
  final String id;
  final String text;
  final String category;
  final String objectiveType;

  MissionObjective({
    required this.id,
    required this.text,
    required this.category,
    required this.objectiveType,
  });

  factory MissionObjective.fromJson(Map<String, dynamic> json) => MissionObjective(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    category: json['category'] ?? '',
    objectiveType: json['objective_type'] ?? 'primary',
  );
}

class MoodReason {
  final String id;
  final String text;
  final String moodType;
  final String icon;

  MoodReason({
    required this.id,
    required this.text,
    required this.moodType,
    required this.icon,
  });

  factory MoodReason.fromJson(Map<String, dynamic> json) => MoodReason(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    moodType: json['mood_type'] ?? '',
    icon: json['icon'] ?? 'circle',
  );
}

class EnergyLevel {
  final String id;
  final String label;
  final String emoji;
  final String description;

  EnergyLevel({
    required this.id,
    required this.label,
    required this.emoji,
    required this.description,
  });

  factory EnergyLevel.fromJson(Map<String, dynamic> json) => EnergyLevel(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    emoji: json['emoji'] ?? '',
    description: json['description'] ?? '',
  );
}

class BriefOption {
  final String id;
  final String text;
  final String category;

  BriefOption({
    required this.id,
    required this.text,
    required this.category,
  });

  factory BriefOption.fromJson(Map<String, dynamic> json) => BriefOption(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    category: json['category'] ?? '',
  );
}

class MilitaryRole {
  final String id;
  final String title;
  final String branch;

  MilitaryRole({
    required this.id,
    required this.title,
    required this.branch,
  });

  factory MilitaryRole.fromJson(Map<String, dynamic> json) => MilitaryRole(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    branch: json['branch'] ?? '',
  );
}

class CivilianJob {
  final String id;
  final String title;
  final String description;
  final String salaryRange;
  final String growthOutlook;
  final List<String> keySkills;

  CivilianJob({
    required this.id,
    required this.title,
    required this.description,
    required this.salaryRange,
    required this.growthOutlook,
    this.keySkills = const [],
  });

  factory CivilianJob.fromJson(Map<String, dynamic> json) => CivilianJob(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    salaryRange: json['salary_range'] ?? '',
    growthOutlook: json['growth_outlook'] ?? '',
    keySkills: (json['key_skills'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class Feeling {
  final String id;
  final String name;
  final String emoji;
  final String color;

  Feeling({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });

  factory Feeling.fromJson(Map<String, dynamic> json) => Feeling(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    emoji: json['emoji'] ?? '',
    color: json['color'] ?? '#00D9C4',
  );
}

class CopingTool {
  final String id;
  final String feelingId;
  final String title;
  final String description;
  final String duration;

  CopingTool({
    required this.id,
    required this.feelingId,
    required this.title,
    required this.description,
    required this.duration,
  });

  factory CopingTool.fromJson(Map<String, dynamic> json) => CopingTool(
    id: json['id'] ?? '',
    feelingId: json['feeling_id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    duration: json['duration'] ?? '',
  );
}

class CareerPath {
  final String id;
  final String title;
  final String emoji;
  final String tagline;
  final String description;
  final String salaryRange;
  final List<String> skillsNeeded;

  CareerPath({
    required this.id,
    required this.title,
    required this.emoji,
    required this.tagline,
    required this.description,
    required this.salaryRange,
    this.skillsNeeded = const [],
  });

  factory CareerPath.fromJson(Map<String, dynamic> json) => CareerPath(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    emoji: json['emoji'] ?? '',
    tagline: json['tagline'] ?? '',
    description: json['description'] ?? '',
    salaryRange: json['salary_range'] ?? '',
    skillsNeeded: (json['skills_needed'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class LearningStyle {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> tips;

  LearningStyle({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.tips,
  });

  factory LearningStyle.fromJson(Map<String, dynamic> json) => LearningStyle(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    emoji: json['emoji'] ?? '',
    description: json['description'] ?? '',
    tips: (json['tips'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class StudyStrategy {
  final String id;
  final String name;
  final String description;
  final List<String> bestFor;

  StudyStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.bestFor,
  });

  factory StudyStrategy.fromJson(Map<String, dynamic> json) => StudyStrategy(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    bestFor: (json['best_for'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class ConfidenceAction {
  final String id;
  final String text;
  final String difficulty;

  ConfidenceAction({
    required this.id,
    required this.text,
    required this.difficulty,
  });

  factory ConfidenceAction.fromJson(Map<String, dynamic> json) => ConfidenceAction(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    difficulty: json['difficulty'] ?? 'easy',
  );
}

class InterestCategory {
  final String id;
  final String name;
  final String emoji;
  final String color;

  InterestCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });

  factory InterestCategory.fromJson(Map<String, dynamic> json) => InterestCategory(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    emoji: json['emoji'] ?? '',
    color: json['color'] ?? '#00D9C4',
  );
}

class InterestActivity {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String difficulty;
  final String duration;

  InterestActivity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
  });

  factory InterestActivity.fromJson(Map<String, dynamic> json) => InterestActivity(
    id: json['id'] ?? '',
    categoryId: json['category_id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    difficulty: json['difficulty'] ?? 'easy',
    duration: json['duration'] ?? '',
  );
}

class TipCategory {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String accentColor;
  final String targetAudience;

  TipCategory({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.targetAudience,
  });

  factory TipCategory.fromJson(Map<String, dynamic> json) => TipCategory(
    id: json['id'] ?? '',
    slug: json['slug'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    accentColor: json['accent_color'] ?? '#00D9C4',
    targetAudience: json['target_audience'] ?? 'all',
  );
}

class Tip {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final List<String> keyPoints;

  Tip({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.keyPoints,
  });

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
    id: json['id'] ?? '',
    categoryId: json['category_id'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    keyPoints: (json['key_points'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class Quiz {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String targetAudience;

  Quiz({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.targetAudience,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    id: json['id'] ?? '',
    slug: json['slug'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    targetAudience: json['target_audience'] ?? 'all',
  );
}

class QuizQuestion {
  final String id;
  final String quizId;
  final String questionText;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionText,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] ?? '',
    quizId: json['quiz_id'] ?? '',
    questionText: json['question_text'] ?? '',
  );
}

class QuizOption {
  final String id;
  final String questionId;
  final String optionText;
  final String resultKey;

  QuizOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.resultKey,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    id: json['id'] ?? '',
    questionId: json['question_id'] ?? '',
    optionText: json['option_text'] ?? '',
    resultKey: json['result_key'] ?? '',
  );
}

class QuizResult {
  final String id;
  final String quizId;
  final String resultKey;
  final String title;
  final String emoji;
  final String description;
  final List<String> strengths;
  final List<String> growthAreas;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.resultKey,
    required this.title,
    required this.emoji,
    required this.description,
    required this.strengths,
    required this.growthAreas,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    id: json['id'] ?? '',
    quizId: json['quiz_id'] ?? '',
    resultKey: json['result_key'] ?? '',
    title: json['title'] ?? '',
    emoji: json['emoji'] ?? '',
    description: json['description'] ?? '',
    strengths: (json['strengths'] as List<dynamic>?)?.cast<String>() ?? [],
    growthAreas: (json['growth_areas'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

// ============================================================
// RESOURCE MODELS
// ============================================================

class ResourceCategory {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String targetAudience;

  ResourceCategory({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.targetAudience,
  });

  factory ResourceCategory.fromJson(Map<String, dynamic> json) => ResourceCategory(
    id: json['id'] ?? '',
    slug: json['slug'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    targetAudience: json['target_audience'] ?? 'all',
  );
}

class ResourceSection {
  final String id;
  final String categoryId;
  final String title;

  ResourceSection({
    required this.id,
    required this.categoryId,
    required this.title,
  });

  factory ResourceSection.fromJson(Map<String, dynamic> json) => ResourceSection(
    id: json['id'] ?? '',
    categoryId: json['category_id'] ?? '',
    title: json['title'] ?? '',
  );
}

class Resource {
  final String id;
  final String sectionId;
  final String name;
  final String description;
  final String? contact;
  final String? website;

  Resource({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.description,
    this.contact,
    this.website,
  });

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
    id: json['id'] ?? '',
    sectionId: json['section_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    contact: json['contact'],
    website: json['website'],
  );
}

// ============================================================
// CHECKLIST MODELS
// ============================================================

class ChecklistTemplate {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String targetAudience;

  ChecklistTemplate({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.targetAudience,
  });

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) => ChecklistTemplate(
    id: json['id'] ?? '',
    slug: json['slug'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    targetAudience: json['target_audience'] ?? 'all',
  );
}

class ChecklistSection {
  final String id;
  final String templateId;
  final String title;

  ChecklistSection({
    required this.id,
    required this.templateId,
    required this.title,
  });

  factory ChecklistSection.fromJson(Map<String, dynamic> json) => ChecklistSection(
    id: json['id'] ?? '',
    templateId: json['template_id'] ?? '',
    title: json['title'] ?? '',
  );
}

class ChecklistItem {
  final String id;
  final String sectionId;
  final String text;
  final String? description;

  ChecklistItem({
    required this.id,
    required this.sectionId,
    required this.text,
    this.description,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] ?? '',
    sectionId: json['section_id'] ?? '',
    text: json['text'] ?? '',
    description: json['description'],
  );
}

// ============================================================
// USER TYPE SCREEN MODELS
// ============================================================

class UserTypeScreen {
  final String id;
  final String slug;
  final String title;
  final String? subtitle;
  final String icon;

  UserTypeScreen({
    required this.id,
    required this.slug,
    required this.title,
    this.subtitle,
    required this.icon,
  });

  factory UserTypeScreen.fromJson(Map<String, dynamic> json) => UserTypeScreen(
    id: json['id'] ?? '',
    slug: json['slug'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'],
    icon: json['icon'] ?? 'person',
  );
}

class UserTypeSection {
  final String id;
  final String screenId;
  final String title;
  final String icon;

  UserTypeSection({
    required this.id,
    required this.screenId,
    required this.title,
    required this.icon,
  });

  factory UserTypeSection.fromJson(Map<String, dynamic> json) => UserTypeSection(
    id: json['id'] ?? '',
    screenId: json['screen_id'] ?? '',
    title: json['title'] ?? '',
    icon: json['icon'] ?? 'folder',
  );
}

class UserTypeItem {
  final String id;
  final String sectionId;
  final String title;
  final String? subtitle;
  final String icon;
  final String actionType;
  final String? actionData;

  UserTypeItem({
    required this.id,
    required this.sectionId,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.actionType,
    this.actionData,
  });

  factory UserTypeItem.fromJson(Map<String, dynamic> json) => UserTypeItem(
    id: json['id'] ?? '',
    sectionId: json['section_id'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'],
    icon: json['icon'] ?? 'arrow_forward',
    actionType: json['action_type'] ?? 'tip_cards',
    actionData: json['action_data'],
  );
}

// ============================================================
// HARASSMENT WIZARD MODELS
// ============================================================

class HarassmentWizardStep {
  final String id;
  final String title;
  final String subtitle;
  final int stepNumber;

  HarassmentWizardStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.stepNumber,
  });

  factory HarassmentWizardStep.fromJson(Map<String, dynamic> json) => HarassmentWizardStep(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    stepNumber: json['step_number'] ?? 0,
  );
}

class HarassmentWizardOption {
  final String id;
  final String stepId;
  final String text;
  final String? description;
  final String tag;

  HarassmentWizardOption({
    required this.id,
    required this.stepId,
    required this.text,
    this.description,
    required this.tag,
  });

  factory HarassmentWizardOption.fromJson(Map<String, dynamic> json) => HarassmentWizardOption(
    id: json['id'] ?? '',
    stepId: json['step_id'] ?? '',
    text: json['text'] ?? '',
    description: json['description'],
    tag: json['tag'] ?? '',
  );
}

class HarassmentGuidanceCard {
  final String id;
  final String title;
  final String message;
  final String guidanceType;
  final int priority;
  final List<String> matchTags;
  final bool isUniversal;

  HarassmentGuidanceCard({
    required this.id,
    required this.title,
    required this.message,
    required this.guidanceType,
    required this.priority,
    required this.matchTags,
    required this.isUniversal,
  });

  factory HarassmentGuidanceCard.fromJson(Map<String, dynamic> json) => HarassmentGuidanceCard(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    message: json['message'] ?? '',
    guidanceType: json['guidance_type'] ?? 'info',
    priority: json['priority'] ?? 0,
    matchTags: (json['match_tags'] as List<dynamic>?)?.cast<String>() ?? [],
    isUniversal: json['is_universal'] ?? false,
  );
}

class HarassmentContact {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? website;
  final String? availability;
  final bool isEmergency;

  HarassmentContact({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.website,
    this.availability,
    required this.isEmergency,
  });

  factory HarassmentContact.fromJson(Map<String, dynamic> json) => HarassmentContact(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    phone: json['phone'],
    website: json['website'],
    availability: json['availability'],
    isEmergency: json['is_emergency'] ?? false,
  );
}
