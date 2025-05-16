import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  int step = 0;
  bool loading = false;
  late final String a;
  late final String b;
  late final String c;
  late final List<String> dummyTexts;
  late ScrollController _scrollController;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    a = '''
  ## Parental-Radar Application – Terms and Conditions for User Acceptance Testing (UAT Only)

  **Effective Date:** 15/05/2025
  **Document Version:** UAT - T&C - 1.0

  These Terms and Conditions (“Agreement”) are a binding legal contract between you (“User”, “Parent”, or “you”) and Parental Radar (“we,” “us,” or “the Company”), governing your access to and participation in the User Acceptance Testing (“UAT”) of the Parental-Radar Application (the “App”). By accessing, installing, or using the App for the purposes of UAT, you agree to be bound by these terms. If you do not agree with any provision in this Agreement, you must not access or use the App for UAT purposes.

  ### 1. Purpose and Intent of UAT

  **1.1** The User Acceptance Testing (UAT) phase is a pre-release environment wherein selected users, including legal guardians and parents, are invited to interact with a test version of the Parental-Radar Application to evaluate its performance, functionality, and stability.

  **1.2** The core objective of UAT is to identify bugs, system irregularities, performance bottlenecks, usability gaps, and potential privacy or security issues before the application is made available to the general public.

  **1.3** Participation in this phase is voluntary, and the software provided is not to be considered a final or commercially deployable product. You acknowledge that your participation contributes to the development and enhancement of the Parental-Radar Application and that the product in its UAT form may experience service interruptions, performance degradation, and loss of data.

  ### 2. Eligibility, Capacity, and Consent

  **2.1** You affirm that you are the lawful parent or guardian of the child whose device will be monitored during the UAT period. You further affirm that you have full legal authority to install, activate, and operate the Parental-Radar Application on the target device during this testing period.

  **2.2** You understand that use of this App in its UAT phase must be restricted to personal, non-commercial, non-criminal usage, and only for the purpose of assisting with testing, quality assurance, and feedback generation.

  **2.3** By participating in the UAT, you grant explicit consent for the App to collect relevant data from the child’s device, including device identifiers, system logs, sensor data, and activity patterns, all of which will be securely stored, processed, and evaluated by our development team solely for the purpose of improving the final release.

  ### 3. Access and Limited License

  **3.1** Subject to your compliance with this Agreement, you are granted a revocable, non-exclusive, non-transferable, and limited license to download, install, and use the UAT version of the Parental-Radar Application for the sole purpose of testing its functions.

  **3.2** This license does not constitute a sale or transfer of ownership. You shall not, under any circumstance, distribute, resell, sublicense, modify, reverse-engineer, or decompile the App or any of its parts.

  **3.3** You may not share, publish, or otherwise disclose the contents, functionalities, or design elements of the App, including but not limited to screenshots, video captures, or user flow recordings, without the prior written consent of the Company.

  ### 4. Data Collection, Use, and Privacy

  **4.1** The App will collect various categories of data from the device it is installed on, including but not limited to location coordinates, contact records, call logs, messages, app usage history, keystrokes (where permitted), Wi-Fi networks, and media gallery contents.

  **4.2** All data collected shall be securely transmitted to the Company’s testing servers or designated cloud storage solutions. Encryption protocols and access management policies are in place to minimize any unauthorized access or data breaches.

  **4.3** You understand that this data will be used solely for the purpose of:
   (a) verifying system functionality,
   (b) identifying bugs and performance issues,
   (c) optimizing user experience and security, and
   (d) making feature adjustments prior to full release.

  **4.4** The Company will not sell, rent, or commercially exploit this data. However, it may be shared with third-party vendors or developers who are contractually obligated to participate in the debugging or optimization process.

  **4.5** Upon termination of the UAT phase, all test data associated with your usage may be archived, anonymized, or deleted as per internal retention policies.

  ### 5. UAT Performance Expectations and Risks

  **5.1** The UAT version of the Parental-Radar Application may not be stable, may experience crashes, may contain incomplete modules, and may behave in unpredictable ways. You acknowledge that such behavior is expected and accept the risk of potential disruptions.

  **5.2** You further understand that:
   (a) features may be disabled or limited without notice,
   (b) updates may be pushed automatically,
   (c) testing may result in loss of personal data on the child’s device if improperly configured,
   (d) connectivity to servers may be inconsistent.

  **5.3** The Company disclaims all warranties during the UAT phase, including express, implied, or statutory guarantees of performance, data accuracy, fitness for a particular purpose, and non-infringement.

  ### 6. Intellectual Property and Ownership

  **6.1** The Parental-Radar Application, including its codebase, user interface, visual elements, APIs, databases, and technical architecture, is and shall remain the exclusive property of ParentalRadar.

  **6.2** You are not permitted to create derivative works, duplicate the App or parts thereof, or incorporate any component of the App into other software or services without express written consent.

  **6.3** Any materials or suggestions you provide during the UAT shall become the intellectual property of the Company. You waive any and all moral rights in such contributions.

  ### 7. Confidentiality Obligations

  **7.1** You agree to treat all information made available to you through the App or related communications as confidential. This includes but is not limited to:
   - the application’s design and structure,
   - test data,
   - development logs and notes,
   - non-public URLs and endpoints,
   - internal documents and reports.

  **7.2** You shall not disclose any confidential information to third parties, nor publish or disseminate the App in any form, whether online or offline, during or after the UAT.

  **7.3** This obligation shall survive the termination of this Agreement and your participation in the UAT.

  ### 8. Feedback, Suggestions, and Reporting

  **8.1** You agree to provide honest, timely, and relevant feedback concerning the usage of the App, including observations, issues, performance notes, and enhancement suggestions.

  **8.2** You may be contacted periodically by our team for follow-up questions or clarifications related to submitted feedback.

  **8.3** All feedback becomes the exclusive property of the Company, and you agree that no compensation, royalty, or acknowledgment is required for its use, modification, or implementation.

  ### 9. Termination and Revocation

  **9.1** Your access to the UAT version of the Parental-Radar Application may be revoked at any time with or without cause, notice, or liability.

  **9.2** You may also voluntarily discontinue participation by uninstalling the App and notifying the Company of your withdrawal.

  **9.3** Upon termination, you are required to:
   (a) delete all copies of the App and any data files associated with it,
   (b) cease all usage and feedback submission,
   (c) discontinue access to any associated portals or support systems.

  **9.4** Unauthorized or unethical behavior, including but not limited to reverse engineering, data tampering, misuse of monitoring features, or violation of privacy laws, will result in immediate termination and potential legal consequences.

  ### 10. Limitation of Liability

  **10.1** You understand and agree that participation in UAT is at your sole risk and discretion.

  **10.2** The Company shall not be held liable for any damages arising directly or indirectly from your use of the App during UAT, including but not limited to data loss, privacy breaches, device malfunctions, or third-party claims.

  **10.3** In no event shall the Company’s total liability exceed the amount paid by you for participating in UAT, which, in most cases, shall be zero.

  ### 11. Legal Compliance and Governing Law

  **11.1** You agree to comply with all applicable laws, rules, and regulations in connection with your use of the App during UAT.

  **11.2** This Agreement shall be governed by and construed in accordance with the laws of [Jurisdiction], and any dispute arising from this Agreement shall be subject to the exclusive jurisdiction of the courts located in Chennai, India.

  ### 12. Acknowledgement of Acceptance

  **12.1** By proceeding with the installation, activation, or usage of the Parental-Radar Application, you affirm that you have read, understood, and accepted these Terms and Conditions in full.

  **12.2** You further acknowledge that you are voluntarily participating in the UAT and have been granted temporary access solely for the purpose of testing, feedback, and product validation.

  If you are not in agreement with these terms, please discontinue your use of the Parental-Radar Application and contact the Company’s support team for removal from the UAT program.
  ''';

    b = '''
  ## Parental-Radar Application – Privacy Policy (User Acceptance Testing - UAT Only)

  **Effective Date:** 15/05/2025
  **Document Version:** UAT - PP - 1.0

  This Privacy Policy describes how Parental Radar ("we", "us", or "our") collects, uses, stores, shares, and protects information obtained from users (“you”, “your”, “Parent”, or “User”) during the User Acceptance Testing (“UAT”) phase of the Parental-Radar Application ("the App"). By participating in the UAT and using the App on your or your child’s device, you agree to the terms of this Privacy Policy.

  The privacy of you and your child is important to us. This document outlines the specific practices we follow during the UAT phase, including data collection, usage, retention, disclosure, and user rights.

  ### 1. Scope and Applicability

  **1.1** This Privacy Policy applies strictly to the UAT version of the Parental-Radar Application and is applicable only to selected users participating in the test phase.

  **1.2** This policy does not apply to the final production version of the App or any other applications, websites, or services owned or operated by the Company unless expressly stated.

  **1.3** The data collection and processing activities described herein are temporary and solely intended for testing, debugging, feature verification, and performance analysis.

  ### 2. Information We Collect

  **2.1 User-Provided Information**

  We collect information you voluntarily provide during registration or through feedback forms, including:

  - Your full name and email address
  - Contact number
  - Consent confirmations
  - Feedback or bug reports submitted via in-app mechanisms or support channels

  **2.2 Child Device Data (Target Device)**

  With your explicit consent, we collect specific categories of data from your child’s device where the App is installed:

  - GPS location data (live and historical)
  - Call logs (metadata only – no voice recordings)
  - Text message metadata and content
  - Keystroke logging (where enabled)
  - Browser history and web activity
  - App usage history and installed app data
  - Wi-Fi network identifiers and connectivity logs
  - Contact list metadata
  - Device identifiers (IMEI, Android ID, IP address, OS version)

  **2.3 Device and Usage Information**

  When you use the App, we may automatically collect technical data including:

  - Device type, manufacturer, and model
  - Operating system version
  - Crash logs and error traces
  - Session timestamps
  - User interaction logs (clicks, scrolls, form interactions)

  ### 3. Purpose of Data Collection

  **3.1** The data collected during UAT is used exclusively for:

  - Identifying technical bugs, glitches, and inconsistencies
  - Measuring performance and responsiveness
  - Verifying feature accuracy and app behavior
  - Improving user interface and experience design
  - Evaluating backend stability under realistic use
  - Strengthening security controls and encryption logic
  - Collecting anonymized analytics to refine final features

  **3.2** No data collected during the UAT period is used for marketing, sales, third-party advertising, or profiling outside the scope of testing.

  ### 4. Legal Basis for Processing

  **4.1** All personal data collected during the UAT phase is processed under the legal basis of explicit user consent. You affirm that you have read and understood this Privacy Policy before activating the App.

  **4.2** You confirm that you are the lawful guardian of the child device on which the App is being installed and used for testing purposes.

  **4.3** Data processing is strictly limited to UAT and is conducted in alignment with global data protection laws, including GDPR (where applicable), the Information Technology Act (India), and local child privacy regulations.

  ### 5. Data Storage and Security

  **5.1** Data collected from your and your child’s devices is encrypted in transit and at rest using industry-standard encryption protocols (e.g., AES-256, TLS 1.3).

  **5.2** All collected data is securely transmitted to our private cloud infrastructure hosted on [provider name, e.g., Google Cloud, AWS] and is subject to restricted access control.

  **5.3** Our internal data policies include:

  - Role-based access for engineers and QA testers
  - Regular vulnerability assessments
  - Two-factor authentication for data access
  - Encryption key rotation policies

  **5.4** The App does not store unencrypted sensitive data locally on the device. Temporary data required for processing is cleared upon task completion.

  ### 6. Data Sharing and Disclosure

  **6.1** We do not sell, rent, lease, or commercially trade any user or child data collected during UAT.

  **6.2** Data may be shared with:

  - Internal software development and QA teams
  - Authorized security analysts and compliance officers
  - Third-party developers under strict non-disclosure agreements for debugging and testing tasks

  **6.3** In cases of legal obligation or valid court order, we may be required to disclose specific data. In such cases, you will be notified unless prohibited by law.

  **6.4** All shared data remains protected by contractual obligations ensuring its exclusive use for UAT purposes and destruction after its intended use.

  ### 7. Data Retention and Deletion

  **7.1** Data collected during the UAT phase will be retained only for the minimum duration required to complete testing, issue reports, and implement changes. This is generally not more than 90 days after the end of UAT unless otherwise required for analysis.

  **7.2** Upon conclusion of UAT, all personal data will be:

  (a) Anonymized for long-term analysis purposes
  (b) Deleted permanently from our systems
  (c) Archived securely with restricted access if required by legal or security policies

  **7.3** You may request early deletion of your data or withdrawal from UAT at any time by contacting our support team at [support email].

  ### 8. User Rights

  As a UAT participant, you have the following rights with respect to your data:

  **8.1 Right to Access** – You may request a copy of the personal data we have collected from you or your child’s device.

  **8.2 Right to Correction** – If any of your personal information is incorrect or outdated, you may request correction.

  **8.3 Right to Withdraw Consent** – You may revoke consent at any time, which will result in immediate termination of UAT participation and deletion of your data.

  **8.4 Right to Deletion** – You may request complete removal of your and your child’s data from our servers.

  **8.5 Right to Restrict Processing** – You may request that certain categories of data (e.g., photos, keystrokes) not be collected.

  **8.6** To exercise these rights, contact us at [data protection contact email].

  ### 9. Children’s Privacy

  **9.1** As the Parental-Radar Application is designed for parental monitoring, you confirm that:

  - You are the parent or legal guardian of the monitored child
  - You have obtained lawful consent to process their data during the UAT
  - You will not use the App on a device without legal authority

  **9.2** We do not knowingly collect personal information from individuals under the age of 13 without parental consent.

  ### 10. Changes to This Privacy Policy

  **10.1** We may update this Privacy Policy from time to time to reflect new testing practices, legal obligations, or improvements to data handling.

  **10.2** You will be notified of any significant changes via email or in-app notification, and your continued use of the App will constitute acceptance of those changes.

  By proceeding with the Parental-Radar Application during the UAT phase, you acknowledge that you have read, understood, and accepted the terms outlined in this Privacy Policy.
  ''';

    c = '''
  ## Parental-Radar Application – User Advice  (UAT Only)

  **Effective Date:** 15/05/2025
  **Document Version:** UAT - UW - 1.0

  The following document outlines **critical warnings, disclaimers, and responsibilities** that every participant of the User Acceptance Testing (UAT) phase of the Parental-Radar Application must acknowledge and adhere to. These warnings are issued to protect the integrity of the testing process, safeguard user privacy, ensure compliance with the law, and prevent the misuse or unauthorized distribution of the application.

  **By installing, accessing, or using the Parental-Radar Application for UAT purposes, you confirm your full understanding and agreement with the following statements.**

  ### 1. Warning Against Unauthorized Use

  **1.1** The Parental-Radar Application is **strictly intended** to be used only by lawful parents or legal guardians of the child or minor whose device is being monitored.

  **1.2** **You must not install this application on any device you do not own or legally control.** Any attempt to deploy the application on unauthorized devices is considered a **breach of ethical and legal responsibility** and may constitute a **criminal offense under cyber laws.**

  **1.3** Participants found to have installed the App without legal authority or on unauthorized devices will be **immediately terminated** from UAT, and their data will be **purged without further notice.**

  ### 2. Warning Against Misuse

  **2.1** The UAT version of the Parental-Radar Application contains features that capture **sensitive personal data**, including but not limited to call logs, SMS content, location, app usage, and keystrokes. These features are enabled **only for the purpose of validating technical functionality.**

  **2.2** **Misusing these features for stalking, surveillance of adults, revenge monitoring, employee tracking, or any other malicious or unlawful intent is strictly prohibited** and will result in **disqualification from the testing program and referral to relevant legal authorities.**

  **2.3** **You are warned not to use any UAT-collected data to harass, threaten, manipulate, or control the behavior of any individual, including minors.**

  **2.4** The App **must not be repurposed or exported** for private monitoring, resale, reverse engineering, or unauthorized feature development.

  ### 3. Warning on Data Sensitivity and Confidentiality

  **3.1** You acknowledge that the data collected during the UAT phase is **sensitive in nature** and that access to such data is a **privilege granted solely for testing purposes.**

  **3.2** **You must not share, transmit, publish, expose, screenshot, or replicate any data collected from the App during testing** in public or private forums, social media platforms, or unauthorized channels.

  **3.3** **Sharing your UAT access credentials or QR code with any third party**, including colleagues, friends, or family, is **strictly prohibited.**

  **3.4** All UAT builds, features, visuals, and documentation are **confidential intellectual property** of the development company. **Reproducing or copying the application, in part or full, without written consent is a violation of copyright laws.**

  ### 4. Warning on Legal Accountability

  **4.1 Misuse of the Parental-Radar Application may violate local, national, and international privacy laws.** It is your responsibility to understand and follow your region’s digital surveillance laws before using the App.

  **4.2 You are personally liable for any legal consequences** resulting from unauthorized use, including installation without consent, unapproved monitoring, or data leaks caused by your negligence.

  **4.3 The Company disclaims all liability** for misuse or mishandling of the App by the UAT participant or any third party who gains access to the App due to the participant’s carelessness.

  ### 5. Warning on Security and Ethical Conduct

  **5.1 You must not attempt to:**

  - Bypass or tamper with app permissions
  - Modify or recompile the application code
  - Extract data directly from storage files or database paths
  - Disable security features or encryption mechanisms
  - Spooof location or falsify usage logs to manipulate results

  **5.2 Any such activity is considered a direct violation of ethical conduct and testing protocols, and you will be permanently barred from current and future access to any product or service provided by the Company.**

  **5.3** The App is to be used **only during the designated testing period.** Continued usage beyond the declared UAT window may result in **suspension or legal consequences** unless otherwise authorized in writing.

  ### 6. Warning on Theft or Distribution

  **6.1 You are strictly prohibited from copying, redistributing, or uploading the Parental-Radar Application** to third-party app stores, marketplaces, code-sharing platforms, or cloud storage systems.

  **6.2 Any participant found to be leaking APKs, sharing internal builds, or publicly exposing UAT modules or source code will be reported for intellectual property theft and dealt with under applicable software piracy laws.**

  **6.3 All UAT participants agree to immediately report any known or suspected misuse, theft, or unauthorized distribution of the application or its related components to the Company’s compliance team.**

  ### 7. Agreement and Acknowledgment

  **7.1 By continuing to participate in the UAT program and using the Parental-Radar Application, you confirm that you:**

  - Are aware of all warnings provided above
  - Have the legal right to use this App on the intended device
  - Will not engage in or encourage any form of misuse
  - Understand that violating these terms may result in legal action
  - Accept your role in safeguarding the reputation, security, and integrity of the App and its intended use

  **If you do not agree with these warnings or are uncertain about any aspect of your usage rights, you must refrain from installing or continuing to use the Parental-Radar Application during UAT.**
  ''';

    dummyTexts = [a, b, c];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasScrolledToBottom &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 10) {
      setState(() {
        _hasScrolledToBottom = true;
      });
    }
  }

  final List<String> titles = [
    "Terms & Conditions",
    "Privacy Policy",
    "User Advice",
  ];

  final primaryColor = const Color(0xFF1D3557);
  final accentColor = const Color(0xFF2A9D8F);

  Future<void> _agreeAndContinue() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final field = {
      0: {'terms_and_conditions': 'agreed'},
      1: {'privacy_policy': 'agreed'},
      2: {'user_advice': 'agreed', 'onboardingStep': 'policy-complete'},
    };

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(field[step]!, SetOptions(merge: true));

    setState(() => loading = false);

    if (step < 2) {
      setState(() => step++);
      _hasScrolledToBottom = false;
      _scrollController.jumpTo(0); // reset scroll to top
    } else {
      Navigator.pushReplacementNamed(context, '/apk-download');
    }
  }

  Widget buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(titles.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Add spacing/connector between steps
          return Container(
            width: 40,
            height: 2,
            color: i ~/ 2 < step ? Colors.green : Colors.grey[300],
          );
        }

        final index = i ~/ 2;
        final isDone = index < step;
        final isActive = index == step;

        return Column(
          children: [
            AnimatedContainer(
              duration: 400.ms,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isDone
                        ? Colors.green
                        : (isActive ? accentColor : Colors.grey[300]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    isDone
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titles[index],
              style: TextStyle(
                color:
                    isDone
                        ? Colors.green
                        : isActive
                        ? primaryColor
                        : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("User Agreements"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            buildStepIndicator(),
            const SizedBox(height: 24),
            Expanded(
              child: Animate(
                key: ValueKey(step),
                effects: [
                  FadeEffect(begin: 0.0, end: 1.0, duration: 300.ms),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: 300.ms,
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: primaryColor,
                            size: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            titles[step],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true, // optional
                          child: Markdown(
                            controller: _scrollController,
                            data: dummyTexts[step],
                            styleSheet: MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child:
                            loading
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text("Agree & Continue"),
                                  onPressed:
                                      _hasScrolledToBottom && !loading
                                          ? _agreeAndContinue
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                  ),
                                ).animate().scale(
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
