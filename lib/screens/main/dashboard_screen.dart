import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/sidebar.dart';
import '../modules/location_screen.dart';
import '../modules/geofencing_screen.dart';
import '../modules/sms_screen.dart';
import '../modules/call_screen.dart';
import '../modules/keylogger_screen.dart';
import '../modules/whatsapp_screen.dart';
import '../modules/installed_apps_screen.dart';
import '../modules/blocked_apps_screen.dart';
import '../modules/stealth_mode_screen.dart';
import '../modules/dashboard.dart';
import '/screens/feedbackforms/feedback1.dart';
import '/screens/feedbackforms/feedback2.dart';
import '../../apis/get.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late Widget _currentScreen;
  bool? isDeviceActive;
  bool isLoading = true;
  String? username;
  late Timer _statusRefreshTimer;
  bool feedback1Done = false;
  bool feedback2Done = false;

  @override
  void initState() {
    super.initState();
    _currentScreen = const Center(child: CircularProgressIndicator());
    _fetchDeviceId();
  }

  Future<void> _fetchDeviceId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        username = snapshot.docs.first.id;
      });
      await _checkFeedbackStatus(uid);
    }
  }

Future<void> _checkFeedbackStatus(String uid) async {
  final feedbackDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('feedback')
      .doc('status')
      .get();

  feedback1Done = feedbackDoc.data()?['feedback1'] == true;
  feedback2Done = feedbackDoc.data()?['feedback2'] == true;

  if (!feedback1Done) {
    setState(() {
      _currentScreen = Stack(
        children: [
          Container(
            color: widget.isDarkMode ? Colors.black : Colors.white,
          ),
          Feedback1(
            onComplete: (int selectedFeedback) async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('feedback')
                  .doc('status')
                  .set({
                    'feedback1': true,
                    'feedback1_value': selectedFeedback,
                  }, SetOptions(merge: true));
              setState(() => feedback1Done = true);
              _checkFeedbackStatus(uid);
            },
          ),
        ],
      );
    });
  } else if (!feedback2Done) {
    setState(() {
      _currentScreen = Stack(
        children: [
          Container(
            color: widget.isDarkMode ? Colors.black : Colors.white,
          ),
          Feedback2(
            onComplete: (int selectedFeedback) async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('feedback')
                  .doc('status')
                  .set({
                    'feedback2': true,
                    'feedback2_value': selectedFeedback,
                  }, SetOptions(merge: true));
              setState(() => feedback2Done = true);
              _initializeDashboard();
            },
          ),
        ],
      );
    });
  } else {
    _initializeDashboard();
  }
}



  void _initializeDashboard() {
    setState(() {
      _currentScreen = _getScreenByIndex(selectedIndex);
    });
    _fetchDeviceStatus();
    _startStatusRefreshTimer();
  }

  void _startStatusRefreshTimer() {
    _statusRefreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _fetchDeviceStatus();
    });
  }

  Future<void> _fetchDeviceStatus() async {
    if (username == null) return;

    setState(() => isLoading = true);
    try {
      final response = await fetchModuleData(
        module: 'device_codes',
        userId: username!,
      );

      final deviceData = response['data'];

      if (deviceData != null && deviceData['used'] != null) {
        setState(() {
          isDeviceActive = deviceData['used'] == true;
          isLoading = false;
        });
      } else {
        setState(() {
          isDeviceActive = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching device status: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    if (_statusRefreshTimer.isActive) {
      _statusRefreshTimer.cancel();
    }
    super.dispose();
  }

  void onSelect(int index) {
    setState(() {
      selectedIndex = index;
      _currentScreen = _getScreenByIndex(index);
    });
  }

  Widget _getScreenByIndex(int index) {
    switch (index) {
      case 0:
        return DashboardPage(username: username!, onJumpToIndex: onSelect);
      case 1:
        return LocationScreen(username: username!);
      case 2:
        return GeofencingScreen(username: username!);
      case 3:
        return SmsScreen(username: username!);
      case 4:
        return CallScreen(username: username!);
      case 5:
        return KeyloggerScreen(username: username!);
      case 6:
        return WhatsAppScreen(username: username!);
      case 7:
        return InstalledAppsScreen(username: username!);
      case 8:
        return BlockedAppsScreen(username: username!);
      case 9:
        return StealthModeScreen(username: username!);
      default:
        return const Center(child: Text("Unknown module"));
    }
  }

  Widget _buildStatusIndicator() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isDeviceActive == null) {
      return const Text("No Status");
    }

    return Row(
      children: [
        Icon(
          Icons.circle,
          color: isDeviceActive! ? Colors.green : Colors.red,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          isDeviceActive! ? "Device Active" : "Device Inactive",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 800;

        if (username == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : null,
          appBar: isLargeScreen
              ? null
              : AppBar(
                  backgroundColor:
                      isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/icon/app_icon.png',
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Parental Radar',
                        style: TextStyle(
                          fontFamily: 'Righteous',
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/add-device'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildStatusIndicator(),
                    ),
                  ],
                ),
          drawer: isLargeScreen
              ? null
              : Drawer(
                  child: SideBar(
                    selectedIndex: selectedIndex,
                    onItemSelected: (index) {
                      Navigator.pop(context);
                      onSelect(index);
                    },
                    username: username!,
                    isDarkMode: widget.isDarkMode,
                    onThemeChanged: widget.onThemeToggle,
                  ),
                ),
          body: Row(
            children: [
              if (isLargeScreen)
                SideBar(
                  selectedIndex: selectedIndex,
                  onItemSelected: onSelect,
                  username: username!,
                  isDarkMode: widget.isDarkMode,
                  onThemeChanged: widget.onThemeToggle,
                ),
              Expanded(
                child: Column(
                  children: [
                    if (isLargeScreen)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFFFDFDFD),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icon/app_icon.png',
                                  height: 32,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Parental Radar",
                                      style: TextStyle(
                                        fontFamily: 'Righteous',
                                        fontSize: 22,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _buildStatusIndicator(),
                                        const SizedBox(width: 12),
                                        Text(
                                          "User ID: $username",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_none),
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/notifications'),
                                  color: isDark ? Colors.white : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/settings'),
                                  color: isDark ? Colors.white : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/add-device'),
                                  color: isDark ? Colors.white : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    username!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: 400.ms,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: _currentScreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
