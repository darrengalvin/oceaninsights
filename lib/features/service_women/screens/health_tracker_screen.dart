import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Female Health Tracker — 100% local, tap-only, OPSEC safe
///
/// ZERO free-text input. Every interaction is tap/select.
/// ALL data stored locally on device via Hive. Nothing leaves the device.
/// No network calls. No Supabase. Completely private.
class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen>
    with TickerProviderStateMixin, TeaseMixin {
  late TabController _tabController;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Health Tracker');

  bool _gateExpand() {
    recordTeaseAction();
    return checkTeaseAndContinue();
  }
  late Box _healthBox;
  bool _isLoaded = false;

  // Period tracking state
  Set<DateTime> _periodDays = {};
  int _averageCycleLength = 28;

  // Symptom tracking state
  final Map<String, Set<String>> _symptomsByDate = {};

  // Contraception state
  String? _selectedMethod;
  bool _reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _healthBox = await Hive.openBox('health_tracker');

    // Load period days
    final savedDays = _healthBox.get('period_days', defaultValue: <String>[]);
    _periodDays = (savedDays as List)
        .map((s) => DateTime.parse(s as String))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    // Load average cycle length
    _averageCycleLength = _healthBox.get('avg_cycle_length', defaultValue: 28);

    // Load symptoms
    final savedSymptoms = _healthBox.get('symptoms', defaultValue: <String, List<String>>{});
    if (savedSymptoms is Map) {
      for (final entry in savedSymptoms.entries) {
        final key = entry.key as String;
        final value = entry.value;
        if (value is List) {
          _symptomsByDate[key] = value.cast<String>().toSet();
        }
      }
    }

    // Load contraception
    _selectedMethod = _healthBox.get('contraception_method');
    _reminderEnabled = _healthBox.get('contraception_reminder', defaultValue: false);

    setState(() => _isLoaded = true);
  }

  Future<void> _saveData() async {
    // Save period days as ISO strings
    await _healthBox.put(
      'period_days',
      _periodDays.map((d) => d.toIso8601String()).toList(),
    );
    await _healthBox.put('avg_cycle_length', _averageCycleLength);

    // Save symptoms
    final symptomsMap = <String, List<String>>{};
    for (final entry in _symptomsByDate.entries) {
      symptomsMap[entry.key] = entry.value.toList();
    }
    await _healthBox.put('symptoms', symptomsMap);

    // Save contraception
    await _healthBox.put('contraception_method', _selectedMethod);
    await _healthBox.put('contraception_reminder', _reminderEnabled);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Period helpers ────────────────────────────────────────

  DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

  void _togglePeriodDay(DateTime day) {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    final norm = _normalise(day);
    setState(() {
      if (_periodDays.contains(norm)) {
        _periodDays.remove(norm);
      } else {
        _periodDays.add(norm);
      }
    });
    _recalculateCycle();
    _saveData();
  }

  void _recalculateCycle() {
    if (_periodDays.length < 2) return;

    final sorted = _periodDays.toList()..sort();

    // Find period start dates (a day where previous day is NOT a period day)
    final starts = <DateTime>[];
    for (int i = 0; i < sorted.length; i++) {
      final prev = sorted[i].subtract(const Duration(days: 1));
      final prevNorm = _normalise(prev);
      if (!_periodDays.contains(prevNorm)) {
        starts.add(sorted[i]);
      }
    }

    if (starts.length >= 2) {
      int totalDays = 0;
      for (int i = 1; i < starts.length; i++) {
        totalDays += starts[i].difference(starts[i - 1]).inDays;
      }
      _averageCycleLength = (totalDays / (starts.length - 1)).round();
      if (_averageCycleLength < 18) _averageCycleLength = 18;
      if (_averageCycleLength > 45) _averageCycleLength = 45;
    }
  }

  DateTime? get _predictedNextPeriod {
    if (_periodDays.isEmpty) return null;
    final sorted = _periodDays.toList()..sort();

    // Find the last period start
    DateTime? lastStart;
    for (int i = sorted.length - 1; i >= 0; i--) {
      final prev = sorted[i].subtract(const Duration(days: 1));
      if (!_periodDays.contains(_normalise(prev))) {
        lastStart = sorted[i];
        break;
      }
    }

    if (lastStart == null) return null;
    return lastStart.add(Duration(days: _averageCycleLength));
  }

  int? get _daysUntilNextPeriod {
    final next = _predictedNextPeriod;
    if (next == null) return null;
    final now = _normalise(DateTime.now());
    return next.difference(now).inDays;
  }

  // ── Symptom helpers ────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Set<String> _symptomsForDate(DateTime d) =>
      _symptomsByDate[_dateKey(d)] ?? {};

  void _toggleSymptom(DateTime date, String symptom) {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    final key = _dateKey(date);
    setState(() {
      final current = _symptomsByDate[key] ?? {};
      if (current.contains(symptom)) {
        current.remove(symptom);
      } else {
        current.add(symptom);
      }
      if (current.isEmpty) {
        _symptomsByDate.remove(key);
      } else {
        _symptomsByDate[key] = current;
      }
    });
    _saveData();
  }

  // ── Contraception helper ────────────────────────────────────

  void _selectContraception(String method) {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    setState(() {
      _selectedMethod = (_selectedMethod == method) ? null : method;
    });
    _saveData();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    if (!_isLoaded) {
      return Scaffold(
        backgroundColor: colours.background,
        body: Center(
          child: CircularProgressIndicator(color: colours.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Health Tracker',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFE879A0),
          labelColor: colours.textBright,
          unselectedLabelColor: colours.textMuted,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Period'),
            Tab(text: 'Symptoms'),
            Tab(text: 'Contraception'),
            Tab(text: 'Pregnancy'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Privacy banner
          _buildPrivacyBanner(colours),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPeriodTab(colours),
                _buildSymptomsTab(colours),
                _buildContraceptionTab(colours),
                _buildPregnancyTab(colours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Privacy banner ────────────────────────────────────────

  Widget _buildPrivacyBanner(AppColours colours) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1A1A2E),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: colours.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'All data stored locally on this device only. Nothing is transmitted.',
              style: TextStyle(color: colours.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: PERIOD TRACKER
  // ============================================================

  Widget _buildPeriodTab(AppColours colours) {
    final now = DateTime.now();
    return _PeriodCalendarView(
      currentMonth: now,
      periodDays: _periodDays,
      averageCycleLength: _averageCycleLength,
      predictedNextPeriod: _predictedNextPeriod,
      daysUntilNext: _daysUntilNextPeriod,
      onToggleDay: _togglePeriodDay,
      colours: colours,
    );
  }

  // ============================================================
  // TAB 2: SYMPTOM LOGGER
  // ============================================================

  Widget _buildSymptomsTab(AppColours colours) {
    final today = _normalise(DateTime.now());
    final todaySymptoms = _symptomsForDate(today);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Symptoms',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to toggle — track how you feel each day',
                  style: TextStyle(color: colours.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Physical symptoms
          _buildSymptomCategory(
            colours,
            'Physical',
            Icons.accessibility_new_rounded,
            const Color(0xFFE879A0),
            [
              _SymptomChip('Cramps', '😣', todaySymptoms.contains('cramps'), () => _toggleSymptom(today, 'cramps')),
              _SymptomChip('Headache', '🤕', todaySymptoms.contains('headache'), () => _toggleSymptom(today, 'headache')),
              _SymptomChip('Back Pain', '😩', todaySymptoms.contains('back_pain'), () => _toggleSymptom(today, 'back_pain')),
              _SymptomChip('Bloating', '🫧', todaySymptoms.contains('bloating'), () => _toggleSymptom(today, 'bloating')),
              _SymptomChip('Fatigue', '😴', todaySymptoms.contains('fatigue'), () => _toggleSymptom(today, 'fatigue')),
              _SymptomChip('Breast Pain', '⚡', todaySymptoms.contains('breast_pain'), () => _toggleSymptom(today, 'breast_pain')),
              _SymptomChip('Nausea', '🤢', todaySymptoms.contains('nausea'), () => _toggleSymptom(today, 'nausea')),
              _SymptomChip('Dizziness', '💫', todaySymptoms.contains('dizziness'), () => _toggleSymptom(today, 'dizziness')),
            ],
          ),
          const SizedBox(height: 20),

          // Mood symptoms
          _buildSymptomCategory(
            colours,
            'Mood & Energy',
            Icons.psychology_rounded,
            const Color(0xFF818CF8),
            [
              _SymptomChip('Mood Swings', '🎭', todaySymptoms.contains('mood_swings'), () => _toggleSymptom(today, 'mood_swings')),
              _SymptomChip('Irritable', '😤', todaySymptoms.contains('irritable'), () => _toggleSymptom(today, 'irritable')),
              _SymptomChip('Anxious', '😰', todaySymptoms.contains('anxious'), () => _toggleSymptom(today, 'anxious')),
              _SymptomChip('Low Mood', '😔', todaySymptoms.contains('low_mood'), () => _toggleSymptom(today, 'low_mood')),
              _SymptomChip('Emotional', '🥺', todaySymptoms.contains('emotional'), () => _toggleSymptom(today, 'emotional')),
              _SymptomChip('Low Energy', '🔋', todaySymptoms.contains('low_energy'), () => _toggleSymptom(today, 'low_energy')),
              _SymptomChip('Difficulty Sleeping', '🌙', todaySymptoms.contains('sleep_difficulty'), () => _toggleSymptom(today, 'sleep_difficulty')),
            ],
          ),
          const SizedBox(height: 20),

          // Flow
          _buildSymptomCategory(
            colours,
            'Flow',
            Icons.water_drop_rounded,
            const Color(0xFFF472B6),
            [
              _SymptomChip('Spotting', '🩸', todaySymptoms.contains('flow_spotting'), () => _toggleSymptom(today, 'flow_spotting')),
              _SymptomChip('Light', '💧', todaySymptoms.contains('flow_light'), () => _toggleSymptom(today, 'flow_light')),
              _SymptomChip('Medium', '💧💧', todaySymptoms.contains('flow_medium'), () => _toggleSymptom(today, 'flow_medium')),
              _SymptomChip('Heavy', '💧💧💧', todaySymptoms.contains('flow_heavy'), () => _toggleSymptom(today, 'flow_heavy')),
            ],
          ),
          const SizedBox(height: 20),

          // Other
          _buildSymptomCategory(
            colours,
            'Other',
            Icons.more_horiz_rounded,
            const Color(0xFF60A5FA),
            [
              _SymptomChip('Acne', '✨', todaySymptoms.contains('acne'), () => _toggleSymptom(today, 'acne')),
              _SymptomChip('Cravings', '🍫', todaySymptoms.contains('cravings'), () => _toggleSymptom(today, 'cravings')),
              _SymptomChip('Hot Flushes', '🔥', todaySymptoms.contains('hot_flushes'), () => _toggleSymptom(today, 'hot_flushes')),
              _SymptomChip('Exercise Difficult', '🏃‍♀️', todaySymptoms.contains('exercise_hard'), () => _toggleSymptom(today, 'exercise_hard')),
            ],
          ),
          const SizedBox(height: 24),

          // Recent history
          _buildSymptomHistory(colours),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSymptomCategory(
    AppColours colours,
    String title,
    IconData icon,
    Color categoryColour,
    List<_SymptomChip> chips,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: categoryColour, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: colours.textBright,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((chip) {
            return GestureDetector(
              onTap: chip.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: chip.selected
                      ? categoryColour.withValues(alpha: 0.2)
                      : colours.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: chip.selected ? categoryColour : colours.border,
                    width: chip.selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(chip.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      chip.label,
                      style: TextStyle(
                        color: chip.selected ? colours.textBright : colours.textLight,
                        fontSize: 13,
                        fontWeight: chip.selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomHistory(AppColours colours) {
    final today = _normalise(DateTime.now());
    // Show last 7 days
    final days = List.generate(7, (i) => today.subtract(Duration(days: i)));

    final hasAnyData = days.any((d) => _symptomsForDate(d).isNotEmpty);
    if (!hasAnyData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border),
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, color: colours.textMuted, size: 32),
            const SizedBox(height: 8),
            Text(
              'Your symptom history will appear here',
              style: TextStyle(color: colours.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent History',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...days.where((d) => _symptomsForDate(d).isNotEmpty).map((d) {
          final symptoms = _symptomsForDate(d);
          final isToday = d == today;
          final dayLabel = isToday
              ? 'Today'
              : d == today.subtract(const Duration(days: 1))
                  ? 'Yesterday'
                  : '${d.day}/${d.month}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: isToday ? const Color(0xFFE879A0) : colours.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: symptoms.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colours.cardLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _symptomLabel(s),
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _symptomLabel(String key) {
    const labels = {
      'cramps': 'Cramps',
      'headache': 'Headache',
      'back_pain': 'Back Pain',
      'bloating': 'Bloating',
      'fatigue': 'Fatigue',
      'breast_pain': 'Breast Pain',
      'nausea': 'Nausea',
      'dizziness': 'Dizziness',
      'mood_swings': 'Mood Swings',
      'irritable': 'Irritable',
      'anxious': 'Anxious',
      'low_mood': 'Low Mood',
      'emotional': 'Emotional',
      'low_energy': 'Low Energy',
      'sleep_difficulty': 'Sleep Difficulty',
      'flow_spotting': 'Spotting',
      'flow_light': 'Light Flow',
      'flow_medium': 'Medium Flow',
      'flow_heavy': 'Heavy Flow',
      'acne': 'Acne',
      'cravings': 'Cravings',
      'hot_flushes': 'Hot Flushes',
      'exercise_hard': 'Exercise Difficult',
    };
    return labels[key] ?? key;
  }

  // ============================================================
  // TAB 3: CONTRACEPTION INFO
  // ============================================================

  Widget _buildContraceptionTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF818CF8).withValues(alpha: 0.15),
                  const Color(0xFFE879A0).withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF818CF8), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Educational Information',
                        style: TextStyle(
                          color: colours.textBright,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This is general educational information only. Always consult your Medical Officer or GP for personal medical advice.',
                  style: TextStyle(color: colours.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Tap a method to learn more',
            style: TextStyle(
              color: colours.textBright,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ..._contraceptionMethods.map((method) {
            final isSelected = _selectedMethod == method.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _selectContraception(method.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE879A0).withValues(alpha: 0.1)
                        : colours.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE879A0).withValues(alpha: 0.5)
                          : colours.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(method.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.name,
                                  style: TextStyle(
                                    color: colours.textBright,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  method.category,
                                  style: const TextStyle(
                                    color: Color(0xFFE879A0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: isSelected ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more_rounded,
                              color: colours.textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: colours.border,
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(colours, 'How it works', method.howItWorks),
                        const SizedBox(height: 10),
                        _buildInfoRow(colours, 'Effectiveness', method.effectiveness),
                        const SizedBox(height: 10),
                        _buildInfoRow(colours, 'Duration', method.duration),
                        const SizedBox(height: 10),
                        _buildInfoRow(colours, 'Service considerations', method.serviceNotes),
                        if (method.sideEffects.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Possible side effects',
                            style: TextStyle(
                              color: colours.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: method.sideEffects.map((e) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colours.cardLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color: colours.textLight,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(AppColours colours, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              color: colours.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: colours.textLight, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAB 4: PREGNANCY GUIDANCE
  // ============================================================

  Widget _buildPregnancyTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medical disclaimer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_information_rounded,
                    color: colours.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is general educational guidance. Always speak to your Medical Officer or GP for personal advice.',
                    style: TextStyle(color: colours.textLight, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ..._pregnancyTopics.map((topic) {
            return _buildExpandableCard(colours, topic);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExpandableCard(AppColours colours, _PregnancyTopic topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _ExpandableTile(
        colours: colours,
        icon: topic.icon,
        iconColour: topic.colour,
        title: topic.title,
        subtitle: topic.subtitle,
        content: topic.content,
        onExpandCheck: _gateExpand,
      ),
    );
  }
}

// ================================================================
// DATA MODELS
// ================================================================

class _SymptomChip {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  _SymptomChip(this.label, this.emoji, this.selected, this.onTap);
}

// ================================================================
// PERIOD CALENDAR VIEW (separate stateful widget for month nav)
// ================================================================

class _PeriodCalendarView extends StatefulWidget {
  final DateTime currentMonth;
  final Set<DateTime> periodDays;
  final int averageCycleLength;
  final DateTime? predictedNextPeriod;
  final int? daysUntilNext;
  final ValueChanged<DateTime> onToggleDay;
  final AppColours colours;

  const _PeriodCalendarView({
    required this.currentMonth,
    required this.periodDays,
    required this.averageCycleLength,
    required this.predictedNextPeriod,
    required this.daysUntilNext,
    required this.onToggleDay,
    required this.colours,
  });

  @override
  State<_PeriodCalendarView> createState() => _PeriodCalendarViewState();
}

class _PeriodCalendarViewState extends State<_PeriodCalendarView> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month);
  }

  void _previousMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colours = widget.colours;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Prediction summary card
          if (widget.daysUntilNext != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE879A0).withValues(alpha: 0.15),
                    const Color(0xFFF472B6).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE879A0).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE879A0).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.daysUntilNext}',
                        style: const TextStyle(
                          color: Color(0xFFE879A0),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.daysUntilNext! <= 0
                              ? 'Period may have started'
                              : widget.daysUntilNext! == 1
                                  ? 'Period expected tomorrow'
                                  : 'Days until next period',
                          style: TextStyle(
                            color: colours.textBright,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Average cycle: ${widget.averageCycleLength} days',
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Calendar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              children: [
                // Month navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: Icon(Icons.chevron_left_rounded,
                          color: colours.textLight),
                    ),
                    Text(
                      '${_monthName(_viewMonth.month)} ${_viewMonth.year}',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: Icon(Icons.chevron_right_rounded,
                          color: colours.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Day headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((d) => SizedBox(
                            width: 36,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colours.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Calendar grid
                ..._buildCalendarWeeks(colours, today),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap dates to mark period days',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _legendDot(const Color(0xFFE879A0)),
                    const SizedBox(width: 6),
                    Text('Period day',
                        style: TextStyle(
                            color: colours.textLight, fontSize: 12)),
                    const SizedBox(width: 16),
                    _legendDot(const Color(0xFFE879A0).withValues(alpha: 0.3)),
                    const SizedBox(width: 6),
                    Text('Predicted',
                        style: TextStyle(
                            color: colours.textLight, fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: colours.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Today',
                        style: TextStyle(
                            color: colours.textLight, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  List<Widget> _buildCalendarWeeks(AppColours colours, DateTime today) {
    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final lastDay = DateTime(_viewMonth.year, _viewMonth.month + 1, 0);

    // Monday = 1, so offset accordingly
    int startWeekday = firstDay.weekday; // 1=Mon ... 7=Sun
    int leadingBlanks = startWeekday - 1;

    final days = <DateTime?>[];

    // Leading blanks
    for (int i = 0; i < leadingBlanks; i++) {
      days.add(null);
    }

    // Actual days
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_viewMonth.year, _viewMonth.month, d));
    }

    // Trailing blanks to fill last week
    while (days.length % 7 != 0) {
      days.add(null);
    }

    final weeks = <Widget>[];
    for (int w = 0; w < days.length; w += 7) {
      final weekDays = days.sublist(w, w + 7);
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((d) {
              if (d == null) {
                return const SizedBox(width: 36, height: 36);
              }
              return _buildDayCell(colours, d, today);
            }).toList(),
          ),
        ),
      );
    }
    return weeks;
  }

  Widget _buildDayCell(AppColours colours, DateTime day, DateTime today) {
    final norm = DateTime(day.year, day.month, day.day);
    final isPeriod = widget.periodDays.contains(norm);
    final isToday = norm == today;
    final isFuture = norm.isAfter(today);

    // Check if this day falls in predicted window
    bool isPredicted = false;
    if (!isPeriod && widget.predictedNextPeriod != null) {
      final pred = widget.predictedNextPeriod!;
      final predEnd = pred.add(const Duration(days: 5));
      if (!norm.isBefore(pred) && norm.isBefore(predEnd)) {
        isPredicted = true;
      }
    }

    return GestureDetector(
      onTap: isFuture ? null : () => widget.onToggleDay(day),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isPeriod
              ? const Color(0xFFE879A0)
              : isPredicted
                  ? const Color(0xFFE879A0).withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: colours.accent, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isPeriod
                  ? Colors.white
                  : isFuture
                      ? colours.textMuted.withValues(alpha: 0.4)
                      : colours.textLight,
              fontSize: 13,
              fontWeight: isPeriod || isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }
}

// ================================================================
// EXPANDABLE TILE (for pregnancy guidance)
// ================================================================

class _ExpandableTile extends StatefulWidget {
  final AppColours colours;
  final IconData icon;
  final Color iconColour;
  final String title;
  final String subtitle;
  final String content;
  final bool Function()? onExpandCheck;

  const _ExpandableTile({
    required this.colours,
    required this.icon,
    required this.iconColour,
    required this.title,
    required this.subtitle,
    required this.content,
    this.onExpandCheck,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        if (!_expanded && widget.onExpandCheck != null) {
          if (!widget.onExpandCheck!()) return;
        }
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _expanded
              ? widget.iconColour.withValues(alpha: 0.08)
              : widget.colours.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? widget.iconColour.withValues(alpha: 0.3)
                : widget.colours.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.iconColour, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.colours.textBright,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: widget.colours.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: widget.colours.textMuted,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 1,
                color: widget.colours.border,
              ),
              const SizedBox(height: 14),
              Text(
                widget.content,
                style: TextStyle(
                  color: widget.colours.textLight,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STATIC DATA — Contraception methods
// ================================================================

class _ContraceptionMethod {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String howItWorks;
  final String effectiveness;
  final String duration;
  final String serviceNotes;
  final List<String> sideEffects;

  const _ContraceptionMethod({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.howItWorks,
    required this.effectiveness,
    required this.duration,
    required this.serviceNotes,
    required this.sideEffects,
  });
}

const _contraceptionMethods = [
  _ContraceptionMethod(
    id: 'implant',
    name: 'Contraceptive Implant',
    emoji: '💪',
    category: 'Long-Acting Reversible (LARC)',
    howItWorks:
        'A small flexible rod inserted under the skin of your upper arm. It releases progestogen to prevent pregnancy.',
    effectiveness: 'Over 99% effective',
    duration: 'Lasts up to 3 years',
    serviceNotes:
        'Very popular in the military — fit and forget. No daily routine needed. Your Medical Officer can arrange fitting. Works well with deployments as nothing to carry or remember.',
    sideEffects: [
      'Irregular periods',
      'Periods may stop',
      'Mood changes',
      'Skin changes',
      'Headaches',
    ],
  ),
  _ContraceptionMethod(
    id: 'iud_hormonal',
    name: 'Hormonal IUD (Coil)',
    emoji: '🔄',
    category: 'Long-Acting Reversible (LARC)',
    howItWorks:
        'A small T-shaped device placed in the womb. Releases progestogen locally to prevent pregnancy.',
    effectiveness: 'Over 99% effective',
    duration: 'Lasts 3–5 years depending on type',
    serviceNotes:
        'Another fit-and-forget option. Can reduce heavy periods, which is helpful during field exercises. Fitted by a trained doctor — speak to your Medical Officer.',
    sideEffects: [
      'Lighter periods or no periods',
      'Spotting in first 6 months',
      'Cramps after fitting',
      'Mood changes',
    ],
  ),
  _ContraceptionMethod(
    id: 'iud_copper',
    name: 'Copper IUD (Coil)',
    emoji: '🛡️',
    category: 'Long-Acting Reversible (LARC)',
    howItWorks:
        'A small T-shaped device with copper, placed in the womb. The copper prevents sperm from surviving.',
    effectiveness: 'Over 99% effective',
    duration: 'Lasts 5–10 years',
    serviceNotes:
        'Hormone-free option — good if you prefer to avoid hormonal methods. Can also be used as emergency contraception if fitted within 5 days.',
    sideEffects: [
      'Heavier periods',
      'More painful periods',
      'Spotting between periods',
    ],
  ),
  _ContraceptionMethod(
    id: 'injection',
    name: 'Contraceptive Injection',
    emoji: '💉',
    category: 'Short-Acting',
    howItWorks:
        'An injection of progestogen given every 8–13 weeks (depending on type). Prevents ovulation.',
    effectiveness: 'Over 99% when given on time',
    duration: 'Repeat every 8–13 weeks',
    serviceNotes:
        'Good option if you prefer not to have a device fitted. Can be given by your Medical Officer. Plan appointments around deployments — you\'ll need rebooking every few months.',
    sideEffects: [
      'Weight gain',
      'Irregular bleeding',
      'Periods may stop',
      'Delayed return to fertility',
      'Mood changes',
    ],
  ),
  _ContraceptionMethod(
    id: 'pill_combined',
    name: 'Combined Pill',
    emoji: '💊',
    category: 'Short-Acting',
    howItWorks:
        'A daily pill containing oestrogen and progestogen. Prevents ovulation when taken correctly.',
    effectiveness: 'Over 99% with perfect use; ~91% with typical use',
    duration: 'Taken daily (21 days on, 7 days off or continuous)',
    serviceNotes:
        'Requires daily discipline — suits some service personnel well. Must carry supply on deployments. Some environments (heat, humidity) may affect storage. Speak to your Medical Officer about supply for exercises.',
    sideEffects: [
      'Nausea',
      'Headaches',
      'Breast tenderness',
      'Mood changes',
      'Blood clot risk (small)',
    ],
  ),
  _ContraceptionMethod(
    id: 'pill_mini',
    name: 'Progestogen-Only Pill (Mini Pill)',
    emoji: '💊',
    category: 'Short-Acting',
    howItWorks:
        'A daily pill containing only progestogen. Thickens cervical mucus and may prevent ovulation.',
    effectiveness: 'Over 99% with perfect use; ~91% with typical use',
    duration: 'Taken daily with no break',
    serviceNotes:
        'Must be taken at the same time every day (or within a 3-12 hour window depending on type). Requires planning around operational duties.',
    sideEffects: [
      'Irregular periods',
      'Spotting',
      'Breast tenderness',
      'Mood changes',
    ],
  ),
  _ContraceptionMethod(
    id: 'patch',
    name: 'Contraceptive Patch',
    emoji: '🩹',
    category: 'Short-Acting',
    howItWorks:
        'A small adhesive patch worn on the skin. Releases oestrogen and progestogen through the skin.',
    effectiveness: 'Over 99% with perfect use; ~91% with typical use',
    duration: 'Changed weekly (3 weeks on, 1 week off)',
    serviceNotes:
        'May become loose during heavy physical activity or in hot climates. Check it regularly. Some units may have uniform/dress concerns — can be placed on areas covered by clothing.',
    sideEffects: [
      'Skin irritation',
      'Headaches',
      'Nausea',
      'Breast tenderness',
      'Blood clot risk (small)',
    ],
  ),
  _ContraceptionMethod(
    id: 'condoms',
    name: 'Condoms (Male & Female)',
    emoji: '🛡️',
    category: 'Barrier Method',
    howItWorks:
        'Physical barrier that prevents sperm from reaching the egg. Also protects against sexually transmitted infections (STIs).',
    effectiveness: '98% (male) / 95% (female) with perfect use; ~82-87% typical',
    duration: 'Single use',
    serviceNotes:
        'The ONLY method that also protects against STIs. Important to use alongside other methods, especially with new partners. Available free from medical centres on base.',
    sideEffects: [
      'Latex allergy (alternatives available)',
    ],
  ),
  _ContraceptionMethod(
    id: 'emergency',
    name: 'Emergency Contraception',
    emoji: '🚨',
    category: 'Emergency',
    howItWorks:
        'Emergency pill (up to 3–5 days after unprotected sex) or copper IUD (up to 5 days). Delays or prevents ovulation.',
    effectiveness:
        'More effective the sooner it is taken. Copper IUD is most effective (99%+)',
    duration: 'One-off use',
    serviceNotes:
        'Available from medical centres, pharmacies, and some medical officers in the field. Do not wait — the sooner the better. No judgement from medical staff.',
    sideEffects: [
      'Nausea',
      'Headache',
      'Irregular next period',
      'Abdominal pain',
    ],
  ),
];

// ================================================================
// STATIC DATA — Pregnancy guidance topics
// ================================================================

class _PregnancyTopic {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final Color colour;

  const _PregnancyTopic({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.colour,
  });
}

const _pregnancyTopics = [
  _PregnancyTopic(
    title: 'Early Signs of Pregnancy',
    subtitle: 'What to look out for',
    icon: Icons.visibility_rounded,
    colour: Color(0xFFF472B6),
    content:
        'Common early signs include:\n\n'
        '• Missed period — the most common first sign\n'
        '• Feeling sick or nauseous (morning sickness can happen any time of day)\n'
        '• Unusual tiredness or fatigue\n'
        '• Breast tenderness or changes\n'
        '• Needing to wee more often\n'
        '• Changes in taste or smell\n'
        '• Light spotting (implantation bleeding)\n\n'
        'If you suspect you may be pregnant, speak to your Medical Officer as soon as possible. This is completely confidential.',
  ),
  _PregnancyTopic(
    title: 'Telling Your Chain of Command',
    subtitle: 'Your rights and the process',
    icon: Icons.groups_rounded,
    colour: Color(0xFF818CF8),
    content:
        'You are not required to announce pregnancy publicly. Here\'s how the process typically works:\n\n'
        '• Confirm pregnancy through your Medical Officer (confidential)\n'
        '• Your MO will conduct a risk assessment for your role\n'
        '• You will need to inform your line manager — your MO can support you with this\n'
        '• A workplace risk assessment will be carried out\n'
        '• Duties may be adjusted to remove physical risks\n'
        '• You are protected from discrimination under service and civilian law\n\n'
        'You cannot be discharged or disadvantaged because of pregnancy. If you feel pressured, speak to your unit welfare officer or the Service Complaints process.',
  ),
  _PregnancyTopic(
    title: 'Maternity Leave & Entitlements',
    subtitle: 'What you are entitled to',
    icon: Icons.calendar_month_rounded,
    colour: Color(0xFF60A5FA),
    content:
        'Service personnel are entitled to maternity provisions:\n\n'
        '• Up to 52 weeks maternity leave (26 ordinary + 26 additional)\n'
        '• Maternity pay — similar to civilian statutory maternity pay\n'
        '• Right to return to your role or equivalent\n'
        '• Shared Parental Leave may also be available\n'
        '• Partner may be entitled to paternity leave\n\n'
        'Specific entitlements vary by service branch and may be updated. Speak to your unit HR / admin office for the latest policy, or check the relevant Joint Service Publication (JSP).',
  ),
  _PregnancyTopic(
    title: 'Physical Training During Pregnancy',
    subtitle: 'Staying active safely',
    icon: Icons.fitness_center_rounded,
    colour: Color(0xFF34D399),
    content:
        'Staying active during pregnancy is generally encouraged, but with adjustments:\n\n'
        '• You will be exempt from standard fitness tests during pregnancy\n'
        '• Low-impact exercise (walking, swimming, yoga) is usually safe\n'
        '• Avoid contact sports, heavy lifting, and high-impact activities\n'
        '• Stop immediately if you experience pain, dizziness, or bleeding\n'
        '• Your MO will provide specific guidance based on your role and stage of pregnancy\n\n'
        'After birth, there is a graduated return to fitness. You won\'t be expected to pass fitness tests immediately. Your MO will set a realistic timeline.',
  ),
  _PregnancyTopic(
    title: 'Deploying While Pregnant',
    subtitle: 'Operational restrictions',
    icon: Icons.flight_rounded,
    colour: Color(0xFFF59E0B),
    content:
        'Once pregnancy is confirmed:\n\n'
        '• You will not be deployed to operational theatres\n'
        '• Travel restrictions apply — especially after 28 weeks (air travel)\n'
        '• You may continue in your normal role with adjustments, depending on the risk assessment\n'
        '• Desk-based or rear-party duties are typical\n'
        '• If you discover you are pregnant while deployed, inform your MO immediately for safe extraction planning\n\n'
        'Your safety and the baby\'s safety are the priority. No one should pressure you to hide pregnancy to maintain deployment.',
  ),
  _PregnancyTopic(
    title: 'Returning to Service After Birth',
    subtitle: 'Planning your return',
    icon: Icons.replay_rounded,
    colour: Color(0xFFA78BFA),
    content:
        'Planning your return:\n\n'
        '• You have the right to return to your role or an equivalent position\n'
        '• Graduated return to physical fitness — no rush\n'
        '• Childcare support may be available — check your service\'s family support\n'
        '• Breastfeeding arrangements — your unit should provide private space and time\n'
        '• Mental health support is available if you experience postnatal depression or anxiety\n'
        '• Flexible working arrangements may be possible depending on your role\n\n'
        'Many service women successfully balance military careers with parenthood. Speak to other service mothers and your welfare team for practical advice.',
  ),
  _PregnancyTopic(
    title: 'Pregnancy Loss & Support',
    subtitle: 'You are not alone',
    icon: Icons.favorite_rounded,
    colour: Color(0xFFE879A0),
    content:
        'Pregnancy loss (miscarriage, stillbirth, or ectopic pregnancy) is more common than many people realise. You are not alone.\n\n'
        '• Seek immediate medical help if you experience heavy bleeding, severe pain, or feel unwell\n'
        '• Your Medical Officer is there to support you — this is confidential\n'
        '• You are entitled to compassionate leave\n'
        '• Counselling support is available through military mental health services\n'
        '• Your chain of command should be supportive — if they are not, speak to your welfare officer\n'
        '• Partners also need support — they can access help too\n\n'
        'There is no "right way" to grieve. Take the time you need. You can also reach out to charities like Tommy\'s and the Miscarriage Association for additional support.',
  ),
];
