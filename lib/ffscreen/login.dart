import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('Login failed');

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final onboardingStep = doc.data()?['onboardingStep'];

      if (onboardingStep == 'profile-complete') {
        Navigator.pushReplacementNamed(context, '/policy');
      } else if (onboardingStep == 'policy-complete') {
        Navigator.pushReplacementNamed(context, '/apk-download');
      } else if (onboardingStep == 'download-complete') {
        Navigator.pushReplacementNamed(context, '/add-device');
      } else if (onboardingStep == 'device-added') {
        Navigator.pushReplacementNamed(context, '/dashB');
      } else {
        Navigator.pushReplacementNamed(context, '/parent-form');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0xFF0090FF), Color(0xFF15D6A6), Color(0xFF123A5B)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Column(
                children: [
                  // ✅ White container behind logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ParentalRadar',
                    style: TextStyle(
                      fontFamily: 'NexaBold',
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'KEEPING THEM SAFE, CONNECTED, AND GROWING',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontFamily: 'NexaBold',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: isMobile ? screenWidth * 0.85 : 360,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NexaBold',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill out the information below in order to access your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'NexaBold',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(fontFamily: 'NexaBold'),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(fontFamily: 'NexaBold'),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(fontFamily: 'NexaBold'),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(fontFamily: 'NexaBold'),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(223, 126, 188, 239),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'NexaBold',
                                ),
                              ),
                      ),
                    
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontFamily: 'NexaBold'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/parent-auth');
                            },
                            child: const Text(
                              'Sign Up here',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'NexaBold',
                              ),
                            ),
                          ),
                        ],
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
