import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';

/// Interactive Career Sampler - Swipeable job preview cards
class CareerSamplerScreen extends StatefulWidget {
  const CareerSamplerScreen({super.key});

  @override
  State<CareerSamplerScreen> createState() => _CareerSamplerScreenState();
}

class _CareerSamplerScreenState extends State<CareerSamplerScreen> {
  int _currentIndex = 0;
  final List<String> _savedCareers = [];
  final PageController _pageController = PageController();
  
  final List<_CareerCard> _careers = [
    _CareerCard(
      title: 'Software Developer',
      icon: Icons.code_rounded,
      color: Colors.blue,
      salary: '\$70K - \$150K',
      education: 'Degree or Self-taught',
      dayInLife: 'Write code, solve problems, build apps and websites. Work with teams to create technology people use.',
      skills: ['Problem Solving', 'Logic', 'Creativity', 'Patience'],
      pros: ['High demand', 'Remote work options', 'Good pay', 'Always learning'],
      cons: ['Sitting a lot', 'Screen time', 'Fast-changing field'],
    ),
    _CareerCard(
      title: 'Nurse',
      icon: Icons.medical_services_rounded,
      color: Colors.red,
      salary: '\$50K - \$100K',
      education: 'Nursing Degree',
      dayInLife: 'Care for patients, give medicine, work with doctors. Help people when they are sick or injured.',
      skills: ['Empathy', 'Attention to Detail', 'Communication', 'Stamina'],
      pros: ['Meaningful work', 'Job security', 'Many specialties', 'Help others'],
      cons: ['Long shifts', 'Emotional toll', 'Physical demands'],
    ),
    _CareerCard(
      title: 'Electrician',
      icon: Icons.electric_bolt_rounded,
      color: Colors.amber,
      salary: '\$40K - \$90K',
      education: 'Trade School / Apprenticeship',
      dayInLife: 'Install and fix electrical systems in homes and buildings. Work with your hands and solve problems.',
      skills: ['Hands-on', 'Math', 'Safety', 'Problem Solving'],
      pros: ['No college debt', 'Physical work', 'Always needed', 'Own your business'],
      cons: ['Physical risk', 'Outdoor work', 'Early mornings'],
    ),
    _CareerCard(
      title: 'Graphic Designer',
      icon: Icons.palette_rounded,
      color: Colors.purple,
      salary: '\$40K - \$80K',
      education: 'Degree or Portfolio',
      dayInLife: 'Create visual designs for companies - logos, websites, ads. Use creativity to solve visual problems.',
      skills: ['Creativity', 'Software Skills', 'Communication', 'Attention to Detail'],
      pros: ['Creative freedom', 'Freelance options', 'Varied projects'],
      cons: ['Client feedback', 'Tight deadlines', 'Competitive field'],
    ),
    _CareerCard(
      title: 'Teacher',
      icon: Icons.school_rounded,
      color: Colors.green,
      salary: '\$40K - \$70K',
      education: 'Teaching Degree',
      dayInLife: 'Teach students, plan lessons, grade work. Shape young minds and make a difference.',
      skills: ['Patience', 'Communication', 'Organization', 'Creativity'],
      pros: ['Summer breaks', 'Meaningful impact', 'Job stability'],
      cons: ['Low pay (often)', 'Challenging behavior', 'Paperwork'],
    ),
    _CareerCard(
      title: 'Content Creator',
      icon: Icons.videocam_rounded,
      color: Colors.pink,
      salary: '\$0 - \$1M+',
      education: 'Self-taught',
      dayInLife: 'Create videos, posts, or content for social media. Build an audience around your interests.',
      skills: ['Creativity', 'Consistency', 'Self-promotion', 'Tech Skills'],
      pros: ['Be your own boss', 'Flexible schedule', 'Express yourself'],
      cons: ['Unstable income', 'Algorithm changes', 'Burnout risk'],
    ),
    _CareerCard(
      title: 'Physical Therapist',
      icon: Icons.accessibility_new_rounded,
      color: Colors.teal,
      salary: '\$60K - \$100K',
      education: 'Doctorate Degree',
      dayInLife: 'Help people recover from injuries. Work with athletes, elderly, and anyone needing physical rehab.',
      skills: ['Anatomy Knowledge', 'Patience', 'Communication', 'Physical Fitness'],
      pros: ['Help people heal', 'Active job', 'Growing field'],
      cons: ['Long education', 'Physical demands', 'Paperwork'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        title: Text(
          'Career Sampler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_savedCareers.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.bookmark, color: colours.accent),
                  onPressed: _showSavedCareers,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colours.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_savedCareers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(_careers.length, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex 
                          ? colours.accent 
                          : colours.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentIndex + 1} of ${_careers.length}',
            style: TextStyle(color: colours.textMuted, fontSize: 12),
          ),
          
          // Career cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _careers.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final career = _careers[index];
                final isSaved = _savedCareers.contains(career.title);
                return _buildCareerCard(career, isSaved);
              },
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip
                _ActionButton(
                  icon: Icons.close_rounded,
                  label: 'Skip',
                  color: colours.textMuted,
                  onTap: _nextCard,
                ),
                // Save
                _ActionButton(
                  icon: _savedCareers.contains(_careers[_currentIndex].title)
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  label: 'Save',
                  color: colours.accent,
                  onTap: () => _toggleSave(_careers[_currentIndex].title),
                ),
                // Learn More
                _ActionButton(
                  icon: Icons.info_outline,
                  label: 'Details',
                  color: Colors.blue,
                  onTap: () => _showDetails(_careers[_currentIndex]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCareerCard(_CareerCard career, bool isSaved) {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colours.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: career.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    career.icon,
                    color: career.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        career.salary,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSaved)
                  Icon(Icons.bookmark, color: colours.accent),
              ],
            ),
            const SizedBox(height: 20),
            
            // Education
            _buildInfoRow(Icons.school_outlined, 'Education', career.education, colours),
            const SizedBox(height: 16),
            
            // Day in life
            Text(
              'A Day in the Life',
              style: TextStyle(
                color: colours.textBright,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              career.dayInLife,
              style: TextStyle(
                color: colours.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            
            // Skills needed
            Text(
              'Skills Needed',
              style: TextStyle(
                color: colours.textBright,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: career.skills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: career.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: career.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            
            // Pros
            _buildProsCons('Pros', career.pros, Colors.green, colours),
            const SizedBox(height: 12),
            
            // Cons
            _buildProsCons('Cons', career.cons, Colors.red, colours),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, AppColours colours) {
    return Row(
      children: [
        Icon(icon, color: colours.textMuted, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: colours.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colours.textBright,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProsCons(String title, List<String> items, Color color, AppColours colours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colours.textBright,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                title == 'Pros' ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                item,
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  void _nextCard() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _careers.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _toggleSave(String title) {
    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    setState(() {
      if (_savedCareers.contains(title)) {
        _savedCareers.remove(title);
      } else {
        _savedCareers.add(title);
      }
    });
  }
  
  void _showDetails(_CareerCard career) {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colours.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Icon(career.icon, color: career.color, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    career.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Text(
                'How to Get Started',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildStep('1', 'Research the field - watch videos, read articles'),
              _buildStep('2', 'Talk to someone in this career'),
              _buildStep('3', 'Try a related activity or project'),
              _buildStep('4', 'Look into education/training options'),
              _buildStep('5', 'Consider internships or entry-level positions'),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: career.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStep(String number, String text) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: colours.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colours.textBright,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSavedCareers() {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colours.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Saved Careers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._savedCareers.map((title) {
              final career = _careers.firstWhere((c) => c.title == title);
              return ListTile(
                leading: Icon(career.icon, color: career.color),
                title: Text(career.title),
                subtitle: Text(career.salary),
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerCard {
  final String title;
  final IconData icon;
  final Color color;
  final String salary;
  final String education;
  final String dayInLife;
  final List<String> skills;
  final List<String> pros;
  final List<String> cons;
  
  const _CareerCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.salary,
    required this.education,
    required this.dayInLife,
    required this.skills,
    required this.pros,
    required this.cons,
  });
}
