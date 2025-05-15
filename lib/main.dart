import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'ffscreen/onboarding.dart';
import 'ffscreen/parent_auth.dart';
import 'ffscreen/parentform.dart';
import 'ffscreen/target_app_download_page.dart';
import 'ffscreen/email_verification_screen.dart';
import 'ffscreen/login.dart';
import './screens/main/device_selection_screen.dart';
import './screens/main/settings_screen.dart';
import './screens/main/notification_screen.dart';
import './screens/main/dashboard_screen.dart';
import './screens/main/UAT_Warning_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Radar Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/parent-auth': (context) => const ParentAuth(),
        '/parent-form': (context) => const ParentDetailsForm(),
        '/verify-email': (context) => const EmailVerificationScreen(),
        '/apk-download': (context) => const TargetAppDownloadPage(),
        '/add-device':
            (context) => DeviceSelectionScreen(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeToggle: _toggleTheme,
            ),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashB':
            (context) => DashboardScreen(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeToggle: _toggleTheme,
            ),
      },
    );
  }
}
