import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dashboard_screen.dart';
import '../../keys/parent_key_generator.dart';

class DeviceSelectionScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const DeviceSelectionScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  String? deviceId;

  @override
  void initState() {
    super.initState();
    _fetchDeviceFromFirestore();
  }

  Future<void> _fetchDeviceFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('devices')
            .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        deviceId = snapshot.docs.first.id;
      });
    }
  }

  Future<void> _saveDeviceToFirestore(String username) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(username)
        .set({'linkedAt': FieldValue.serverTimestamp()});

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'onboardingStep': 'device-added',
    }, SetOptions(merge: true));

    setState(() {
      deviceId = username;
    });

    _openDashboard();
  }

  void _openDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => DashboardScreen(
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle,
            ),
      ),
    );
  }

  void _showQRAndConfirm(String username) async {
    await ParentKeyGenerator.generateAndUpload(username);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Scan This QR to Link Device'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(data: username),
                ),
                const SizedBox(height: 12),
                Text(username, style: const TextStyle(fontSize: 14)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveDeviceToFirestore(username);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _addDevice() {
    final uniqueName =
        'device_qer_${Random().nextInt(999999).toString().padLeft(6, '0')}';
    _showQRAndConfirm(uniqueName);
  }

  Future<void> _deleteDevice(String username) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(username)
        .delete();

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'onboardingStep': 'download-complete',
    }, SetOptions(merge: true));

    setState(() {
      deviceId = null;
    });
  }

  void _confirmDeleteDevice(String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Device'),
            content: Text('Are you sure you want to remove "$username"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _deleteDevice(username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Connect Your Device'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0090ff), Color(0xFF15D6A6), Color(0xFFF2F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600,
            ),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 100,
              ),
              children: [
                const Text(
                  'Connect your child’s device to get started',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (deviceId != null)
                  Animate(
                    effects: [FadeEffect(duration: 300.ms), SlideEffect()],
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: const Icon(Icons.devices, color: Colors.teal),
                        title: const Text(
                          'Linked Device',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(deviceId!),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteDevice(deviceId!),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: _openDashboard,
                      ),
                    ),
                  ),
                if (deviceId == null)
                  Animate(
                    effects: [FadeEffect(), ScaleEffect(delay: 100.ms)],
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        leading: const Icon(Icons.link, color: Colors.green),
                        title: const Text(
                          'Add New Device',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        onTap: _addDevice,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}