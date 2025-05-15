import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class AESKeyDerivation {
  static Future<Uint8List> deriveAESKey(Uint8List sharedSecret, Uint8List salt) async {
    final hkdf = Hkdf(
      hmac: Hmac.sha256(),
      outputLength: 32,
    );

    final secretKey = await hkdf.deriveKey(
      secretKey: SecretKey(sharedSecret),
      nonce: salt,
    );

    return Uint8List.fromList(await secretKey.extractBytes());
  }
}