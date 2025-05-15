import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userData = doc.data();
      isLoading = false;
    });
  }

  Widget _buildUserField(String label, dynamic value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0090ff), Color(0xFF15D6A6), Color(0xFFF2F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    children: [
                      Animate(
                        effects: [FadeEffect(duration: 500.ms), ScaleEffect()],
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color.fromARGB(255, 255, 255, 255),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Animate(
                        effects: [
                          FadeEffect(duration: 300.ms),
                          SlideEffect(begin: const Offset(0, 0.2)),
                        ],
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildUserField(
                                "Name",
                                userData?['name'] ?? '-',
                                Icons.person,
                              ),
                              const Divider(),
                              _buildUserField(
                                "Phone",
                                userData?['phone'] ?? '-',
                                Icons.phone,
                              ),
                              const Divider(),
                              _buildUserField(
                                "Gender",
                                userData?['gender'] ?? '-',
                                Icons.male,
                              ),
                              const Divider(),
                              _buildUserField(
                                "Age",
                                userData?['age'] ?? '-',
                                Icons.cake,
                              ),
                              const Divider(),
                              _buildUserField(
                                "Date of Birth",
                                userData?['dob'] ?? '-',
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
      ),
    );
  }
}
