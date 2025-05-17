import 'package:flutter/material.dart';

class BreathingLoader extends StatefulWidget {
  const BreathingLoader({super.key});

  @override
  State<BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<BreathingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _sizeAnimation = Tween<double>(begin: 50, end: 90).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _colorAnimation = ColorTween(
      begin: const Color(0xFF0090FF),
      end: isDark ? const Color(0xFF15D6A6) : const Color(0xFFCCE8FF),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Container(
      color: backgroundColor.withOpacity(0.9),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple (outer glow effect)
              Container(
                width: _sizeAnimation.value + 12,
                height: _sizeAnimation.value + 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_colorAnimation.value ?? const Color(0xFF0090FF))
                      .withOpacity(_opacityAnimation.value * 0.25),
                ),
              ),

              // Main breathing circle
              Container(
                width: _sizeAnimation.value,
                height: _sizeAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: _colorAnimation.value ?? const Color(0xFF0090FF),
                    width: 4, // refined border thickness
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_colorAnimation.value ?? const Color(0xFF0090FF))
                          .withOpacity(_opacityAnimation.value * 0.5),
                      blurRadius: 16,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}