import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/providers/user_provider.dart';
import 'core/providers/mood_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('user_data');
  await Hive.openBox('mood_entries');
  await Hive.openBox('settings');
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const DeepDiveApp());
}

class DeepDiveApp extends StatelessWidget {
  const DeepDiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<UserProvider, ThemeProvider>(
        builder: (context, userProvider, themeProvider, _) {
          // Update system UI based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: themeProvider.themeData.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
          );
          
          return MaterialApp(
            title: 'Deep Dive',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            darkTheme: themeProvider.themeData,
            themeMode: ThemeMode.dark,
            home: userProvider.isOnboarded 
                ? const HomeScreen() 
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
