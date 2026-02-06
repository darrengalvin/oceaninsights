import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/providers/user_provider.dart';
import 'core/providers/mood_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/content_service.dart';
import 'core/services/content_sync_service.dart';
import 'core/services/ui_sound_service.dart';
import 'core/services/ui_preferences_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scenarios/services/scenario_service.dart';
import 'features/scenarios/models/user_response_profile.dart';
import 'features/rituals/services/ritual_service.dart';
import 'features/rituals/services/ritual_topics_service.dart';

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
  
  // Initialise ritual service
  await RitualService().initialize();
  
  // Initialise ritual topics service (new Supabase-based system)
  await RitualTopicsService().initialize();
  
  // Initialise UI preferences
  await UIPreferencesService().initialize();
  
  // Initialise UI sound service
  await UISoundService().initialize();
  
  // Initialise anonymous analytics (privacy-compliant)
  await AnalyticsService().initialize();
  
  // Initialise notification service (daily affirmations)
  await NotificationService().initialize();
  
  // Initialise content sync service and sync if online
  // This downloads all admin-managed content for offline use
  await ContentSyncService().init();
  ContentSyncService().syncAll(); // Non-blocking background sync
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const BelowTheSurfaceApp());
}

class BelowTheSurfaceApp extends StatefulWidget {
  const BelowTheSurfaceApp({super.key});

  @override
  State<BelowTheSurfaceApp> createState() => _BelowTheSurfaceAppState();
}

class _BelowTheSurfaceAppState extends State<BelowTheSurfaceApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Track session end when app goes to background/closes
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      AnalyticsService().endSession();
    }
    // Start new session when app resumes
    if (state == AppLifecycleState.resumed) {
      AnalyticsService().initialize();
      // Sync content when app resumes (user may have regained connectivity)
      ContentSyncService().syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: ScenarioService.instance),
        ChangeNotifierProvider.value(value: UIPreferencesService()),
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
            title: 'Below the Surface',
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
