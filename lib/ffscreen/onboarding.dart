import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _boxController;
  late AnimationController _buttonController;

  late Animation<Offset> _logoOffset;
  late Animation<double> _logoOpacity;

  late Animation<double> _boxOpacity;
  late Animation<Offset> _boxSlide;

  late Animation<Offset> _buttonOffset;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _boxController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoOffset = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(_logoController);

    _boxOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _boxController, curve: Curves.easeIn));

    _boxSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _boxController, curve: Curves.easeOut));

    _buttonOffset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(_buttonController);

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _boxController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _boxController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo without extra container or spacing
                SlideTransition(
                  position: _logoOffset,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Image.asset(
                      'assets/icon/Final logo-01.png',
                      width: 450,
                      height: 450,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Welcome Box directly after logo
                SlideTransition(
                  position: _boxSlide,
                  child: FadeTransition(
                    opacity: _boxOpacity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Welcome!',
                            style: TextStyle(
                              fontFamily: 'NexaBold',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Thanks for joining! Access or create your account below, and get started on your journey!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'NexaBold',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Buttons
                SlideTransition(
                  position: _buttonOffset,
                  child: FadeTransition(
                    opacity: _buttonOpacity,
                    child: isWide
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPrimaryButton(
                                context,
                                "Get Started",
                                onPressed: () {
                                  Navigator.pushNamed(context, '/parent-auth');
                                },
                              ),
                              const SizedBox(width: 20),
                              _buildPrimaryButton(
                                context,
                                "My Account",
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildPrimaryButton(
                                context,
                                "Get Started",
                                onPressed: () {
                                  Navigator.pushNamed(context, '/parent-auth');
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildPrimaryButton(
                                context,
                                "My Account",
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0090FF),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'NexaBold',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
