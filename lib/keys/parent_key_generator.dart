import 'dart:typed_data';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert';

class ParentKeyGenerator {
  static Future<void> generateAndUpload(String username) async {
    final domainParams = ECDomainParameters('secp256r1');

    final secureRandom = FortunaRandom();
    final seed = Uint8List.fromList(List.generate(32, (_) => Random.secure().nextInt(256)));
    secureRandom.seed(KeyParameter(seed));

    final keyParams = ECKeyGeneratorParameters(domainParams);
    final generator = ECKeyGenerator();
    generator.init(ParametersWithRandom(keyParams, secureRandom));

    final keyPair = generator.generateKeyPair();
    final privateKey = keyPair.privateKey as ECPrivateKey;
    final publicKey = keyPair.publicKey as ECPublicKey;

    await FirebaseFirestore.instance.collection('user').doc(username).collection('keys').doc('latest').set({
      'privateKey': privateKey.d!.toRadixString(16).padLeft(64, '0'),
      'publicKey': base64Encode(publicKey.Q!.getEncoded(false)),
      'keyVersion': 'v1',
      'createdAt': DateTime.now().toIso8601String(),
    });

    print("✅ Uploaded parent key pair to Firestore.");
  }
}