import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../../scenarios/screens/scenario_library_screen.dart';
import '../../scenarios/screens/protocol_library_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../settings/screens/contact_help_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../widgets/daily_brief_widget.dart';
import '../widgets/after_action_review_widget.dart';
import '../widgets/skills_translator_widget.dart';
import '../widgets/mission_planner_widget.dart';
import '../widgets/tip_cards_screen.dart';
import '../widgets/checklist_screen.dart';
import '../widgets/resource_list_screen.dart';

// Track items viewed for tease gating
int _militaryItemsViewed = 0;
const int _freeItemLimit = 2; // Allow first 2 items free

/// Military support screen with service mode tabs
class MilitaryScreen extends StatefulWidget {
  const MilitaryScreen({super.key});

  @override
  State<MilitaryScreen> createState() => _MilitaryScreenState();
}

class _MilitaryScreenState extends State<MilitaryScreen> {
  int _selectedModeIndex = 0;
  
  final List<String> _serviceModes = [
    'Active Duty',
    'Reserve',
    'Transitioning',
    'Recently Discharged',
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.military_tech_rounded,
                color: colours.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Military',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildServiceModeTabs(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildContentForMode(_selectedModeIndex),
            ),
          ),
          _buildQuickExitButton(context),
        ],
      ),
    );
  }
  
  Widget _buildServiceModeTabs(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Mode:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colours.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_serviceModes.length, (index) {
                final isSelected = _selectedModeIndex == index;
                return Padding(
                  padding: EdgeInsets.only(right: index < _serviceModes.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedModeIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colours.accent : colours.cardLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? colours.accent : colours.border,
                        ),
                      ),
                      child: Text(
                        _serviceModes[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : colours.textBright,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentForMode(int modeIndex) {
    switch (modeIndex) {
      case 0:
        return _buildActiveDutyContent();
      case 1:
        return _buildReserveContent();
      case 2:
        return _buildTransitioningContent();
      case 3:
        return _buildRecentlyDischargedContent();
      default:
        return _buildActiveDutyContent();
    }
  }
  
  Widget _buildActiveDutyContent() {
    return Column(
      children: [
        _MilitarySection(
          icon: Icons.assignment_outlined,
          title: 'Daily Ops & Structure',
          items: [
            _MilitaryItem(
              title: 'Daily Brief',
              subtitle: 'Short prompt for mission focus',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyBriefScreen(userType: 'military')),
              ),
            ),
            _MilitaryItem(
              title: 'Mission Planner',
              subtitle: 'Plan the day: Primary / Secondary / Contingency',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MissionPlannerScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'After Action Review',
              subtitle: "Quick debrief: What worked? What didn't?",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AfterActionReviewScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.psychology_outlined,
          title: 'Mental Readiness',
          items: [
            _MilitaryItem(
              title: 'Stress Reset Drills',
              subtitle: 'Quick mental reset routines',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BreathingScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Shift & Sleep Support',
              subtitle: 'Adjust to night, rotations, shift work',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Shift & Sleep Support',
                  subtitle: 'Manage irregular schedules and get better rest',
                  icon: Icons.bedtime_outlined,
                  tips: const [
                    TipCard(title: 'Before Night Shift', content: 'Prepare your body for the switch. Nap before your shift if possible, eat a light meal, and avoid caffeine close to when you need to sleep.', keyPoints: ['Nap 90 minutes before shift', 'Light meal, not heavy', 'Caffeine only early in shift']),
                    TipCard(title: 'During Night Shift', content: 'Stay alert with bright light exposure. Take short walks, stay hydrated, and save caffeine for the first half of your shift.', keyPoints: ['Bright lights help alertness', 'Move every hour', 'Hydrate frequently']),
                    TipCard(title: 'After Night Shift', content: 'Wind down properly. Wear sunglasses on the way home, avoid screens, and create a dark, cool sleeping environment.', keyPoints: ['Sunglasses block wake signals', 'Blackout curtains essential', 'Keep room cool: 65-68°F']),
                    TipCard(title: 'Rotating Schedules', content: 'Give your body time to adjust. Stick to consistent meal times, exercise regularly, and protect your sleep windows.', keyPoints: ['Meals anchor your rhythm', 'Exercise but not before sleep', 'Prioritize sleep above all']),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Focus Under Pressure',
              subtitle: 'Mindset drills for performance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Focus Under Pressure',
                  subtitle: 'Perform when it matters most',
                  icon: Icons.psychology_outlined,
                  tips: const [
                    TipCard(title: 'Box Breathing', content: 'Inhale 4 seconds, hold 4 seconds, exhale 4 seconds, hold 4 seconds. Repeat 4 times. This activates your calm response.', keyPoints: ['Used by Navy SEALs', 'Lowers heart rate', 'Clears mental fog']),
                    TipCard(title: 'The 5-Second Rule', content: 'When you hesitate, count 5-4-3-2-1 and move. Don\'t give your brain time to talk you out of action.', keyPoints: ['Interrupt hesitation', 'Create forward momentum', 'Works for any decision']),
                    TipCard(title: 'Visualization', content: 'Before high-pressure situations, mentally rehearse success. See yourself performing calmly and confidently.', keyPoints: ['Picture each step clearly', 'Include the feeling of success', 'Do this daily for key tasks']),
                    TipCard(title: 'Focus Cue', content: 'Choose a physical trigger - touching your thumb to finger, deep breath - to activate focus. Practice linking it to calm, clear thinking.', keyPoints: ['Pick a simple gesture', 'Practice in calm moments', 'Use before high-stakes moments']),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Tactical Mindset Drills',
              subtitle: 'Mental preparation techniques',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Tactical Mindset',
                  subtitle: 'Mental edge for operational readiness',
                  icon: Icons.shield_outlined,
                  tips: const [
                    TipCard(title: 'Situational Awareness', content: 'Stay alert without being paranoid. Regularly scan your environment. Know exits, notice changes, trust your instincts.', keyPoints: ['Know your exits', 'Notice what\'s normal', 'Trust gut feelings']),
                    TipCard(title: 'Pre-Mission Mindset', content: 'Before any operation, run through your role mentally. Visualize contingencies. Accept uncertainty.', keyPoints: ['Mental rehearsal', 'Plan for problems', 'Accept what you can\'t control']),
                    TipCard(title: 'Recovery After Ops', content: 'Debrief mentally. What went well? What would you do differently? Then let it go - dwelling doesn\'t help.', keyPoints: ['Learn from each experience', 'Don\'t ruminate', 'Move forward']),
                    TipCard(title: 'Maintaining Edge', content: 'Stay sharp through regular training, physical fitness, and mental challenges. Complacency is the enemy.', keyPoints: ['Train consistently', 'Challenge yourself', 'Stay humble']),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.groups_outlined,
          title: 'Leadership & Team Skills',
          items: [
            _MilitaryItem(
              title: 'Situational Leadership',
              subtitle: 'Scenarios to practice tactical leadership',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScenarioLibraryScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Difficult Conversations',
              subtitle: 'Exercise rank-appropriate talks',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProtocolLibraryScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.work_outline,
          title: 'Transition & Career Support',
          items: [
            _MilitaryItem(
              title: 'Civilian Skills Translator',
              subtitle: 'MOS to civilian job translator',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillsTranslatorScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Resume & Interview Help',
              subtitle: 'Translate experience, prep for interviews',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Resume & Interview',
                  subtitle: 'Translate your service for civilian employers',
                  icon: Icons.description_outlined,
                  tips: const [
                    TipCard(title: 'Translate Military Terms', content: 'Replace jargon with civilian equivalents. "Led a 12-person fire team" becomes "Managed a 12-person team in high-pressure environments."', keyPoints: ['Avoid acronyms', 'Use civilian job titles', 'Quantify achievements']),
                    TipCard(title: 'Highlight Leadership', content: 'Military service builds leadership skills employers value. Emphasize decision-making, team management, and accountability.', keyPoints: ['Show responsibility level', 'Include budget/resources managed', 'Mention training you provided']),
                    TipCard(title: 'Interview Preparation', content: 'Practice the STAR method: Situation, Task, Action, Result. Have 3-5 stories ready that show your skills.', keyPoints: ['STAR method for answers', 'Practice out loud', 'Research the company']),
                    TipCard(title: 'Common Questions', content: 'Be ready for: "Why are you leaving the military?" "How do your skills transfer?" "Tell me about a challenge you overcame."', keyPoints: ['Stay positive about transition', 'Connect your experience', 'Show eagerness to learn']),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.health_and_safety_outlined,
          title: 'Crisis & Support Access',
          items: [
            _MilitaryItem(
              title: "When You're Not OK",
              subtitle: 'Clear, calm support pathways',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Emergency Help',
              subtitle: 'Region-aware resources',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
  
  Widget _buildReserveContent() {
    return Column(
      children: [
        _MilitarySection(
          icon: Icons.sync_outlined,
          title: 'Cross-Training & Skills',
          items: [
            _MilitaryItem(
              title: 'Skill Refreshers',
              subtitle: 'Stay current with core tasks',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChecklistScreen(
                  title: 'Skill Refreshers',
                  subtitle: 'Keep your skills sharp between drills',
                  icon: Icons.refresh_outlined,
                  categories: const [
                    ChecklistCategory(title: 'Physical Readiness', icon: Icons.fitness_center, color: Colors.green, items: [
                      ChecklistItem(title: 'PT test standards review'),
                      ChecklistItem(title: 'Run distance/time check'),
                      ChecklistItem(title: 'Strength training routine'),
                    ]),
                    ChecklistCategory(title: 'Technical Skills', icon: Icons.build, color: Colors.blue, items: [
                      ChecklistItem(title: 'MOS-specific refresher'),
                      ChecklistItem(title: 'Equipment familiarity'),
                      ChecklistItem(title: 'Procedure review'),
                    ]),
                    ChecklistCategory(title: 'Admin & Readiness', icon: Icons.folder, color: Colors.orange, items: [
                      ChecklistItem(title: 'Update personal records'),
                      ChecklistItem(title: 'Verify emergency contacts'),
                      ChecklistItem(title: 'Review mobilization checklist'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Civilian Job Translators',
              subtitle: 'Bridge gaps between civilian and military roles',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillsTranslatorScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Drills for Readiness',
              subtitle: 'Preparation for active duty transitions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChecklistScreen(
                  title: 'Drill Readiness',
                  subtitle: 'Be prepared for your next drill weekend',
                  icon: Icons.checklist_outlined,
                  categories: const [
                    ChecklistCategory(title: 'Before Drill', icon: Icons.schedule, color: Colors.blue, items: [
                      ChecklistItem(title: 'Uniform inspection complete'),
                      ChecklistItem(title: 'Travel arrangements confirmed'),
                      ChecklistItem(title: 'Work/family notified'),
                      ChecklistItem(title: 'Gear packed and ready'),
                    ]),
                    ChecklistCategory(title: 'Documents', icon: Icons.description, color: Colors.green, items: [
                      ChecklistItem(title: 'ID card valid'),
                      ChecklistItem(title: 'Orders printed'),
                      ChecklistItem(title: 'Medical records current'),
                    ]),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.balance_outlined,
          title: 'Balance & Resilience',
          items: [
            _MilitaryItem(
              title: 'Work-Life Juggle',
              subtitle: 'Guidance to balance service and civilian life',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Work-Life Balance',
                  subtitle: 'Managing dual roles as a Reservist',
                  icon: Icons.balance_outlined,
                  tips: const [
                    TipCard(title: 'Communicate Early', content: 'Let your civilian employer know about drill schedules well in advance. Most are supportive when given proper notice.', keyPoints: ['Share annual drill calendar', 'Document in writing', 'Know your legal protections']),
                    TipCard(title: 'Family Planning', content: 'Keep family in the loop. Share drill dates, discuss what happens during mobilization, and involve them in planning.', keyPoints: ['Mark all military dates on family calendar', 'Have backup childcare plans', 'Discuss financial implications']),
                    TipCard(title: 'Protect Your Time', content: 'Use drill weekends efficiently. When you\'re in civilian mode, be fully present there too.', keyPoints: ['Don\'t blur the lines', 'Set boundaries', 'Quality over quantity']),
                    TipCard(title: 'When Things Conflict', content: 'Conflicts will happen. Prioritize based on what can\'t be moved, communicate honestly, and don\'t overcommit.', keyPoints: ['Military orders typically take priority', 'But be flexible when possible', 'Build goodwill on both sides']),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Stress Reset Skills',
              subtitle: 'Quick, practical stress reset drills',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BreathingScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.checklist_outlined,
          title: 'Mobilization Prep',
          items: [
            _MilitaryItem(
              title: 'Immediate Orders Prep',
              subtitle: 'Tools to ready for sudden deployment',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChecklistScreen(
                  title: 'Mobilization Prep',
                  subtitle: 'Ready yourself and your family quickly',
                  icon: Icons.local_shipping_outlined,
                  accentColor: Colors.red,
                  categories: const [
                    ChecklistCategory(title: 'Personal Admin', icon: Icons.person, color: Colors.blue, items: [
                      ChecklistItem(title: 'Power of attorney prepared'),
                      ChecklistItem(title: 'Will and testament current'),
                      ChecklistItem(title: 'Emergency contacts updated'),
                      ChecklistItem(title: 'Bank accounts accessible to family'),
                    ]),
                    ChecklistCategory(title: 'Family Prep', icon: Icons.family_restroom, color: Colors.purple, items: [
                      ChecklistItem(title: 'Family care plan filed'),
                      ChecklistItem(title: 'Childcare arrangements confirmed'),
                      ChecklistItem(title: 'Bills on autopay'),
                      ChecklistItem(title: 'Emergency fund accessible'),
                    ]),
                    ChecklistCategory(title: 'Employer Notification', icon: Icons.work, color: Colors.green, items: [
                      ChecklistItem(title: 'Written notice to employer'),
                      ChecklistItem(title: 'Copy of orders provided'),
                      ChecklistItem(title: 'Return date discussed'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Family Contingency Plans',
              subtitle: 'Personal planning guide templates',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChecklistScreen(
                  title: 'Family Contingency',
                  subtitle: 'Ensure your family is prepared',
                  icon: Icons.family_restroom_outlined,
                  categories: const [
                    ChecklistCategory(title: 'Communication Plan', icon: Icons.phone, color: Colors.blue, items: [
                      ChecklistItem(title: 'Primary contact identified'),
                      ChecklistItem(title: 'Backup contact identified'),
                      ChecklistItem(title: 'Communication schedule set'),
                    ]),
                    ChecklistCategory(title: 'Financial Prep', icon: Icons.attach_money, color: Colors.green, items: [
                      ChecklistItem(title: 'Joint account access confirmed'),
                      ChecklistItem(title: 'Automatic payments set up'),
                      ChecklistItem(title: 'Emergency fund in place'),
                    ]),
                    ChecklistCategory(title: 'Household', icon: Icons.home, color: Colors.orange, items: [
                      ChecklistItem(title: 'Home maintenance contacts listed'),
                      ChecklistItem(title: 'Spare keys with trusted person'),
                      ChecklistItem(title: 'Vehicle maintenance current'),
                    ]),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.people_outline,
          title: 'Community & Unit Ties',
          items: [
            _MilitaryItem(
              title: 'Unit Calendar & Events',
              subtitle: "Stay up to speed with your unit's activities",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResourceListScreen(
                  title: 'Unit Resources',
                  subtitle: 'Stay connected with your unit',
                  icon: Icons.calendar_today_outlined,
                  categories: const [
                    ResourceCategory(title: 'Upcoming', icon: Icons.event, resources: [
                      ResourceItem(title: 'Drill Schedule', subtitle: 'Monthly drill dates', icon: Icons.calendar_today, description: 'Check with your unit for the annual training schedule and monthly drill dates.'),
                      ResourceItem(title: 'Annual Training', subtitle: 'AT dates and location', icon: Icons.map, description: 'Annual training typically 2-3 weeks. Confirm dates and location with your chain of command.'),
                    ]),
                    ResourceCategory(title: 'Resources', icon: Icons.folder, resources: [
                      ResourceItem(title: 'Family Readiness', subtitle: 'Support for families', icon: Icons.family_restroom, description: 'Family Readiness Groups provide support, information, and community for military families.'),
                      ResourceItem(title: 'Unit Newsletter', subtitle: 'Stay informed', icon: Icons.newspaper, description: 'Subscribe to unit communications for updates, news, and important announcements.'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Command Check-Ins',
              subtitle: 'Stay in sync with your superior officers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Command Check-Ins',
                  subtitle: 'Best practices for staying connected',
                  icon: Icons.people_outline,
                  tips: const [
                    TipCard(title: 'Regular Contact', content: 'Don\'t wait for drill. Check in periodically via email or phone. This builds trust and keeps you informed.', keyPoints: ['Monthly email update is good', 'Report significant life changes', 'Ask questions early']),
                    TipCard(title: 'Before Drill', content: 'Reach out a week before drill if you have questions or concerns. Coming prepared shows professionalism.', keyPoints: ['Confirm any special requirements', 'Ask about training focus', 'Report any issues early']),
                    TipCard(title: 'After Drill', content: 'Follow up on action items promptly. If assigned tasks, complete and report back quickly.', keyPoints: ['Complete tasks on time', 'Document what you did', 'Ask for feedback']),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.health_and_safety_outlined,
          title: 'Crisis & Support Access',
          items: [
            _MilitaryItem(
              title: "When You're Not OK",
              subtitle: 'Clear, calm support pathways',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Emergency Help',
              subtitle: 'Region-aware resources',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
  
  Widget _buildTransitioningContent() {
    return Column(
      children: [
        _MilitarySection(
          icon: Icons.work_outline,
          title: 'Career Transition',
          items: [
            _MilitaryItem(
              title: 'Civilian Skills Translator',
              subtitle: 'MOS to civilian job translator',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillsTranslatorScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Resume Building',
              subtitle: 'Translate military experience for employers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Resume Building',
                  subtitle: 'Create a civilian-ready resume',
                  icon: Icons.description_outlined,
                  tips: const [
                    TipCard(title: 'Format for Impact', content: 'Use a clean, professional format. Lead with a summary, then experience, then education and skills.', keyPoints: ['One page if possible', 'Reverse chronological order', 'Easy to scan quickly']),
                    TipCard(title: 'Quantify Everything', content: 'Numbers stand out. "Managed inventory" becomes "Managed \$2M equipment inventory with 99% accountability."', keyPoints: ['Dollar amounts', 'Team sizes', 'Percentages and metrics']),
                    TipCard(title: 'Action Verbs', content: 'Start bullets with strong verbs: Led, Managed, Developed, Implemented, Trained, Coordinated, Achieved.', keyPoints: ['Avoid passive voice', 'Be specific', 'Show results']),
                    TipCard(title: 'Tailor Each Application', content: 'Customize your resume for each job. Match keywords from the job posting to your experience.', keyPoints: ['Read job description carefully', 'Mirror their language', 'Highlight relevant skills']),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Interview Preparation',
              subtitle: 'Practice civilian interview scenarios',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScenarioLibraryScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.home_outlined,
          title: 'Life Transition',
          items: [
            _MilitaryItem(
              title: 'Housing & Relocation',
              subtitle: 'Planning for civilian housing',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChecklistScreen(
                  title: 'Housing & Relocation',
                  subtitle: 'Plan your move to civilian life',
                  icon: Icons.home_outlined,
                  categories: const [
                    ChecklistCategory(title: 'Before You Leave', icon: Icons.schedule, color: Colors.blue, items: [
                      ChecklistItem(title: 'Research destination cost of living'),
                      ChecklistItem(title: 'Start apartment/house search'),
                      ChecklistItem(title: 'Check veteran home loan eligibility'),
                      ChecklistItem(title: 'Budget for deposits and moving costs'),
                    ]),
                    ChecklistCategory(title: 'Moving Process', icon: Icons.local_shipping, color: Colors.green, items: [
                      ChecklistItem(title: 'Schedule move with TMO or arrange own'),
                      ChecklistItem(title: 'Inventory all belongings'),
                      ChecklistItem(title: 'Forward mail to new address'),
                      ChecklistItem(title: 'Transfer or close utilities'),
                    ]),
                    ChecklistCategory(title: 'After Arrival', icon: Icons.home, color: Colors.orange, items: [
                      ChecklistItem(title: 'Set up new utilities'),
                      ChecklistItem(title: 'Update driver\'s license'),
                      ChecklistItem(title: 'Register to vote'),
                      ChecklistItem(title: 'Find local services (doctors, etc.)'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Benefits Navigation',
              subtitle: 'Understanding your transition benefits',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResourceListScreen(
                  title: 'Benefits Guide',
                  subtitle: 'Maximize your transition benefits',
                  icon: Icons.card_giftcard_outlined,
                  categories: const [
                    ResourceCategory(title: 'Healthcare', icon: Icons.local_hospital, resources: [
                      ResourceItem(title: 'Veteran Healthcare', subtitle: 'Enrollment & eligibility', icon: Icons.health_and_safety, description: 'Veteran healthcare provides comprehensive services. Check your government veteran services for enrollment.', details: ['Apply soon after discharge', 'Bring service documents', 'Priority based on service connection']),
                      ResourceItem(title: 'Transition Healthcare', subtitle: 'Continued coverage options', icon: Icons.medical_services, description: 'Many countries offer continued healthcare coverage for 12-36 months after separation.'),
                    ]),
                    ResourceCategory(title: 'Education', icon: Icons.school, resources: [
                      ResourceItem(title: 'Education Benefits', subtitle: 'Learning support', icon: Icons.school, description: 'Many countries offer education benefits covering tuition, housing, and books. Check your veteran services.', details: ['Months of benefits vary', 'Housing allowance often included', 'May transfer to dependents']),
                      ResourceItem(title: 'VR&E', subtitle: 'Vocational Rehabilitation', icon: Icons.work, description: 'Vocational Rehabilitation helps service-connected veterans prepare for, find, and keep jobs.'),
                    ]),
                    ResourceCategory(title: 'Financial', icon: Icons.attach_money, resources: [
                      ResourceItem(title: 'Disability Compensation', subtitle: 'Service-connected claims', icon: Icons.accessibility, description: 'File disability claims for conditions related to your service. Tax-free monthly payments.'),
                      ResourceItem(title: 'Separation Pay', subtitle: 'Final pay and benefits', icon: Icons.payments, description: 'Ensure you receive all entitled separation pay and terminal leave.'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Family Adjustment',
              subtitle: 'Supporting family through transition',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Family Adjustment',
                  subtitle: 'Navigate transition together',
                  icon: Icons.family_restroom_outlined,
                  tips: const [
                    TipCard(title: 'Communicate Openly', content: 'Talk about what transition means for everyone. Discuss concerns, expectations, and hopes as a family.', keyPoints: ['Regular family meetings', 'Everyone\'s voice matters', 'Be patient with each other']),
                    TipCard(title: 'Kids\' Adjustment', content: 'Children may struggle with leaving friends, changing schools, or seeing a parent home more. Give them extra support.', keyPoints: ['Maintain routines', 'Validate their feelings', 'Stay connected with old friends']),
                    TipCard(title: 'Spouse Support', content: 'Spouses often shoulder extra burden during transition. Acknowledge this and share responsibilities.', keyPoints: ['Share decision-making', 'Recognize their sacrifices', 'Support their goals too']),
                    TipCard(title: 'Building New Routines', content: 'Military life was structured. Create new family routines for stability and connection.', keyPoints: ['Family dinner times', 'Weekend activities', 'Individual check-ins']),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.psychology_outlined,
          title: 'Mental Adjustment',
          items: [
            _MilitaryItem(
              title: 'Identity Shift',
              subtitle: 'Navigating the transition mentally',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Identity Shift',
                  subtitle: 'Rediscover who you are beyond service',
                  icon: Icons.psychology_outlined,
                  tips: const [
                    TipCard(title: 'It\'s Normal', content: 'Feeling lost or unsure after leaving the military is completely normal. Your identity was tied to service, and that takes time to rebuild.', keyPoints: ['Most veterans experience this', 'It gets easier', 'You\'re not alone']),
                    TipCard(title: 'You\'re More Than Your Rank', content: 'You built skills, character, and experiences that go beyond your uniform. Start identifying who you are as a person, not just a servicemember.', keyPoints: ['List your values', 'What do you enjoy?', 'Who do you want to become?']),
                    TipCard(title: 'Find Purpose', content: 'Service gave you purpose. Now you get to choose your own. This is freedom, even if it feels scary.', keyPoints: ['What problems do you want to solve?', 'How can you contribute?', 'Try new things']),
                    TipCard(title: 'Connect with Veterans', content: 'Other veterans understand. Join veteran groups, maintain military friendships, and build new civilian connections too.', keyPoints: ['Veteran organizations', 'Maintain old bonds', 'Build new ones']),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Stress Management',
              subtitle: 'Coping with transition stress',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BreathingScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.health_and_safety_outlined,
          title: 'Crisis & Support Access',
          items: [
            _MilitaryItem(
              title: "When You're Not OK",
              subtitle: 'Clear, calm support pathways',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Emergency Help',
              subtitle: 'Region-aware resources',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
  
  Widget _buildRecentlyDischargedContent() {
    return Column(
      children: [
        _MilitarySection(
          icon: Icons.explore_outlined,
          title: 'Finding Your Path',
          items: [
            _MilitaryItem(
              title: 'Purpose Discovery',
              subtitle: 'Rediscover meaning in civilian life',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Purpose Discovery',
                  subtitle: 'Find meaning in your next chapter',
                  icon: Icons.explore_outlined,
                  tips: const [
                    TipCard(title: 'Reflect on Your Why', content: 'Why did you join the military? What drove you? Those core motivations can guide your civilian path too.', keyPoints: ['Service to others', 'Challenge and growth', 'Making a difference']),
                    TipCard(title: 'Explore Freely', content: 'You don\'t have to have it figured out immediately. Try things. Take time to discover what resonates.', keyPoints: ['No pressure to decide now', 'Experiment', 'It\'s okay to change direction']),
                    TipCard(title: 'Define Success for Yourself', content: 'Success isn\'t just money or titles. What does a fulfilling life look like for YOU?', keyPoints: ['Family? Freedom? Impact?', 'Write your own definition', 'Ignore others\' expectations']),
                    TipCard(title: 'Start Small', content: 'Purpose doesn\'t require grand gestures. Start with small actions aligned with your values.', keyPoints: ['Volunteer', 'Help one person', 'Build from there']),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Goal Setting',
              subtitle: 'Set new life goals post-service',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.work_outline,
          title: 'Employment & Education',
          items: [
            _MilitaryItem(
              title: 'Job Search Strategies',
              subtitle: 'Veteran-focused job hunting tips',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen.fromSlug(
                  slug: 'job-search',
                  fallbackTitle: 'Job Search',
                  fallbackSubtitle: 'Find the right civilian career',
                  fallbackIcon: Icons.search_outlined,
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Education Benefits',
              subtitle: 'Education benefits and resources',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResourceListScreen(
                  title: 'Education Benefits',
                  subtitle: 'Your guide to education options',
                  icon: Icons.school_outlined,
                  categories: const [
                    ResourceCategory(title: 'Education Benefits', icon: Icons.school, resources: [
                      ResourceItem(title: 'Full Education Benefit', subtitle: 'Comprehensive coverage', icon: Icons.school, description: 'Covers tuition, housing allowance, and books/supplies for approved programs.', details: ['Months of benefits vary by country', 'Housing allowance often included', 'Book allowance typically available']),
                      ResourceItem(title: 'Alternative Options', subtitle: 'Other programs', icon: Icons.payments, description: 'Monthly benefit paid directly to you. Amount depends on contribution and service.'),
                    ]),
                    ResourceCategory(title: 'Training Programs', icon: Icons.library_books, resources: [
                      ResourceItem(title: 'Tech Training', subtitle: 'Tech bootcamps', icon: Icons.computer, description: 'Tuition-free training in high-demand tech fields like coding, data science, and IT.', details: ['Often separate from education benefits', 'Housing allowance may be included', 'Short-term programs']),
                      ResourceItem(title: 'Apprenticeships', subtitle: 'Earn while you learn', icon: Icons.work, description: 'Use veteran benefits while doing paid apprenticeships.'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Networking',
              subtitle: 'Building civilian professional connections',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipCardsScreen(
                  title: 'Professional Networking',
                  subtitle: 'Build your civilian network',
                  icon: Icons.people_outline,
                  tips: const [
                    TipCard(title: 'LinkedIn is Essential', content: 'Create a strong LinkedIn profile. Connect with veterans, recruiters, and people in your target industry.', keyPoints: ['Professional photo', 'Translated military experience', 'Connect actively']),
                    TipCard(title: 'Veteran Organizations', content: 'Join veteran groups for networking. Local veteran associations and industry-specific veteran groups are valuable.', keyPoints: ['Built-in trust', 'Shared experiences', 'Mentorship opportunities']),
                    TipCard(title: 'Informational Interviews', content: 'Ask people for 15-minute conversations about their career. Most are happy to help, and you learn a lot.', keyPoints: ['Ask questions, don\'t pitch', 'Follow up with thanks', 'Ask for referrals']),
                    TipCard(title: 'Give Before You Ask', content: 'Networking is about relationships, not transactions. Help others first, and opportunities will come.', keyPoints: ['Share resources', 'Make introductions', 'Be genuinely helpful']),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.favorite_outline,
          title: 'Wellbeing & Health',
          items: [
            _MilitaryItem(
              title: 'Veteran Healthcare Navigation',
              subtitle: 'Understanding your health benefits',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResourceListScreen(
                  title: 'Veteran Healthcare',
                  subtitle: 'Navigate your healthcare benefits',
                  icon: Icons.local_hospital_outlined,
                  categories: const [
                    ResourceCategory(title: 'Getting Started', icon: Icons.play_arrow, resources: [
                      ResourceItem(title: 'Enrollment', subtitle: 'How to enroll in veteran healthcare', icon: Icons.app_registration, description: 'Apply online, by phone, or in person at your local veteran services office.', details: ['Bring service documents', 'Apply soon after discharge for easiest enrollment', 'Priority groups may determine eligibility']),
                      ResourceItem(title: 'Your First Appointment', subtitle: 'What to expect', icon: Icons.calendar_today, description: 'Your first appointment will establish care and assess your health needs.', details: ['Bring medications list', 'Bring medical records', 'Be honest about symptoms']),
                    ]),
                    ResourceCategory(title: 'Services', icon: Icons.medical_services, resources: [
                      ResourceItem(title: 'Primary Care', subtitle: 'Regular health needs', icon: Icons.person, description: 'Your primary care team handles routine care, referrals, and ongoing health management.'),
                      ResourceItem(title: 'Mental Health', subtitle: 'Counseling and support', icon: Icons.psychology, description: 'Veteran services offer counseling, therapy, and medication management. Ask about community-based care options.'),
                      ResourceItem(title: 'Specialty Care', subtitle: 'Specialized treatment', icon: Icons.local_hospital, description: 'Access specialists for specific conditions through referrals from your primary care team.'),
                    ]),
                  ],
                )),
              ),
            ),
            _MilitaryItem(
              title: 'Mental Health Support',
              subtitle: 'Resources for post-service adjustment',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResourceListScreen(
                  title: 'Mental Health',
                  subtitle: 'Support for your wellbeing',
                  icon: Icons.psychology_outlined,
                  categories: const [
                    ResourceCategory(title: 'Veteran Services', icon: Icons.local_hospital, resources: [
                      ResourceItem(title: 'Veteran Mental Health', subtitle: 'Comprehensive care', icon: Icons.psychology, description: 'Veteran services provide therapy, counseling, and medication management. Covered under your veteran healthcare.'),
                      ResourceItem(title: 'Vet Centers', subtitle: 'Community-based', icon: Icons.location_city, description: 'Vet Centers offer counseling in community settings. No enrollment required for combat veterans.', details: ['More informal setting', 'Peer counselors available', 'Family counseling too']),
                    ]),
                    ResourceCategory(title: 'Crisis Resources', icon: Icons.warning, resources: [
                      ResourceItem(title: 'Crisis Support', subtitle: 'Emergency help', icon: Icons.phone, description: 'Free, confidential support 24/7. Contact your local veteran crisis line or emergency services.', details: ['Available 24/7', 'Trained counselors', 'Chat and text options often available']),
                      ResourceItem(title: 'Same Day Mental Health', subtitle: 'Urgent care option', icon: Icons.schedule, description: 'Many veteran medical centers offer same-day mental health services for urgent needs.'),
                    ]),
                  ],
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _MilitarySection(
          icon: Icons.health_and_safety_outlined,
          title: 'Crisis & Support Access',
          items: [
            _MilitaryItem(
              title: "When You're Not OK",
              subtitle: 'Clear, calm support pathways',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
            _MilitaryItem(
              title: 'Crisis Support',
              subtitle: 'Immediate support when you need it',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
  
  Widget _buildQuickExitButton(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.background,
        border: Border(
          top: BorderSide(color: colours.border.withOpacity(0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colours.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quick Exit',
                  style: TextStyle(
                    color: colours.textBright,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: colours.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MilitarySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_MilitaryItem> items;
  
  const _MilitarySection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: colours.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colours.textMuted),
              ],
            ),
          ),
          Divider(height: 1, color: colours.border.withOpacity(0.5)),
          ...items.map((item) => _buildItem(context, item)),
        ],
      ),
    );
  }
  
  Widget _buildItem(BuildContext context, _MilitaryItem item) {
    final colours = context.colours;
    
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        
        // Check subscription after free limit
        final subscriptionService = SubscriptionService();
        if (!subscriptionService.isPremium) {
          _militaryItemsViewed++;
          if (_militaryItemsViewed > _freeItemLimit) {
            final unlocked = await checkPremiumAccess(context, featureName: 'Military Resources');
            if (!unlocked) return;
          }
        }
        
        item.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colours.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MilitaryItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _MilitaryItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
