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
        _currentScreen = _buildFeedbackScreen(
          Feedback1(onComplete: (selected) async {
            await _submitFeedback(uid, 'feedback1', selected);
            feedback1Done = true;
            _checkFeedbackStatus(uid);
          }),
        );
      });
    } else if (!feedback2Done) {
      setState(() {
        _currentScreen = _buildFeedbackScreen(
          Feedback2(onComplete: (selected) async {
            await _submitFeedback(uid, 'feedback2', selected);
            feedback2Done = true;
            _initializeDashboard();
          }),
        );
      });
    } else {
      _initializeDashboard();
    }
  }

  Widget _buildFeedbackScreen(Widget form) {
    return Stack(
      children: [
        Container(color: widget.isDarkMode ? Colors.black : Colors.white),
        form,
      ],
    );
  }

  Future<void> _submitFeedback(String uid, String type, int value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('feedback')
        .doc('status')
        .set({type: true, '${type}_value': value}, SetOptions(merge: true));
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
      setState(() {
        isDeviceActive = deviceData?['used'] == true;
        isLoading = false;
      });
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
    final screens = [
      DashboardPage(username: username!, onJumpToIndex: onSelect),
      LocationScreen(username: username!),
      GeofencingScreen(username: username!),
      SmsScreen(username: username!),
      CallScreen(username: username!),
      KeyloggerScreen(username: username!),
      WhatsAppScreen(username: username!),
      InstalledAppsScreen(username: username!),
      BlockedAppsScreen(username: username!),
      StealthModeScreen(username: username!),
    ];

    return index >= 0 && index < screens.length
        ? screens[index]
        : const Center(child: Text("Unknown module"));
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
          style: const TextStyle(fontSize: 13),
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : null,
          appBar: isLargeScreen
              ? null
              : AppBar(
                  backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Row(
                    children: [
                      Image.asset('assets/icon/app_icon.png', height: 24),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Parental Radar',
                          style: TextStyle(
                            fontFamily: 'Righteous',
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                      tooltip: 'Notifications',
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      tooltip: 'Settings',
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(context, '/add-device'),
                      tooltip: 'Edit Device',
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFDFDFD),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                Image.asset('assets/icon/app_icon.png', height: 30),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Parental Radar",
                                      style: TextStyle(
                                        fontFamily: 'Righteous',
                                        fontSize: 20,
                                        color: isDark ? Colors.white : Colors.black,
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
                                            color: isDark ? Colors.white70 : Colors.black,
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
                                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                                  color: isDark ? Colors.white : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                                  color: isDark ? Colors.white : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.pushNamed(context, '/add-device'),
                                  color: isDark ? Colors.white : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: 400.ms,
                        transitionBuilder: (child, animation) => FadeTransition(
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
