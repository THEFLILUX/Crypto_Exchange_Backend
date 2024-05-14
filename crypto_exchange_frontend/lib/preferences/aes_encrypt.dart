import 'package:encrypt/encrypt.dart';

class AESEncrypt {
  static final Key _key = Key.fromUtf8('FgmqZeLNPPhSq7aKekhz2IfrXRJv46Fb');
  static final IV _iv = IV.fromUtf8('BPmumIgR3jTuGkMF');

  static late Encrypter _encrypter;

  static void init() {
    _encrypter = Encrypter(AES(_key));
  }

  // Encrypt and decrypt functions
  static String encryptString(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decryptString(String cipherText) {
    return _encrypter.decrypt64(cipherText, iv: _iv);
  }
}
