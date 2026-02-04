import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';

/// Interactive Skills Translator - MOS/Military role to civilian jobs
class SkillsTranslatorScreen extends StatefulWidget {
  const SkillsTranslatorScreen({super.key});

  @override
  State<SkillsTranslatorScreen> createState() => _SkillsTranslatorScreenState();
}

class _SkillsTranslatorScreenState extends State<SkillsTranslatorScreen> {
  String? _selectedCategory;
  String? _selectedRole;
  List<_CivilianJob> _matchedJobs = [];
  bool _showResults = false;
  
  final Map<String, List<String>> _militaryRoles = {
    'Combat Arms': [
      'Infantry',
      'Armor/Cavalry',
      'Artillery',
      'Combat Engineer',
      'Special Operations',
    ],
    'Combat Support': [
      'Military Police',
      'Intelligence',
      'Signal/Communications',
      'Civil Affairs',
      'Psychological Operations',
    ],
    'Combat Service Support': [
      'Logistics/Supply',
      'Transportation',
      'Medical/Healthcare',
      'Human Resources',
      'Finance',
    ],
    'Technical': [
      'IT/Cyber',
      'Aviation Maintenance',
      'Weapons Systems',
      'Electronics',
      'Nuclear/Chemical',
    ],
    'Leadership': [
      'Platoon Leader/Sergeant',
      'Company Commander/1SG',
      'Staff Officer/NCO',
      'Training Instructor',
      'Recruiter',
    ],
  };
  
  final Map<String, List<_CivilianJob>> _jobMappings = {
    'Infantry': [
      _CivilianJob('Security Manager', 'Oversee security operations and teams', 85, ['Leadership', 'Risk Assessment', 'Team Management']),
      _CivilianJob('Law Enforcement Officer', 'Police, federal agent, or corrections', 80, ['Physical Fitness', 'Decision Making', 'Crisis Response']),
      _CivilianJob('Emergency Management', 'Coordinate disaster response', 78, ['Planning', 'Coordination', 'Stress Management']),
      _CivilianJob('Corporate Security Director', 'Lead security for organizations', 75, ['Leadership', 'Strategy', 'Risk Management']),
    ],
    'Military Police': [
      _CivilianJob('Police Officer', 'Local or state law enforcement', 92, ['Law Enforcement', 'Investigation', 'Report Writing']),
      _CivilianJob('Federal Agent', 'FBI, DEA, ATF, or similar', 88, ['Investigation', 'Firearms', 'Security Clearance']),
      _CivilianJob('Corporate Security', 'Private sector security management', 82, ['Security Operations', 'Risk Assessment']),
      _CivilianJob('Loss Prevention Manager', 'Retail/corporate loss prevention', 75, ['Investigation', 'Surveillance', 'Reporting']),
    ],
    'Intelligence': [
      _CivilianJob('Intelligence Analyst', 'Government or private sector analysis', 95, ['Analysis', 'Security Clearance', 'Research']),
      _CivilianJob('Cybersecurity Analyst', 'Protect digital assets', 85, ['Threat Analysis', 'Security', 'Technical Skills']),
      _CivilianJob('Business Intelligence', 'Corporate data analysis', 80, ['Data Analysis', 'Reporting', 'Strategy']),
      _CivilianJob('Risk Analyst', 'Assess organizational risks', 78, ['Assessment', 'Critical Thinking', 'Communication']),
    ],
    'Logistics/Supply': [
      _CivilianJob('Supply Chain Manager', 'Oversee logistics operations', 92, ['Logistics', 'Planning', 'Vendor Management']),
      _CivilianJob('Operations Manager', 'Manage business operations', 88, ['Operations', 'Team Leadership', 'Process Improvement']),
      _CivilianJob('Warehouse Manager', 'Manage distribution centers', 85, ['Inventory', 'Logistics', 'Team Management']),
      _CivilianJob('Procurement Specialist', 'Manage purchasing and contracts', 80, ['Negotiation', 'Contracts', 'Vendor Relations']),
    ],
    'Medical/Healthcare': [
      _CivilianJob('Registered Nurse', 'Hospital or clinical nursing', 90, ['Patient Care', 'Medical Knowledge', 'Emergency Response']),
      _CivilianJob('EMT/Paramedic', 'Emergency medical services', 92, ['Emergency Care', 'Medical Procedures', 'Quick Thinking']),
      _CivilianJob('Healthcare Administrator', 'Manage healthcare facilities', 78, ['Administration', 'Healthcare Knowledge', 'Leadership']),
      _CivilianJob('Medical Sales', 'Sell medical equipment/pharma', 72, ['Medical Knowledge', 'Communication', 'Sales']),
    ],
    'IT/Cyber': [
      _CivilianJob('Cybersecurity Engineer', 'Protect networks and systems', 95, ['Security', 'Networks', 'Programming']),
      _CivilianJob('Systems Administrator', 'Manage IT infrastructure', 90, ['Systems', 'Networks', 'Troubleshooting']),
      _CivilianJob('Network Engineer', 'Design and maintain networks', 88, ['Networking', 'Security', 'Technical']),
      _CivilianJob('IT Project Manager', 'Lead technology projects', 82, ['Project Management', 'Technical', 'Leadership']),
    ],
    'Training Instructor': [
      _CivilianJob('Corporate Trainer', 'Develop and deliver training programs', 90, ['Training', 'Communication', 'Curriculum Development']),
      _CivilianJob('HR Learning & Development', 'Manage organizational training', 85, ['Training', 'HR', 'Program Management']),
      _CivilianJob('Teacher/Educator', 'K-12 or higher education', 80, ['Teaching', 'Communication', 'Patience']),
      _CivilianJob('Fitness Instructor', 'Personal training or group fitness', 75, ['Fitness', 'Motivation', 'Communication']),
    ],
  };

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
          'Skills Translator',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _showResults ? _buildResults() : _buildSelector(),
    );
  }
  
  Widget _buildSelector() {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What was your role?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select your military specialty area and role.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          
          // Category selector
          Text(
            'Category',
            style: TextStyle(
              color: colours.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _militaryRoles.keys.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  setState(() {
                    _selectedCategory = category;
                    _selectedRole = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colours.accent : colours.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colours.accent : colours.border,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colours.textBright,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (_selectedCategory != null) ...[
            const SizedBox(height: 32),
            Text(
              'Role',
              style: TextStyle(
                color: colours.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...(_militaryRoles[_selectedCategory] ?? []).map((role) {
              final isSelected = _selectedRole == role;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    UISoundService().playClick();
                    setState(() => _selectedRole = role);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? colours.accent.withOpacity(0.15)
                          : colours.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? colours.accent : colours.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            role,
                            style: TextStyle(
                              color: colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: colours.accent),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          
          const SizedBox(height: 32),
          
          // Translate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedRole != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      _translateSkills();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colours.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Find Matching Jobs',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _translateSkills() {
    // Get matching jobs or use defaults
    final jobs = _jobMappings[_selectedRole] ?? [
      _CivilianJob('Project Manager', 'Lead and coordinate projects', 75, ['Leadership', 'Planning', 'Communication']),
      _CivilianJob('Operations Supervisor', 'Manage teams and operations', 72, ['Leadership', 'Operations', 'Team Building']),
      _CivilianJob('Consultant', 'Advise organizations on strategy', 68, ['Problem Solving', 'Communication', 'Analysis']),
    ];
    
    setState(() {
      _matchedJobs = jobs;
      _showResults = true;
    });
  }
  
  Widget _buildResults() {
    final colours = context.colours;
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          color: colours.accent.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.military_tech_rounded, color: colours.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedRole ?? '',
                      style: TextStyle(
                        color: colours.textBright,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _selectedCategory ?? '',
                      style: TextStyle(
                        color: colours.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showResults = false;
                    _selectedRole = null;
                    _selectedCategory = null;
                  });
                },
                child: Text(
                  'Change',
                  style: TextStyle(color: colours.accent),
                ),
              ),
            ],
          ),
        ),
        
        // Results
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _matchedJobs.length,
            itemBuilder: (context, index) {
              final job = _matchedJobs[index];
              return _buildJobCard(job);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildJobCard(_CivilianJob job) {
    final colours = context.colours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and match percentage
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getMatchColor(job.matchPercentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${job.matchPercentage}% match',
                  style: TextStyle(
                    color: _getMatchColor(job.matchPercentage),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            job.description,
            style: TextStyle(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          
          // Skills
          Text(
            'Transferable Skills:',
            style: TextStyle(
              color: colours.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: job.skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  color: colours.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showJobDetails(job);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colours.accent,
                side: BorderSide(color: colours.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Learn More'),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getMatchColor(int percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.blue;
  }
  
  void _showJobDetails(_CivilianJob job) {
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
              
              Text(
                job.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                job.description,
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Next Steps',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildNextStep('1', 'Research job requirements and certifications'),
              _buildNextStep('2', 'Update resume with military-to-civilian language'),
              _buildNextStep('3', 'Connect with veterans in this field'),
              _buildNextStep('4', 'Apply for relevant positions'),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colours.accent,
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
  
  Widget _buildNextStep(String number, String text) {
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
}

class _CivilianJob {
  final String title;
  final String description;
  final int matchPercentage;
  final List<String> skills;
  
  const _CivilianJob(this.title, this.description, this.matchPercentage, this.skills);
}
