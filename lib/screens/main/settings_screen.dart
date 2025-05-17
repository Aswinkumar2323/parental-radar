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

  Future<void> _editField(String field, String label, IconData icon) async {
    final TextEditingController controller = TextEditingController(
      text: userData?[field]?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text('Edit $label', style: const TextStyle(fontFamily: 'NexaBold')),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new $label',
            hintStyle: const TextStyle(fontFamily: 'NexaBold'),
          ),
          style: const TextStyle(fontFamily: 'NexaBold'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'NexaBold')),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({field: controller.text.trim()});
                await _fetchUserData();
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontFamily: 'NexaBold')),
          ),
        ],
      ),
    );
  }

  Widget _buildUserField(String label, String field, IconData icon) {
    final value = userData?[field]?.toString() ?? '-';

    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'NexaBold',
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontFamily: 'NexaBold'),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.grey),
        onPressed: () => _editField(field, label, icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parent Settings',
          style: TextStyle(fontFamily: 'NexaBold'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    Animate(
                      effects: [FadeEffect(duration: 500.ms), ScaleEffect()],
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.black,
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
                            _buildUserField("Name", 'name', Icons.person),
                            const Divider(),
                            _buildUserField("Phone", 'phone', Icons.phone),
                            const Divider(),
                            _buildUserField("Gender", 'gender', Icons.male),
                            const Divider(),
                            _buildUserField("Age", 'age', Icons.cake),
                            const Divider(),
                            _buildUserField("Date of Birth", 'dob',
                                Icons.calendar_today),
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
