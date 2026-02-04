import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/analytics_service.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _analyticsEnabled = !AnalyticsService().isOptedOut;
  }

  Future<void> _toggleAnalytics(bool value) async {
    HapticFeedback.lightImpact();
    if (value) {
      await AnalyticsService().optIn();
    } else {
      await AnalyticsService().optOut();
    }
    setState(() {
      _analyticsEnabled = value;
    });
  }

  Future<void> _clearAllData(BuildContext context) async {
    final colours = context.colours;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(colours: colours),
    );
    
    if (confirmed != true) return;
    
    // Show loading indicator
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: colours.accent),
                const SizedBox(height: 16),
                Text(
                  'Deleting data...',
                  style: TextStyle(color: colours.textBright),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    try {
      // Clear analytics data from server
      await AnalyticsService().clearAnalyticsData();
      
      // Clear all Hive boxes
      await Hive.deleteFromDisk();
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.pop(context);
        
        // Show success and exit app
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: colours.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green[400]),
                const SizedBox(width: 12),
                Text(
                  'Data Deleted',
                  style: TextStyle(color: colours.textBright),
                ),
              ],
            ),
            content: Text(
              'All your data has been permanently deleted.\n\n'
              'Please restart the app to continue with a fresh start.',
              style: TextStyle(color: colours.textLight, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Close dialog and restart app
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Restart App',
                  style: TextStyle(color: colours.background),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.storage_rounded, color: colours.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data is stored locally on this device',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colours.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // What's stored section
            Text(
              'What\'s Stored on Your Device',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colours.textBright,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildDataItem(
              context,
              Icons.mood_rounded,
              'Mood History',
              'Your mood check-ins and patterns',
            ),
            _buildDataItem(
              context,
              Icons.flag_rounded,
              'Goals',
              'Your saved goals and progress',
            ),
            _buildDataItem(
              context,
              Icons.check_circle_outline_rounded,
              'Ritual Completions',
              'Your daily ritual progress',
            ),
            _buildDataItem(
              context,
              Icons.settings_rounded,
              'Preferences',
              'Theme, sounds, and other settings',
            ),
            _buildDataItem(
              context,
              Icons.person_outline_rounded,
              'Profile',
              'User type and age bracket',
            ),
            
            const SizedBox(height: 24),
            
            // Analytics toggle
            Text(
              'Anonymous Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colours.textBright,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help improve the app',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: colours.textBright,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Share anonymous usage data (no personal info)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colours.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _analyticsEnabled,
                    onChanged: _toggleAnalytics,
                    activeColor: colours.accent,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // What's NOT stored
            Text(
              'What We Don\'t Store',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colours.textBright,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotStoredItem(context, 'No personal identity (name, email)'),
                  _buildNotStoredItem(context, 'No location data'),
                  _buildNotStoredItem(context, 'No photos or media access'),
                  _buildNotStoredItem(context, 'No data sent to external servers'),
                  _buildNotStoredItem(context, 'No tracking or advertising data'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Delete section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delete_forever_rounded, color: Colors.red[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Delete All Data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This will permanently delete all your data from this device, including:\n\n'
                    '• All mood history\n'
                    '• All goals and progress\n'
                    '• All ritual completions\n'
                    '• All preferences and settings\n\n'
                    'This action cannot be undone.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.textLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _clearAllData(context),
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: const Text('Delete All My Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataItem(BuildContext context, IconData icon, String title, String subtitle) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colours.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colours.textBright,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colours.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotStoredItem(BuildContext context, String text) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_rounded, color: Colors.green[400], size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatefulWidget {
  final AppColours colours;
  
  const _DeleteConfirmationDialog({required this.colours});

  @override
  State<_DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.colours.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Confirm Deletion',
              style: TextStyle(color: widget.colours.textBright),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will permanently delete ALL your data. This cannot be undone.',
            style: TextStyle(color: widget.colours.textLight, height: 1.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Type DELETE to confirm:',
            style: TextStyle(
              color: widget.colours.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'DELETE',
              hintStyle: TextStyle(color: widget.colours.textMuted.withOpacity(0.5)),
              filled: true,
              fillColor: widget.colours.cardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyle(color: widget.colours.textBright),
            onChanged: (value) {
              setState(() {
                _canDelete = value.toUpperCase() == 'DELETE';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: widget.colours.textMuted)),
        ),
        ElevatedButton(
          onPressed: _canDelete ? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canDelete ? Colors.red[400] : widget.colours.cardLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Delete Everything',
            style: TextStyle(
              color: _canDelete ? Colors.white : widget.colours.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
