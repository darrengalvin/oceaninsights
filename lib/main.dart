import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/providers/user_provider.dart';
import 'core/providers/mood_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/content_service.dart';
import 'core/services/ui_sound_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scenarios/services/scenario_service.dart';
import 'features/scenarios/models/user_response_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserResponseProfileAdapter());
  
  await Hive.openBox('user_data');
  await Hive.openBox('mood_entries');
  await Hive.openBox('settings');
  
  // Initialise content service (handles Supabase + caching)
  await ContentService.instance.init();
  
  // Initialise scenario service
  await ScenarioService.instance.initialize();
  
  // Initialise UI sound service
  await UISoundService().initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const OceanInsightApp());
}

class OceanInsightApp extends StatelessWidget {
  const OceanInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: ScenarioService.instance),
      ],
      child: Consumer2<UserProvider, ThemeProvider>(
        builder: (context, userProvider, themeProvider, _) {
          // Determine if the current theme is light or dark
          final isLightTheme = themeProvider.themeData.brightness == Brightness.light;
          
          // Update system UI based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isLightTheme ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: themeProvider.themeData.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness: isLightTheme ? Brightness.dark : Brightness.light,
            ),
          );
          
          return MaterialApp(
            title: 'Ocean Insight',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            darkTheme: themeProvider.themeData,
            themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
            home: SplashScreen(
              nextScreen: userProvider.isOnboarded 
                  ? const HomeScreen() 
                  : const OnboardingScreen(),
            ),
          );
        },
      ),
    );
  }
}
