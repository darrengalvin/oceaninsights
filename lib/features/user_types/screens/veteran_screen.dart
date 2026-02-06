import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../settings/screens/contact_help_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../widgets/skills_translator_widget.dart';
import '../widgets/tip_cards_screen.dart';
import '../widgets/checklist_screen.dart';
import '../widgets/resource_list_screen.dart';

/// Veteran support screen with comprehensive resources
class VeteranScreen extends StatelessWidget {
  const VeteranScreen({super.key});

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
                Icons.workspace_premium_rounded,
                color: colours.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Veterans',
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
            // Personal Growth
            _VeteranSection(
              icon: Icons.trending_up_outlined,
              title: 'Personal Growth',
              items: [
                _VeteranItem(
                  title: 'New Passions',
                  subtitle: 'Classes, hobbies, and personal interests to explore',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Explore New Passions',
                      subtitle: 'Discover interests beyond military life',
                      icon: Icons.explore_outlined,
                      tips: const [
                        TipCard(title: 'Why Try New Things?', content: 'Military life often limited time for hobbies. Now you have the freedom to explore. Finding passions brings purpose and joy.', keyPoints: ['No more waiting', 'Low stakes - just try', 'It\'s about exploration']),
                        TipCard(title: 'Physical Activities', content: 'Many veterans thrive with physical challenges. Consider hiking, martial arts, CrossFit, or team sports.', keyPoints: ['Maintains fitness', 'Community aspect', 'Healthy competition']),
                        TipCard(title: 'Creative Pursuits', content: 'Art, music, writing, and woodworking can be therapeutic and fulfilling. Many veteran programs offer free classes.', keyPoints: ['Expression outlet', 'Often veteran-specific groups', 'No experience needed']),
                        TipCard(title: 'Learning & Growth', content: 'Take classes in anything that interests you. Languages, cooking, technology, finance - education benefits may cover some.', keyPoints: ['Community colleges', 'Online courses', 'Veteran discounts common']),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Family Lifeskills',
                  subtitle: 'Parenting, relationships, and family tools',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Family Life Skills',
                      subtitle: 'Build stronger family connections',
                      icon: Icons.family_restroom_outlined,
                      tips: const [
                        TipCard(title: 'Reconnecting After Service', content: 'Relationships may have changed during your service. Be patient with yourself and family members as you reconnect.', keyPoints: ['Give it time', 'Communicate openly', 'Seek counseling if needed']),
                        TipCard(title: 'Parenting Transitions', content: 'Adjusting to civilian parenting can be challenging. Your kids may need time to adjust to having you more present.', keyPoints: ['Be consistent', 'Quality time matters', 'Match parent partner\'s style']),
                        TipCard(title: 'Relationship Maintenance', content: 'Military life stresses relationships. Invest in your partnership with regular check-ins, date nights, and shared goals.', keyPoints: ['Schedule couple time', 'Listen actively', 'Consider couples counseling']),
                        TipCard(title: 'Managing Conflict', content: 'Use communication skills from your service. Stay calm, listen first, and focus on solutions rather than blame.', keyPoints: ['Cool down before discussing', 'Use "I" statements', 'Find compromise']),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Vet To Entrepreneur',
                  subtitle: 'Startup guide and business resources',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResourceListScreen(
                      title: 'Veteran Entrepreneurship',
                      subtitle: 'Start and grow your own business',
                      icon: Icons.business_outlined,
                      categories: const [
                        ResourceCategory(title: 'Getting Started', icon: Icons.rocket_launch, resources: [
                          ResourceItem(title: 'Veteran Business Training', subtitle: 'Free entrepreneurship programs', icon: Icons.school, description: 'Free entrepreneurship training for veterans. Learn fundamentals of business ownership.', details: ['Free workshops available', 'Online options', 'Business plan assistance']),
                          ResourceItem(title: 'Veteran Business Support', subtitle: 'Counseling services', icon: Icons.support, description: 'Free business counseling, training, and mentoring for veteran entrepreneurs.'),
                        ]),
                        ResourceCategory(title: 'Funding', icon: Icons.attach_money, resources: [
                          ResourceItem(title: 'Veteran Business Loans', subtitle: 'Financing options', icon: Icons.account_balance, description: 'Many countries offer loan programs with favorable terms for veteran-owned businesses.', details: ['Special veteran rates', 'Reduced fees often available', 'Expedited processing']),
                          ResourceItem(title: 'Veteran Grants', subtitle: 'Non-repayable funding', icon: Icons.card_giftcard, description: 'Various organizations offer grants specifically for veteran entrepreneurs.'),
                        ]),
                        ResourceCategory(title: 'Mentorship', icon: Icons.people, resources: [
                          ResourceItem(title: 'Business Mentoring', subtitle: 'Free business mentors', icon: Icons.person, description: 'Volunteer business mentors provide free guidance. Many are veterans themselves.'),
                          ResourceItem(title: 'Veteran Entrepreneur Networks', subtitle: 'Connect with veteran business owners', icon: Icons.groups, description: 'Networks of veteran entrepreneurs offering programs, events, and community support.'),
                        ]),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Health & Wellness
            _VeteranSection(
              icon: Icons.favorite_outline,
              title: 'Health & Wellness',
              items: [
                _VeteranItem(
                  title: 'Fitness & Nutrition',
                  subtitle: 'Vet-tailored workout & diet plans',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Fitness & Nutrition',
                      subtitle: 'Stay healthy in civilian life',
                      icon: Icons.fitness_center_outlined,
                      tips: const [
                        TipCard(title: 'Adjusting Your Fitness', content: 'Military PT is intense. You may need to adjust to a sustainable civilian routine. Focus on consistency over intensity.', keyPoints: ['Find what you enjoy', 'Recovery is important', 'Set realistic goals']),
                        TipCard(title: 'Dealing with Injuries', content: 'Many veterans have service-related injuries. Work with veteran healthcare or civilian providers to adapt workouts safely.', keyPoints: ['Don\'t push through pain', 'Consider physical therapy', 'Modify, don\'t quit']),
                        TipCard(title: 'Nutrition Basics', content: 'Without DFAC meals, you control your nutrition. Focus on whole foods, adequate protein, and hydration.', keyPoints: ['Protein with every meal', 'More vegetables', 'Limit processed foods']),
                        TipCard(title: 'Veteran Fitness Programs', content: 'Many programs offer discounts or free access to veterans. Check gym, fitness, and community programs.', keyPoints: ['Community fitness programs', 'Veteran running groups', 'Local veteran fitness groups']),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Health Routine Tracker',
                  subtitle: 'Simple app to keep your health on point',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChecklistScreen(
                      title: 'Daily Health Routine',
                      subtitle: 'Build healthy habits',
                      icon: Icons.check_circle_outline,
                      categories: const [
                        ChecklistCategory(title: 'Morning', icon: Icons.wb_sunny, color: Colors.orange, items: [
                          ChecklistItem(title: 'Drink water first thing'),
                          ChecklistItem(title: 'Eat a healthy breakfast'),
                          ChecklistItem(title: 'Take medications/supplements'),
                          ChecklistItem(title: 'Brief stretch or movement'),
                        ]),
                        ChecklistCategory(title: 'Throughout Day', icon: Icons.schedule, color: Colors.blue, items: [
                          ChecklistItem(title: 'Stay hydrated'),
                          ChecklistItem(title: 'Take breaks from sitting'),
                          ChecklistItem(title: 'Get outside for fresh air'),
                          ChecklistItem(title: 'Eat balanced meals'),
                        ]),
                        ChecklistCategory(title: 'Evening', icon: Icons.nightlight, color: Colors.purple, items: [
                          ChecklistItem(title: 'Wind down routine'),
                          ChecklistItem(title: 'Limit screens before bed'),
                          ChecklistItem(title: 'Consistent bedtime'),
                        ]),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Whole Health VA',
                  subtitle: 'Integrated approach to mind and body care',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Whole Health',
                      subtitle: 'VA\'s holistic health approach',
                      icon: Icons.spa_outlined,
                      tips: const [
                        TipCard(title: 'What is Whole Health?', content: 'VA\'s Whole Health approach looks at your complete wellbeing - body, mind, and spirit - not just treating symptoms.', keyPoints: ['Patient-centered care', 'You set the goals', 'More than medications']),
                        TipCard(title: 'The 8 Areas', content: 'Whole Health covers 8 areas: sleep, nutrition, movement, relationships, spirit, environment, personal development, and mind-body.', keyPoints: ['All areas connected', 'Work on what matters to you', 'Small changes add up']),
                        TipCard(title: 'Getting Started', content: 'Ask your veteran healthcare team about holistic health approaches. Take a personal health inventory to identify your priorities.', keyPoints: ['Talk to your care team', 'Online resources available', 'Wellness coaching offered']),
                        TipCard(title: 'Available Programs', content: 'Many veteran services offer yoga, tai chi, meditation, nutrition counseling, health coaching, and more - often at no cost.', keyPoints: ['Free to veterans', 'In-person and virtual', 'Community classes too']),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Finances & Benefits
            _VeteranSection(
              icon: Icons.account_balance_outlined,
              title: 'Finances & Benefits',
              items: [
                _VeteranItem(
                  title: 'Financial Maximizer',
                  subtitle: 'Vet-specific advice to optimize your finances',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Financial Planning',
                      subtitle: 'Maximize your veteran benefits and income',
                      icon: Icons.attach_money_outlined,
                      tips: const [
                        TipCard(title: 'Know Your Benefits', content: 'Many veterans don\'t use all their earned benefits. Review disability compensation, education, healthcare, and loan benefits available in your country.', keyPoints: ['Check your entitlements', 'Education benefits often available', 'Veteran healthcare is earned']),
                        TipCard(title: 'TSP Management', content: 'Your TSP is portable. You can leave it, roll it to IRA, or combine with new employer 401k. Consider long-term strategy.', keyPoints: ['Don\'t cash out - penalties!', 'Review allocation', 'Consider Roth conversion']),
                        TipCard(title: 'Tax Benefits', content: 'Veterans have specific tax advantages. Disability compensation is tax-free. Some states exempt military retirement from taxes.', keyPoints: ['Disability = tax-free', 'Check state benefits', 'Property tax exemptions possible']),
                        TipCard(title: 'Credit Building', content: 'Good credit opens doors. Check your credit report annually, dispute errors, and build positive history.', keyPoints: ['Free credit reports', 'SCRA protections may apply', 'Many veteran credit programs']),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Veteran Benefits',
                  subtitle: 'Tools to stay current and maximize your benefits',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResourceListScreen(
                      title: 'Benefits Overview',
                      subtitle: 'Know and use your earned benefits',
                      icon: Icons.card_membership_outlined,
                      categories: const [
                        ResourceCategory(title: 'Healthcare', icon: Icons.local_hospital, resources: [
                          ResourceItem(title: 'Veteran Healthcare', subtitle: 'Medical coverage', icon: Icons.health_and_safety, description: 'Comprehensive healthcare for enrolled veterans. Check your government veteran services portal.'),
                          ResourceItem(title: 'Dental & Vision', subtitle: 'Additional coverage', icon: Icons.visibility, description: 'Check what dental and vision coverage is available through your veteran services.'),
                        ]),
                        ResourceCategory(title: 'Education', icon: Icons.school, resources: [
                          ResourceItem(title: 'Education Benefits', subtitle: 'Learning support', icon: Icons.school, description: 'Many countries offer education benefits for veterans. Use for college, trade school, or apprenticeships.'),
                          ResourceItem(title: 'Voc Rehab', subtitle: 'Career training', icon: Icons.work, description: 'VR&E (Chapter 31) for service-connected veterans seeking employment.'),
                        ]),
                        ResourceCategory(title: 'Financial', icon: Icons.attach_money, resources: [
                          ResourceItem(title: 'Home Loan Benefits', subtitle: 'Housing support', icon: Icons.home, description: 'Many countries offer veteran home loan programs with favorable terms. Check your local veteran services.'),
                          ResourceItem(title: 'Disability Compensation', subtitle: 'Monthly payments', icon: Icons.payments, description: 'Tax-free monthly payments for service-connected conditions.'),
                        ]),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Retirement Resources',
                  subtitle: 'Pension options, TSP, and estate planning',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Retirement Planning',
                      subtitle: 'Secure your financial future',
                      icon: Icons.savings_outlined,
                      tips: const [
                        TipCard(title: 'Military Pension', content: 'If you served 20+ years, your pension is guaranteed income for life. Understand your options for survivor benefits.', keyPoints: ['Survivor Benefit Plan options', 'COLA adjustments', 'Taxable in most states']),
                        TipCard(title: 'TSP Options', content: 'Your TSP can stay where it is, roll to IRA, or combine with new employer plan. Consider fees and investment options.', keyPoints: ['TSP has very low fees', 'IRAs offer more flexibility', 'Don\'t cash out early']),
                        TipCard(title: 'Veteran Pension', content: 'Low-income wartime veterans may qualify for pension benefits. Separate from disability compensation.', keyPoints: ['Income-based', 'Wartime service often required', 'Additional support may be available']),
                        TipCard(title: 'Estate Planning', content: 'Ensure your wishes are documented. Create or update will, designate beneficiaries, and consider trust options.', keyPoints: ['Update beneficiaries', 'Power of attorney', 'Healthcare directives']),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Veteran Events & Activities
            _VeteranSection(
              icon: Icons.event_outlined,
              title: 'Veteran Events & Activities',
              items: [
                _VeteranItem(
                  title: 'Local Vet Meetups',
                  subtitle: 'Event list by city and interests',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResourceListScreen(
                      title: 'Local Meetups',
                      subtitle: 'Find veteran groups and events in your area',
                      icon: Icons.groups_outlined,
                      categories: const [
                        ResourceCategory(title: 'Regular Events', icon: Icons.calendar_today, resources: [
                          ResourceItem(title: 'Coffee & Conversation', subtitle: 'Casual meetups', icon: Icons.coffee, description: 'Informal gatherings at local coffee shops. No agenda, just connection.', details: ['Check local veteran posts', 'Veteran community chapters', 'Social media groups']),
                          ResourceItem(title: 'Fitness Groups', subtitle: 'Stay active together', icon: Icons.fitness_center, description: 'Running clubs, fitness groups, and outdoor activities for veterans.', details: ['Veteran fitness organizations', 'Community service groups', 'Local gym veteran groups']),
                        ]),
                        ResourceCategory(title: 'Finding Events', icon: Icons.event, resources: [
                          ResourceItem(title: 'Veteran Organizations', subtitle: 'Local veteran groups', icon: Icons.groups, description: 'Traditional veteran service organizations host regular events and meetings.'),
                          ResourceItem(title: 'Online Platforms', subtitle: 'Find local events', icon: Icons.computer, description: 'Social media groups and organization websites list local events.'),
                        ]),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Vet-Friendly Conferences',
                  subtitle: 'Learn & network with other vets',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TipCardsScreen(
                      title: 'Veteran Conferences',
                      subtitle: 'Network and learn with fellow veterans',
                      icon: Icons.groups_outlined,
                      tips: const [
                        TipCard(title: 'Why Attend?', content: 'Veteran conferences offer networking, job opportunities, education, and community. Many offer free or discounted registration.', keyPoints: ['Career opportunities', 'Continuing education', 'Make connections']),
                        TipCard(title: 'Major Conferences', content: 'Veteran employment summits, entrepreneur events, and industry-specific veteran conferences.', keyPoints: ['Annual events', 'Regional options', 'Virtual attendance often available']),
                        TipCard(title: 'Getting the Most Out', content: 'Set goals before attending. Who do you want to meet? What do you want to learn? Follow up after.', keyPoints: ['Prepare talking points', 'Bring business cards', 'Follow up within a week']),
                      ],
                    )),
                  ),
                ),
                _VeteranItem(
                  title: 'Sports & Adventure',
                  subtitle: 'Outdoor trips and veteran rec leagues',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResourceListScreen(
                      title: 'Sports & Adventure',
                      subtitle: 'Stay active with fellow veterans',
                      icon: Icons.terrain_outlined,
                      categories: const [
                        ResourceCategory(title: 'Outdoor Adventures', icon: Icons.hiking, resources: [
                          ResourceItem(title: 'Veterans Expeditions', subtitle: 'Outdoor challenges', icon: Icons.terrain, description: 'Hiking, climbing, kayaking, and adventure trips designed for veterans.', details: ['Often free or subsidized', 'All skill levels', 'Therapeutic benefits']),
                          ResourceItem(title: 'Fishing & Hunting', subtitle: 'Traditional outdoor sports', icon: Icons.water, description: 'Many programs offer free licenses and organized trips for veterans.'),
                        ]),
                        ResourceCategory(title: 'Team Sports', icon: Icons.sports, resources: [
                          ResourceItem(title: 'Veteran Leagues', subtitle: 'Team competition', icon: Icons.sports_baseball, description: 'Softball, flag football, basketball, and other team sports for veterans.'),
                          ResourceItem(title: 'Adaptive Sports', subtitle: 'For all abilities', icon: Icons.accessibility, description: 'Programs for veterans with disabilities including wheelchair sports, sled hockey, and more.'),
                        ]),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Side by side cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _VeteranCompactSection(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Volunteer & Community',
                    items: [
                      _VeteranItem(
                        title: 'Ways to Volunteer',
                        subtitle: 'Opportunities to serve your community',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourceListScreen(
                            title: 'Volunteer Opportunities',
                            subtitle: 'Continue serving in your community',
                            icon: Icons.volunteer_activism_outlined,
                            categories: const [
                              ResourceCategory(title: 'Veteran-Focused', icon: Icons.military_tech, resources: [
                                ResourceItem(title: 'Mentor Other Vets', subtitle: 'Share your experience', icon: Icons.people, description: 'Help transitioning service members navigate civilian life.'),
                                ResourceItem(title: 'Honor Guard', subtitle: 'Veteran ceremonies', icon: Icons.flag, description: 'Participate in military funeral honors and ceremonies.'),
                              ]),
                              ResourceCategory(title: 'Community', icon: Icons.location_city, resources: [
                                ResourceItem(title: 'Community Service Projects', subtitle: 'Local volunteering', icon: Icons.groups, description: 'Veteran-led community service projects in cities and towns.'),
                                ResourceItem(title: 'Disaster Response', subtitle: 'Emergency volunteering', icon: Icons.emergency, description: 'Deploy military skills for disaster relief operations.'),
                              ]),
                            ],
                          )),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Mentorship Programs',
                        subtitle: 'Guide vets and youth through transition',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourceListScreen(
                            title: 'Mentorship',
                            subtitle: 'Share your experience with others',
                            icon: Icons.supervisor_account_outlined,
                            categories: const [
                              ResourceCategory(title: 'Programs', icon: Icons.people, resources: [
                                ResourceItem(title: 'Corporate Mentoring', subtitle: 'Career mentoring', icon: Icons.work, description: 'Connect with corporate mentors for career guidance. Many organizations match veterans with industry professionals.'),
                                ResourceItem(title: 'Veterati', subtitle: 'Veteran-to-veteran', icon: Icons.phone, description: 'Phone-based mentoring connecting veterans across the country.'),
                              ]),
                            ],
                          )),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Veteran Outreach',
                        subtitle: 'Help those struggling the most',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Veteran Outreach',
                            subtitle: 'How to help struggling veterans',
                            icon: Icons.handshake_outlined,
                            tips: const [
                              TipCard(title: 'Recognize the Signs', content: 'Isolation, substance use, hopelessness, anger, and neglecting responsibilities can indicate a veteran is struggling.', keyPoints: ['Trust your instincts', 'Don\'t ignore warning signs', 'Better to reach out than not']),
                              TipCard(title: 'How to Approach', content: 'Be direct but caring. Express concern without judgment. Offer to help, not to fix.', keyPoints: ['Check in regularly', 'Listen more than talk', 'Be patient']),
                              TipCard(title: 'Resources to Share', content: 'Your local veteran crisis line, veteran centres, and peer support programs are good starting points.', keyPoints: ['Know the crisis line', 'Offer to make the call together', 'Follow up']),
                            ],
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VeteranCompactSection(
                    icon: Icons.computer_outlined,
                    title: 'VetTech & Employment',
                    items: [
                      _VeteranItem(
                        title: 'VetTech Training',
                        subtitle: 'Best schools and free enrollment advice',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourceListScreen(
                            title: 'Tech Training',
                            subtitle: 'Build skills in high-demand tech fields',
                            icon: Icons.computer_outlined,
                            categories: const [
                              ResourceCategory(title: 'Veteran Programs', icon: Icons.school, resources: [
                                ResourceItem(title: 'Tech Training Programs', subtitle: 'Tuition-free tech training', icon: Icons.code, description: 'Many veteran services offer funded tech bootcamps and training programs.', details: ['Check local veteran services', 'Living support often included', 'Many approved providers']),
                              ]),
                              ResourceCategory(title: 'Bootcamps', icon: Icons.laptop, resources: [
                                ResourceItem(title: 'Coding Bootcamps', subtitle: 'Learn to code', icon: Icons.developer_mode, description: 'Intensive programs teaching web development, data science, and cybersecurity.'),
                                ResourceItem(title: 'IT Certifications', subtitle: 'Industry credentials', icon: Icons.verified, description: 'CompTIA, AWS, Microsoft, and other certifications valued by employers.'),
                              ]),
                            ],
                          )),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Job Boards & Apps',
                        subtitle: 'Veteran-focused job sites and apps',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourceListScreen(
                            title: 'Job Resources',
                            subtitle: 'Veteran-friendly job search tools',
                            icon: Icons.work_outline,
                            categories: const [
                              ResourceCategory(title: 'Job Boards', icon: Icons.search, resources: [
                                ResourceItem(title: 'Veteran Job Placement', subtitle: 'Free job placement', icon: Icons.work, description: 'Free career coaching and job placement services for veterans and spouses available in many countries.'),
                                ResourceItem(title: 'Military.com', subtitle: 'Job listings', icon: Icons.list, description: 'Large job board with veteran-friendly employer listings.'),
                              ]),
                            ],
                          )),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Networking Tips',
                        subtitle: 'Build your professional network',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Networking',
                            subtitle: 'Build connections that lead to opportunities',
                            icon: Icons.connect_without_contact_outlined,
                            tips: const [
                              TipCard(title: 'Start with Fellow Vets', content: 'Veterans help veterans. Start networking within the veteran community where trust is built-in.', keyPoints: ['Join vet organizations', 'Attend vet events', 'Use LinkedIn veteran groups']),
                              TipCard(title: 'Be Helpful First', content: 'Networking is about relationships, not transactions. Help others before asking for help.', keyPoints: ['Share information', 'Make introductions', 'Be genuinely interested']),
                              TipCard(title: 'Follow Up', content: 'After meeting someone, follow up within 48 hours. Connect on LinkedIn with a personalized note.', keyPoints: ['Send thank you notes', 'Reference your conversation', 'Stay in touch']),
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
            
            // Another side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _VeteranCompactSection(
                    icon: Icons.self_improvement_outlined,
                    title: 'Mindfulness & Calm',
                    items: [
                      _VeteranItem(
                        title: 'Breathing Exercises',
                        subtitle: 'Quick stress relief',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BreathingScreen()),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Civilian Skills Translator',
                        subtitle: 'Translate your experience',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SkillsTranslatorScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VeteranCompactSection(
                    icon: Icons.gavel_outlined,
                    title: 'Legacy Planning',
                    items: [
                      _VeteranItem(
                        title: 'Estate Planning',
                        subtitle: 'Manage wills, trusts, and survivor benefits',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChecklistScreen(
                            title: 'Estate Planning',
                            subtitle: 'Secure your family\'s future',
                            icon: Icons.gavel_outlined,
                            categories: const [
                              ChecklistCategory(title: 'Essential Documents', icon: Icons.description, color: Colors.blue, items: [
                                ChecklistItem(title: 'Will created or updated'),
                                ChecklistItem(title: 'Power of attorney designated'),
                                ChecklistItem(title: 'Healthcare directive completed'),
                                ChecklistItem(title: 'Beneficiaries updated on accounts'),
                              ]),
                              ChecklistCategory(title: 'Military-Specific', icon: Icons.military_tech, color: Colors.green, items: [
                                ChecklistItem(title: 'SBP election reviewed'),
                                ChecklistItem(title: 'DD-214 stored safely'),
                                ChecklistItem(title: 'Veteran benefits documented'),
                              ]),
                            ],
                          )),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Veteran Memorials',
                        subtitle: "Honor and remember those we've lost",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Veteran Memorials',
                            subtitle: 'Honoring service and sacrifice',
                            icon: Icons.flag_outlined,
                            tips: const [
                              TipCard(title: 'Military Cemeteries', content: 'Many countries offer veterans burial in military cemeteries at no cost. Often includes headstone, opening/closing, and perpetual care.', keyPoints: ['Free to eligible veterans', 'Multiple locations available', 'Family may be eligible too']),
                              TipCard(title: 'Memorial Benefits', content: 'Even if not buried in military cemetery, veterans may be eligible for headstone, marker, or medallion through veteran services.', keyPoints: ['Apply through veteran services', 'No deadline typically', 'Shipping often included']),
                            ],
                          )),
                        ),
                      ),
                      _VeteranItem(
                        title: 'Veteran History Projects',
                        subtitle: 'Get involved in preserving military history',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TipCardsScreen(
                            title: 'Preserve History',
                            subtitle: 'Your service is part of history',
                            icon: Icons.history_edu_outlined,
                            tips: const [
                              TipCard(title: 'Veterans History Project', content: 'Library of Congress collects and preserves veteran stories. You can submit your own or interview other veterans.', keyPoints: ['Free to participate', 'Written, audio, or video', 'Preserved forever']),
                              TipCard(title: 'StoryCorps', content: 'Record conversations about military service that become part of the American Folklife Center.', keyPoints: ['Easy recording process', 'Shareable with family', 'National archive']),
                              TipCard(title: 'Local Museums', content: 'Many local museums collect military artifacts and stories. Consider donating or volunteering.', keyPoints: ['Connect with local history', 'Educate next generation', 'Preserve memorabilia']),
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
            
            // Crisis Support
            _VeteranSection(
              icon: Icons.health_and_safety_outlined,
              title: 'Crisis & Support Access',
              items: [
                _VeteranItem(
                  title: "When You're Not OK",
                  subtitle: 'Clear, calm support pathways',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
                  ),
                ),
                _VeteranItem(
                  title: 'Crisis Support Line',
                  subtitle: 'Immediate support available 24/7',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
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

class _VeteranSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_VeteranItem> items;
  
  const _VeteranSection({
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
  
  Widget _buildItem(BuildContext context, _VeteranItem item) {
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

class _VeteranCompactSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_VeteranItem> items;
  
  const _VeteranCompactSection({
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
  
  Widget _buildCompactItem(BuildContext context, _VeteranItem item) {
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

class _VeteranItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _VeteranItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
