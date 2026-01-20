import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// User Provider
/// 
/// Manages user profile data stored locally
/// Only stores: first name and age bracket (minimal data per privacy policy)
class UserProvider extends ChangeNotifier {
  final Box _userBox = Hive.box('user_data');
  
  String? get firstName => _userBox.get('firstName');
  String? get ageBracket => _userBox.get('ageBracket');
  bool get isOnboarded => _userBox.get('isOnboarded', defaultValue: false);
  
  /// Age brackets available for selection
  static const List<String> ageBrackets = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+',
  ];
  
  /// Set user's first name
  Future<void> setFirstName(String name) async {
    await _userBox.put('firstName', name.trim());
    notifyListeners();
  }
  
  /// Set user's age bracket
  Future<void> setAgeBracket(String bracket) async {
    await _userBox.put('ageBracket', bracket);
    notifyListeners();
  }
  
  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _userBox.put('isOnboarded', true);
    notifyListeners();
  }
  
  /// Reset all user data (for testing or user request)
  Future<void> resetUserData() async {
    await _userBox.clear();
    notifyListeners();
  }
  
  /// Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    final name = firstName ?? 'there';
    
    if (hour < 12) {
      return 'Good morning, $name';
    } else if (hour < 17) {
      return 'Good afternoon, $name';
    } else {
      return 'Good evening, $name';
    }
  }
}

