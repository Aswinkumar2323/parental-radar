import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/export.dart';
import '../ecdh/ecdh_key_exchange.dart';
import '../utils/aes_key_derivation.dart';

class ParentDecryption {
  static Future<Map<String, dynamic>> decrypt(
    Map<String, dynamic> encryptedResponse,
    String username,
  ) async {
    try {
      // 1. Extract 'data' and 'timestamp' from the response
      final encryptedPayload =
          encryptedResponse['data'] as Map<String, dynamic>?;
      final timestamp = encryptedResponse['timestamp'];

      if (encryptedPayload == null) {
        throw Exception("Missing 'data' field in encrypted response.");
      }

      // 2. Load parent private key
      final doc =
          await FirebaseFirestore.instance
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

      // 3. Parse target public key from payload
      final targetKeyBytes = base64Decode(encryptedPayload['targetPublicKey']);
      if (targetKeyBytes[0] != 0x04)
        throw Exception("Invalid target public key format");

      final x = BigInt.parse(
        hex.encode(targetKeyBytes.sublist(1, 33)),
        radix: 16,
      );
      final y = BigInt.parse(
        hex.encode(targetKeyBytes.sublist(33, 65)),
        radix: 16,
      );
      final targetPublicKey = ECPublicKey(
        domainParams.curve.createPoint(x, y),
        domainParams,
      );

      // 4. Compute shared secret
      final sharedSecretHex = ECDHKeyExchange.computeSharedSecret(
        parentPrivateKey,
        targetPublicKey,
      );
      final sharedSecretBytes = Uint8List.fromList(hex.decode(sharedSecretHex));

      // 5. Derive AES key using salt
      final saltBytes = base64Decode(encryptedPayload['salt']);
      final aesKey = await AESKeyDerivation.deriveAESKey(
        sharedSecretBytes,
        saltBytes,
      );

      // 6. Decrypt with AES-GCM
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
      final decryptedJson =
          jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;

      print("✅ Decryption complete.");
      return {'data': decryptedJson, 'timestamp': timestamp};
    } catch (e) {
      print("❌ Decryption failed: $e");
      return {};
    }
  }
}