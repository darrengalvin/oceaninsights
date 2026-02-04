import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../goals/screens/goals_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../widgets/big_feelings_toolkit.dart';
import '../widgets/who_am_i_quiz.dart';
import '../widgets/career_sampler_widget.dart';
import '../widgets/study_smarter_screen.dart';
import '../widgets/confidence_builder_screen.dart';
import '../widgets/interest_explorer_screen.dart';
import '../widgets/tip_cards_screen.dart';
import '../widgets/checklist_screen.dart';
import '../widgets/resource_list_screen.dart';

/// Young Person support screen with youth-focused resources
class YoungPersonScreen extends StatelessWidget {
  const YoungPersonScreen({super.key});

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
                Icons.school_rounded,
                color: colours.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Young Person',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Identity & Self-Discovery
            _YouthSection(
              icon: Icons.person_search_outlined,
              title: 'Identity & Self-Discovery',
              items: [
                _YouthItem(
                  title: 'Who Am I?',
                  subtitle: 'Values, strengths, and personality quizzes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WhoAmIQuizScreen()),
                  ),
                ),
                _YouthItem(
                  title: 'Explore Interests',
                  subtitle: 'Try mini challenges in art, tech, sports, writing',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InterestExplorerScreen()),
                  ),
                ),
                _YouthItem(
                  title: 'Confidence Builder',
                  subtitle: 'Tools for self-esteem and self-expression',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConfidenceBuilderScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // School & Learning
            _YouthSection(
              icon: Icons.menu_book_outlined,
              title: 'School & Learning',
              items: [
                _YouthItem(
                  title: 'Study Smarter',
                  subtitle: 'Learning styles, focus tools, revision tips',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudySmarterScreen()),
                  ),
                ),
                _YouthItem(
                  title: 'Subject Explorer',
                  subtitle: 'What different subjects can lead to',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Subject Explorer',
                      subtitle: 'Discover where each subject can take you',
                      icon: Icons.explore_outlined,
                      tips: const [
                        TipCard(
                          title: 'Math',
                          content: 'Math opens doors to engineering, finance, data science, architecture, and game development. It teaches logical thinking that applies everywhere.',
                          keyPoints: ['Engineering & Architecture', 'Finance & Banking', 'Data Science & AI', 'Game Development'],
                        ),
                        TipCard(
                          title: 'Science',
                          content: 'Science leads to medicine, research, environmental work, and technology. It teaches you to question, test, and discover.',
                          keyPoints: ['Medicine & Healthcare', 'Environmental Science', 'Research & Lab Work', 'Tech & Innovation'],
                        ),
                        TipCard(
                          title: 'English & Writing',
                          content: 'Communication skills are valued everywhere. Writing leads to journalism, marketing, law, and creative careers.',
                          keyPoints: ['Journalism & Media', 'Marketing & Advertising', 'Law & Policy', 'Content Creation'],
                        ),
                        TipCard(
                          title: 'History & Social Studies',
                          content: 'Understanding the past and society prepares you for law, politics, teaching, and business leadership.',
                          keyPoints: ['Law & Politics', 'Teaching & Education', 'Business Strategy', 'Social Work'],
                        ),
                        TipCard(
                          title: 'Arts & Design',
                          content: 'Creativity is increasingly valuable. Art leads to design, entertainment, marketing, and entrepreneurship.',
                          keyPoints: ['Graphic & UX Design', 'Film & Animation', 'Fashion & Interior Design', 'Advertising'],
                        ),
                      ],
                    )),
                  ),
                ),
                _YouthItem(
                  title: 'Ask for Help',
                  subtitle: 'How to talk to teachers, counselors, and parents',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Ask for Help',
                      subtitle: 'Scripts and tips for getting support',
                      icon: Icons.support_agent_outlined,
                      tips: const [
                        TipCard(
                          title: 'Talking to Teachers',
                          content: 'Teachers want to help. Approach them after class or during office hours. Be specific about what you need.',
                          keyPoints: [
                            'Say: "I\'m struggling with X. Can you help?"',
                            'Ask for extra practice or resources',
                            'Email if talking in person feels hard',
                          ],
                        ),
                        TipCard(
                          title: 'Talking to Parents',
                          content: 'Pick a calm moment, not during an argument. Start with how you feel, not what you want them to do.',
                          keyPoints: [
                            'Say: "I want to talk about something"',
                            'Use "I feel" statements',
                            'Be patient - they might need time',
                          ],
                        ),
                        TipCard(
                          title: 'School Counselors',
                          content: 'Counselors are trained to help with academic, social, and emotional issues. Everything is confidential.',
                          keyPoints: [
                            'You can ask to see them anytime',
                            'They can help with stress, friends, family',
                            'They won\'t judge you',
                          ],
                        ),
                        TipCard(
                          title: 'When It Feels Too Hard',
                          content: 'If you\'re really struggling, it\'s okay to say so. You don\'t have to figure everything out alone.',
                          keyPoints: [
                            'Write it down if speaking is hard',
                            'Ask a friend to come with you',
                            'One conversation can change things',
                          ],
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Future Pathways
            _YouthSection(
              icon: Icons.route_outlined,
              title: 'Future Pathways',
              items: [
                _YouthItem(
                  title: 'Career Sampler',
                  subtitle: 'Short previews of different jobs',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CareerSamplerScreen()),
                  ),
                ),
                _YouthItem(
                  title: 'College vs Trades',
                  subtitle: 'Understand your options early',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'College vs Trades',
                      subtitle: 'Both paths can lead to great careers',
                      icon: Icons.compare_arrows_outlined,
                      tips: const [
                        TipCard(
                          title: 'College Path',
                          content: 'College gives you broad education, time to explore, and is required for some careers like medicine or law.',
                          keyPoints: [
                            '4+ years of study',
                            'Broader career options',
                            'More student debt typically',
                            'Required for some professions',
                          ],
                        ),
                        TipCard(
                          title: 'Trade School Path',
                          content: 'Trade schools teach specific skills quickly. You can start earning sooner in high-demand fields.',
                          keyPoints: [
                            '6 months to 2 years typically',
                            'Hands-on learning',
                            'Less debt, faster income',
                            'High demand: plumbing, electrical, HVAC',
                          ],
                        ),
                        TipCard(
                          title: 'Apprenticeships',
                          content: 'Get paid while you learn. Apprenticeships combine work experience with education.',
                          keyPoints: [
                            'Earn while you learn',
                            'Real-world experience',
                            'Available in many industries',
                            'Often leads to full-time jobs',
                          ],
                        ),
                        TipCard(
                          title: 'The Real Truth',
                          content: 'Neither path is "better." It depends on your interests, learning style, and goals. Many successful people take both paths at different times.',
                          keyPoints: [
                            'You can change paths later',
                            'Success comes in many forms',
                            'What matters is finding your fit',
                          ],
                        ),
                      ],
                    )),
                  ),
                ),
                _YouthItem(
                  title: 'Goal Setting',
                  subtitle: 'Plan short-term and long-term goals',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mental Health & Emotions
            _YouthSection(
              icon: Icons.psychology_outlined,
              title: 'Mental Health & Emotions',
              items: [
                _YouthItem(
                  title: 'Big Feelings Toolkit',
                  subtitle: 'Anxiety, anger, sadness - tools to cope',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BigFeelingsToolkitScreen()),
                  ),
                ),
                _YouthItem(
                  title: 'Stress Coping Skills',
                  subtitle: 'Manage stress and find calm',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BreathingScreen()),
                  ),
                ),
                _YouthItem(
                  title: 'Daily Check-In',
                  subtitle: 'Build awareness of how you\'re feeling',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Side by side: Relationships & Life Skills
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _YouthCompactSection(
                    icon: Icons.people_outline,
                    title: 'Relationships & Belonging',
                    items: [
                      _YouthItem(
                        title: 'Friendship Skills',
                        subtitle: 'Communication and boundaries',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Friendship Skills',
                            subtitle: 'Build stronger connections',
                            icon: Icons.people_outline,
                            accentColor: Colors.purple,
                            tips: const [
                              TipCard(title: 'Being a Good Listener', content: 'Really listen when friends talk. Put your phone away, make eye contact, and ask follow-up questions.', keyPoints: ['Don\'t just wait to talk', 'Show you heard them', 'Remember details']),
                              TipCard(title: 'Setting Boundaries', content: 'It\'s okay to say no. Good friends respect your limits and don\'t pressure you.', keyPoints: ['No is a complete sentence', 'You don\'t owe explanations', 'True friends understand']),
                              TipCard(title: 'Handling Conflict', content: 'Disagreements happen. Address issues calmly, use "I feel" statements, and be willing to apologize.', keyPoints: ['Cool down before talking', 'Focus on the issue, not the person', 'Apologize when wrong']),
                            ],
                          )),
                        ),
                      ),
                      _YouthItem(
                        title: 'Family Dynamics',
                        subtitle: 'Handling expectations and conflict',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Family Dynamics',
                            subtitle: 'Navigate family relationships',
                            icon: Icons.family_restroom_outlined,
                            accentColor: Colors.teal,
                            tips: const [
                              TipCard(title: 'Managing Expectations', content: 'Parents want the best for you, but sometimes their vision differs from yours. Communicate openly about your goals.', keyPoints: ['Share your perspective calmly', 'Listen to their concerns', 'Find middle ground']),
                              TipCard(title: 'During Arguments', content: 'Stay calm, don\'t escalate. If things get heated, it\'s okay to take a break and come back later.', keyPoints: ['Take deep breaths', 'Say "I need a minute"', 'Revisit when calm']),
                              TipCard(title: 'Building Trust', content: 'Trust is built over time through consistent actions. Follow through on commitments and be honest.', keyPoints: ['Keep your promises', 'Communicate proactively', 'Admit mistakes']),
                            ],
                          )),
                        ),
                      ),
                      _YouthItem(
                        title: 'Finding Your People',
                        subtitle: 'Clubs, teams, and communities',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourceListScreen(
                            title: 'Find Your People',
                            subtitle: 'Ways to connect with others who share your interests',
                            icon: Icons.groups_outlined,
                            accentColor: Colors.indigo,
                            categories: const [
                              ResourceCategory(title: 'At School', icon: Icons.school_outlined, resources: [
                                ResourceItem(title: 'Sports Teams', subtitle: 'Athletics & fitness', icon: Icons.sports_basketball, description: 'Join a school sports team to stay active and make friends.', details: ['Check with PE department', 'Tryouts are usually at start of season', 'JV teams often welcome beginners']),
                                ResourceItem(title: 'Clubs & Activities', subtitle: 'Academic & interest groups', icon: Icons.interests, description: 'From debate club to robotics, there\'s something for everyone.', details: ['Ask your counselor for a list', 'Start your own club if needed', 'Leadership opportunities available']),
                              ]),
                              ResourceCategory(title: 'Online', icon: Icons.computer_outlined, resources: [
                                ResourceItem(title: 'Discord Communities', subtitle: 'Chat & connect', icon: Icons.chat, description: 'Find servers for your interests - gaming, art, music, coding.', details: ['Search for communities you like', 'Stay safe - don\'t share personal info', 'Find moderated, positive spaces']),
                                ResourceItem(title: 'Online Courses', subtitle: 'Learn together', icon: Icons.school, description: 'Take courses with discussion forums to meet people learning the same things.', details: ['Coursera, Khan Academy, Skillshare', 'Join study groups', 'Participate in forums']),
                              ]),
                              ResourceCategory(title: 'Local', icon: Icons.location_on_outlined, resources: [
                                ResourceItem(title: 'Youth Groups', subtitle: 'Community organizations', icon: Icons.groups, description: 'YMCA, community centers, and local youth programs.', details: ['Often free or low-cost', 'Sports, arts, volunteering', 'Meet people from different schools']),
                                ResourceItem(title: 'Volunteer Work', subtitle: 'Give back & connect', icon: Icons.volunteer_activism, description: 'Volunteering connects you with like-minded people while helping others.', details: ['Animal shelters', 'Food banks', 'Environmental cleanup']),
                              ]),
                            ],
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _YouthCompactSection(
                    icon: Icons.lightbulb_outline,
                    title: 'Life Skills',
                    items: [
                      _YouthItem(
                        title: 'Money Basics',
                        subtitle: 'Saving, budgeting, and spending',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Money Basics',
                            subtitle: 'Build smart money habits early',
                            icon: Icons.attach_money_outlined,
                            accentColor: Colors.green,
                            tips: const [
                              TipCard(title: 'The 50/30/20 Rule', content: 'A simple way to split your money: 50% needs, 30% wants, 20% savings.', keyPoints: ['Needs: food, transport, essentials', 'Wants: entertainment, extras', 'Savings: future you will thank you']),
                              TipCard(title: 'Start Saving Now', content: 'Even small amounts add up. Save something from every bit of money you get.', keyPoints: ['Open a savings account', 'Set up automatic transfers', 'Watch it grow over time']),
                              TipCard(title: 'Avoid Impulse Buys', content: 'Wait 24-48 hours before buying something you want. If you still want it, go for it.', keyPoints: ['Sleep on big purchases', 'Ask: do I need this?', 'Compare prices first']),
                            ],
                          )),
                        ),
                      ),
                      _YouthItem(
                        title: 'Time Management',
                        subtitle: 'Homework + life balance',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Time Management',
                            subtitle: 'Get more done, stress less',
                            icon: Icons.schedule_outlined,
                            accentColor: Colors.blue,
                            tips: const [
                              TipCard(title: 'Prioritize First', content: 'Not everything is equally important. Do the most important or urgent things first.', keyPoints: ['Make a quick list', 'Number by importance', 'Start with #1']),
                              TipCard(title: 'Use Time Blocks', content: 'Schedule specific times for homework, breaks, and fun. Your brain works better with structure.', keyPoints: ['25-50 min work blocks', '5-10 min breaks', 'Longer break after 2-3 blocks']),
                              TipCard(title: 'Eliminate Distractions', content: 'Phone notifications kill focus. Put your phone in another room when you need to concentrate.', keyPoints: ['Turn off notifications', 'Use apps to block distractions', 'Tell others you\'re focusing']),
                            ],
                          )),
                        ),
                      ),
                      _YouthItem(
                        title: 'Digital Life',
                        subtitle: 'Social media, privacy, safety',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Digital Life',
                            subtitle: 'Stay safe and healthy online',
                            icon: Icons.phone_android_outlined,
                            accentColor: Colors.orange,
                            tips: const [
                              TipCard(title: 'Protect Your Privacy', content: 'Think before you share. Once it\'s online, it\'s hard to take back.', keyPoints: ['Don\'t share location publicly', 'Use strong passwords', 'Be careful with personal info']),
                              TipCard(title: 'Social Media Balance', content: 'Social media is designed to keep you scrolling. Set limits and take breaks.', keyPoints: ['Set daily time limits', 'Unfollow accounts that make you feel bad', 'Real life > online life']),
                              TipCard(title: 'Dealing with Cyberbullying', content: 'If someone is harassing you online, don\'t engage. Screenshot, block, and tell an adult.', keyPoints: ['Don\'t respond to trolls', 'Save evidence', 'Report and block']),
                            ],
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Inspiration & Role Models
            _YouthSection(
              icon: Icons.bolt_outlined,
              title: 'Inspiration & Role Models',
              items: [
                _YouthItem(
                  title: 'Real Student Stories',
                  subtitle: 'Different journeys, same struggles',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Real Stories',
                      subtitle: 'You\'re not alone in your journey',
                      icon: Icons.auto_stories_outlined,
                      tips: const [
                        TipCard(title: 'From Failing to Top of Class', content: 'Marcus was failing math in 9th grade. He asked for help, found a study group, and by 11th grade was tutoring others.', keyPoints: ['Asked for help', 'Found study partners', 'Turned weakness into strength']),
                        TipCard(title: 'Finding My Voice', content: 'Sofia was terrified of public speaking. She joined drama club on a dare and discovered she loved performing.', keyPoints: ['Tried something scary', 'Found hidden talent', 'Now leads school events']),
                        TipCard(title: 'Different Path, Same Success', content: 'Jamal skipped college for trade school. Now he runs his own electrical business and earns more than many of his college friends.', keyPoints: ['Chose his own path', 'Learned practical skills', 'Built his own business']),
                      ],
                    )),
                  ),
                ),
                _YouthItem(
                  title: 'Mentor Connect',
                  subtitle: 'Older students or young professionals',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResourceListScreen(
                      title: 'Find a Mentor',
                      subtitle: 'Connect with people who\'ve been there',
                      icon: Icons.supervisor_account_outlined,
                      categories: const [
                        ResourceCategory(title: 'At School', icon: Icons.school_outlined, resources: [
                          ResourceItem(title: 'Peer Mentoring', subtitle: 'Older students', icon: Icons.people, description: 'Many schools have peer mentoring programs where upperclassmen help younger students.', details: ['Ask your counselor', 'Often paired by interest', 'Great for college advice']),
                          ResourceItem(title: 'Teacher Mentors', subtitle: 'Faculty guidance', icon: Icons.person, description: 'Teachers can be great mentors. Find one whose class you enjoy and ask to chat.', details: ['Visit office hours', 'Ask about their career path', 'Seek advice on your interests']),
                        ]),
                        ResourceCategory(title: 'Programs', icon: Icons.groups_outlined, resources: [
                          ResourceItem(title: 'Big Brothers Big Sisters', subtitle: 'Community mentoring', icon: Icons.favorite, description: 'One of the oldest mentoring programs. Matches youth with adult mentors.', details: ['Free to join', 'Carefully vetted mentors', 'Long-term relationships']),
                          ResourceItem(title: 'Industry Mentors', subtitle: 'Career guidance', icon: Icons.work, description: 'Some organizations connect students with professionals in fields they\'re interested in.', details: ['LinkedIn mentoring', 'Industry associations', 'Career day connections']),
                        ]),
                      ],
                    )),
                  ),
                ),
                _YouthItem(
                  title: 'Try Something New',
                  subtitle: 'Monthly challenges',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChecklistScreen(
                      title: 'Monthly Challenges',
                      subtitle: 'Step outside your comfort zone',
                      icon: Icons.emoji_events_outlined,
                      accentColor: Colors.amber,
                      categories: const [
                        ChecklistCategory(title: 'Social Challenges', icon: Icons.people, color: Colors.purple, items: [
                          ChecklistItem(title: 'Talk to someone new', subtitle: 'Just say hi'),
                          ChecklistItem(title: 'Give a genuine compliment', subtitle: 'To someone you don\'t usually talk to'),
                          ChecklistItem(title: 'Join a group activity', subtitle: 'Club, sport, or event'),
                        ]),
                        ChecklistCategory(title: 'Learning Challenges', icon: Icons.school, color: Colors.blue, items: [
                          ChecklistItem(title: 'Learn a new skill', subtitle: 'Cooking, coding, instrument'),
                          ChecklistItem(title: 'Read a book outside your usual genre'),
                          ChecklistItem(title: 'Teach someone something you know'),
                        ]),
                        ChecklistCategory(title: 'Personal Growth', icon: Icons.trending_up, color: Colors.green, items: [
                          ChecklistItem(title: 'Wake up 30 min earlier for a week'),
                          ChecklistItem(title: 'Go a day without social media'),
                          ChecklistItem(title: 'Write down 3 things you\'re grateful for'),
                        ]),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _YouthSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_YouthItem> items;
  
  const _YouthSection({
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
  
  Widget _buildItem(BuildContext context, _YouthItem item) {
    final colours = context.colours;
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
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

class _YouthCompactSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_YouthItem> items;
  
  const _YouthCompactSection({
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: colours.accent, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colours.textMuted, size: 18),
              ],
            ),
          ),
          ...items.map((item) => _buildCompactItem(context, item)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  Widget _buildCompactItem(BuildContext context, _YouthItem item) {
    final colours = context.colours;
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        item.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colours.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _YouthItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _YouthItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
