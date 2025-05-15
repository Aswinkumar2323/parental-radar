import 'package:pointycastle/ecc/api.dart';

class ECDHKeyExchange {
  static String computeSharedSecret(ECPrivateKey privateKey, ECPublicKey publicKey) {
    final sharedSecret = (publicKey.Q! * privateKey.d!)!.x!.toBigInteger()!;
    return sharedSecret.toRadixString(16).padLeft(64, '0');
  }
}