import 'package:flutter/material.dart';

class Feedback2 extends StatefulWidget {
  final Function(int) onComplete;

  const Feedback2({super.key, required this.onComplete});

  @override
  State<Feedback2> createState() => _Feedback2State();
}

class _Feedback2State extends State<Feedback2> {
  int? selectedRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          backgroundColor: Colors.black.withOpacity(isDark ? 0.7 : 0.5),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 450),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How clear and understandable was the process of connecting your child\'s devices?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NexaBold',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Where 1 = Unclear and 5 = Very Clear',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NexaBold',
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      final isSelected = selectedRating == value;
                      final buttonColor = isSelected
                          ? (isDark ? Colors.greenAccent[400] : Colors.green[800])
                          : (isDark ? Colors.green[700] : Colors.green);

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          minimumSize: const Size(40, 48),
                        ),
                        onPressed: () {
                          setState(() => selectedRating = value);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            widget.onComplete(value);
                          });
                        },
                        child: Text(
                          '$value',
                          style: const TextStyle(
                            fontFamily: 'NexaBold',
                            fontSize: 18,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
