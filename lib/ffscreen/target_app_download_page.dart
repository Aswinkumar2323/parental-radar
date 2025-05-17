import 'dart:io' show File, Directory, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Import helper
import '../utils/download_helper_stub.dart'
    if (dart.library.html) '../utils/web_download_helper.dart';

class TargetAppDownloadPage extends StatelessWidget {
  const TargetAppDownloadPage({super.key});

  static const String apkDownloadUrl = 'https://parentalradar.com/';
  static const font = 'NexaBold';

  Future<void> _copyApkToDownloads(BuildContext context) async {
    try {
      final byteData = await rootBundle.load('assets/apk/target.apk');
      final bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        downloadApkInWeb(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('APK download started in browser')),
        );
        return;
      }

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required')),
          );
          return;
        }
      }

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final apkFile = File('${downloadsDir.path}/target_app.apk');
      await apkFile.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('APK saved to Downloads folder')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save APK: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 500,
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: apkDownloadUrl,
                    version: QrVersions.auto,
                    size: isMobile ? 180 : 220,
                    gapless: false,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan the QR code on the child’s device to log in to the parent dashboard',
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Download Child Data Sensing App',
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Download Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _copyApkToDownloads(context),
                      icon: const Icon(Icons.file_download, color: Colors.white),
                      label: const Text(
                        'Download Now',
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0090FF),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) throw Exception("User not logged in");

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .set({
                                'onboardingStep': 'download-complete',
                              }, SetOptions(merge: true));

                          Navigator.pushNamed(context, '/add-device');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B97D),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
