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

    final snapshot = await FirebaseFirestore.instance
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
        builder: (_) => DashboardScreen(
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
      builder: (_) => AlertDialog(
        title: const Text(
          'Scan This QR to Link Device',
          style: TextStyle(fontFamily: 'NexaBold'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(data: username),
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(fontSize: 14, fontFamily: 'NexaBold'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'NexaBold'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveDeviceToFirestore(username);
            },
            child: const Text(
              'Confirm',
              style: TextStyle(fontFamily: 'NexaBold'),
            ),
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
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Device',
          style: TextStyle(fontFamily: 'NexaBold'),
        ),
        content: Text(
          'Are you sure you want to remove "$username"?',
          style: const TextStyle(fontFamily: 'NexaBold'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'NexaBold'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'NexaBold'),
            ),
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
      backgroundColor: const Color(0xFFE2E2E2),
      appBar: AppBar(
        title: const Text(
          'Connect Your Device',
          style: TextStyle(fontFamily: 'NexaBold', color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
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
                  fontFamily: 'NexaBold',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (deviceId != null)
                Animate(
                  effects: [FadeEffect(duration: 300.ms), SlideEffect()],
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: const Icon(Icons.devices, color: Colors.teal),
                      title: const Text(
                        'Linked Device',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        deviceId!,
                        style: const TextStyle(fontFamily: 'NexaBold'),
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.redAccent),
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
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      leading: const Icon(Icons.link, color: Color(0xFF0090FF)),
                      title: const Text(
                        'Add New Device',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
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
    );
  }
}
