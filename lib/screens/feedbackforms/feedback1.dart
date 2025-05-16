import 'package:flutter/material.dart';

class Feedback1 extends StatefulWidget {
  final Function(int) onComplete;

  const Feedback1({super.key, required this.onComplete});

  @override
  State<Feedback1> createState() => _Feedback1State();
}

class _Feedback1State extends State<Feedback1> {
  int? selectedRating;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.5);
    final containerColor = isDark ? Colors.green[900] : Colors.green[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Material(
        color: backgroundColor,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(16),
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How easy was the initial sign-up and setup process for Parental Radar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Where 1 = least satisfied and 5 = most satisfied',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final isSelected = selectedRating == value;
                    final buttonColor = isSelected
                        ? (isDark ? Colors.green[400] : Colors.green[800])
                        : (isDark ? Colors.green[700] : Colors.green);

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        setState(() => selectedRating = value);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          widget.onComplete(value);
                        });
                      },
                      child: Text(
                        '$value',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
