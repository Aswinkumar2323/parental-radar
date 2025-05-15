import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/export.dart';
import '../ecdh/ecdh_key_exchange.dart';
import '../utils/aes_key_derivation.dart';

class ParentDecryption {
  static Future<List<Map<String, dynamic>>> decrypt(List<dynamic> encryptedList, {required String username}) async {
    final List<Map<String, dynamic>> decryptedList = [];

    for (final item in encryptedList) {
      final encryptedPayload = item['data'];
      final timestamp = item['timestamp'];

      final decrypted = await _decryptSingle(encryptedPayload, username);
      if (decrypted.isNotEmpty) {
        decryptedList.add({
          'data': decrypted,
          'timestamp': timestamp,
        });
      }
    }

    return decryptedList;
  }

  static Future<Map<String, dynamic>> _decryptSingle(Map<String, dynamic> encryptedPayload, String username) async {
    try {
      // 1. Load parent private key
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(username)
          .collection('keys')
          .doc('latest')
          .get();
      if (!doc.exists) throw Exception("Parent key not found!");

      final data = doc.data()!;
      final privateKeyHex = data['privateKey'];
      final privateKeyInt = BigInt.parse(privateKeyHex, radix: 16);
      final domainParams = ECDomainParameters('secp256r1');
      final parentPrivateKey = ECPrivateKey(privateKeyInt, domainParams);

      // 2. Parse target public key
      final targetKeyBytes = base64Decode(encryptedPayload['targetPublicKey']);
      if (targetKeyBytes[0] != 0x04) throw Exception("Invalid target public key format");

      final x = BigInt.parse(hex.encode(targetKeyBytes.sublist(1, 33)), radix: 16);
      final y = BigInt.parse(hex.encode(targetKeyBytes.sublist(33, 65)), radix: 16);
      final targetPublicKey = ECPublicKey(domainParams.curve.createPoint(x, y), domainParams);

      // 3. Compute shared secret
      final sharedSecretHex = ECDHKeyExchange.computeSharedSecret(parentPrivateKey, targetPublicKey);
      final sharedSecretBytes = Uint8List.fromList(hex.decode(sharedSecretHex));

      // 4. Derive AES key
      final saltBytes = base64Decode(encryptedPayload['salt']);
      final aesKey = await AESKeyDerivation.deriveAESKey(sharedSecretBytes, saltBytes);

      // 5. Decrypt with AES-GCM
      final cipherText = base64Decode(encryptedPayload['cipherText']);
      final nonce = base64Decode(encryptedPayload['nonce']);
      final authTag = base64Decode(encryptedPayload['authTag']);
      final combined = Uint8List.fromList([...cipherText, ...authTag]);

      final gcm = GCMBlockCipher(AESEngine());
      gcm.init(
        false,
        AEADParameters(KeyParameter(aesKey), 128, nonce, Uint8List(0)),
      );

      final decrypted = gcm.process(combined);
      final decryptedJson = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;

      print("✅ Decryption successful.");
      return decryptedJson;
    } catch (e) {
      print("❌ Decryption failed: $e");
      return {};
    }
  }
}