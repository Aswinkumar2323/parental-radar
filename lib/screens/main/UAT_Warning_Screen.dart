import 'package:flutter/material.dart';
import 'dart:math' as math;

class UATWarningScreen extends StatelessWidget {
  const UATWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gradient angle: 315 degrees
    final double angleInRadians = 315 * (math.pi / 180);
    final Alignment begin = Alignment(
      math.cos(angleInRadians),
      math.sin(angleInRadians),
    );
    final Alignment end = Alignment(
      -math.cos(angleInRadians),
      -math.sin(angleInRadians),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: const [
              Color(0xFF0090FF), // Primary
              Color(0xFF15D6A6), // Secondary
              Color(0xFF123A5B), // Tertiary
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Text(
              _uatText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const String _uatText = '''
Parental-Radar Application – User Warnings (UAT Only)

Effective Date: 15/05/2025
Document Version: UAT-UW

The following document outlines critical warnings, disclaimers, and responsibilities that every participant of the User Acceptance Testing (UAT) phase of the Parental-Radar Application must acknowledge and adhere to...

1. Warning Against Unauthorized Use
- The application is only for legal parents or guardians.
- You must not install it on devices you do not own.
- Unauthorized installation may be a criminal offense.

2. Warning Against Misuse
- App may capture sensitive data (calls, SMS, location, etc.)
- Do not use for stalking, revenge, employee tracking, etc.
- Misuse leads to disqualification and possible legal action.

3. Data Sensitivity & Confidentiality
- You must not share, screenshot, or publish UAT data.
- All builds and features are confidential.

4. Legal Accountability
- Misuse may violate laws.
- You are personally liable for unauthorized actions.

5. Security and Ethical Conduct
- Don’t tamper with permissions, recompile code, or spoof data.
- Breach will result in permanent exclusion.

6. Theft or Distribution
- Do not share the app or upload it online.
- Any leaks will be treated as intellectual property theft.

7. Agreement and Acknowledgment
- You agree to comply with all the above.
- Violations may result in legal action.

If you disagree with these terms, do not install or use the UAT build.

Parental-Radar Application – UAT Program
''';
}
