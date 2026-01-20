import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// User Provider
/// 
/// Manages user profile data stored locally
/// Stores: user type, age bracket, and profile answers (minimal data per privacy policy)
class UserProvider extends ChangeNotifier {
  final Box _userBox = Hive.box('user_data');
  
  String? get firstName => _userBox.get('firstName');
  String? get userType => _userBox.get('userType');
  String? get ageBracket => _userBox.get('ageBracket');
  bool get isOnboarded => _userBox.get('isOnboarded', defaultValue: false);
  
  /// User types available for selection (for statistics)
  static const List<String> userTypes = [
    'Serving',
    'Veteran', 
    'Deployed',
    'Alongside',
    'Young Person',
  ];
  
  /// Age brackets available for selection
  static const List<String> ageBrackets = [
    'Teen',
    '18-24',
    '25-30',
    '31-40',
    '40+',
  ];
  
  /// Set user's first name
  Future<void> setFirstName(String name) async {
    await _userBox.put('firstName', name.trim());
    notifyListeners();
  }
  
  /// Set user's type (Serving, Veteran, etc.)
  Future<void> setUserType(String type) async {
    await _userBox.put('userType', type);
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

