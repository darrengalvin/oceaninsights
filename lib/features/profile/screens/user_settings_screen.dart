import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  String? _selectedUserType;
  String? _selectedAgeBracket;
  
  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _selectedUserType = userProvider.userType;
    _selectedAgeBracket = userProvider.ageBracket;
  }
  
  Future<void> _saveSettings() async {
    final userProvider = context.read<UserProvider>();
    
    if (_selectedUserType != null) {
      await userProvider.setUserType(_selectedUserType!);
    }
    
    if (_selectedAgeBracket != null) {
      await userProvider.setAgeBracket(_selectedAgeBracket!);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your profile',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colours.textLight,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'I am currently...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            ...UserProvider.userTypes.map((type) => _buildRadioOption(
              type,
              _selectedUserType == type,
              () => setState(() => _selectedUserType = type),
            )),
            
            const SizedBox(height: 24),
            
            Text(
              'My age bracket',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            ...UserProvider.ageBrackets.map((bracket) => _buildRadioOption(
              bracket,
              _selectedAgeBracket == bracket,
              () => setState(() => _selectedAgeBracket = bracket),
            )),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colours.accent : colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colours.background : colours.textBright,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colours.background,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

