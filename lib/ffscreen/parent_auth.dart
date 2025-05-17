import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_screen.dart';

class ParentAuth extends StatefulWidget {
  const ParentAuth({super.key});

  @override
  State<ParentAuth> createState() => _ParentAuthState();
}

class _ParentAuthState extends State<ParentAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  bool get isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    return email.isNotEmpty && password.isNotEmpty && password == confirmPassword;
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = authResult.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Email already in use';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const font = 'NexaBold';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0090ff), Color(0xFF15D6A6), Color(0xFFF2F8FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Your Account',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: font,
                        color: Color(0xFF123a5b),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Email Address',
                      style: const TextStyle(fontSize: 14, fontFamily: font),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(fontFamily: font),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Create Password',
                      style: const TextStyle(fontSize: 14, fontFamily: font),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        hintStyle: const TextStyle(fontFamily: font),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Confirm Password',
                      style: const TextStyle(fontSize: 14, fontFamily: font),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        hintStyle: const TextStyle(fontFamily: font),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() =>
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _emailController.clear();
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0090ff),
                              side: const BorderSide(color: Color(0xFF0090ff)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: font,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isFormValid && !_isLoading ? _createAccount : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5F40FB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Next',
                                    style: TextStyle(
                                      fontFamily: font,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
