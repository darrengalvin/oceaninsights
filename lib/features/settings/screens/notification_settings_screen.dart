import 'package:flutter/material.dart';
import '../../../core/theme/theme_options.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/ui_sound_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final service = NotificationService();
    setState(() {
      _isAvailable = service.isAvailable;
      _notificationsEnabled = service.isEnabled;
      _selectedTime = service.scheduledTime;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _isLoading = true);
    
    await NotificationService().setEnabled(enabled);
    UISoundService().playClick();
    
    setState(() {
      _notificationsEnabled = NotificationService().isEnabled;
      _isLoading = false;
    });

    if (enabled && !_notificationsEnabled) {
      // Permission was denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable notifications in your device settings'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectTime() async {
    final colours = context.colours;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colours.accent,
              surface: colours.card,
              onSurface: colours.textBright,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      UISoundService().playClick();
      setState(() => _selectedTime = picked);
      await NotificationService().setNotificationTime(picked);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Affirmation time set to ${_formatTime(picked)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    UISoundService().playClick();
    await NotificationService().sendTestNotification();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Show warning if not available
          if (!_isAvailable) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifications require a full app restart to enable. Please close and reopen the app.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colours.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 32,
                    color: colours.accent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Daily Affirmations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Receive a positive affirmation every day to start your morning right',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colours.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Enable/Disable Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _notificationsEnabled 
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: colours.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Notifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _notificationsEnabled ? 'Enabled' : 'Disabled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colours.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colours.accent,
                    ),
                  )
                else
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: colours.accent,
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Time Picker
          AnimatedOpacity(
            opacity: _notificationsEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _notificationsEnabled ? _selectTime : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colours.border.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colours.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: colours.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Time',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatTime(_selectedTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colours.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colours.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test Notification Button
          if (_notificationsEnabled) ...[
            GestureDetector(
              onTap: _sendTestNotification,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colours.accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      color: colours.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Send Test Notification',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colours.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
          
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colours.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A random affirmation from our collection will be sent at your chosen time each day. Perfect for starting your morning with positivity.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
