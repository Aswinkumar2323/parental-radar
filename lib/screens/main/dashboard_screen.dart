import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'dart:async';
import '../../apis/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        _currentScreen = _getScreenByIndex(selectedIndex);
      });
      _fetchDeviceStatus();
      _startStatusRefreshTimer();
    }
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
    _statusRefreshTimer.cancel();
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
        return LocationScreen(username: username!);
      case 1:
        return GeofencingScreen(username: username!);
      case 2:
        return SmsScreen(username: username!);
      case 3:
        return CallScreen(username: username!);
      case 4:
        return KeyloggerScreen(username: username!);
      case 5:
        return WhatsAppScreen(username: username!);
      case 6:
        return InstalledAppsScreen(username: username!);
      case 7:
        return BlockedAppsScreen(username: username!);
      case 8:
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 800;

        if (username == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: isLargeScreen
              ? null
              : AppBar(
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parent Radar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "User ID: $username",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      tooltip: 'Notifications',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Device',
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
                      Navigator.pop(context); // close drawer
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
                          color: Colors.deepPurple.shade50,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Parent Radar",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: const Color(0xFF4B39EF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _buildStatusIndicator(),
                                    const SizedBox(width: 12),
                                    Text(
                                      "User ID: $username",
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_none),
                                  tooltip: 'Notifications',
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/notifications'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings),
                                  tooltip: 'Settings',
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/settings'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit Device',
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/add-device'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    username!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
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
