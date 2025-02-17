# Flutter AES Encryption Project

## Overview

This Flutter project implements AES encryption using the `encrypt` package. The application allows users to obtain a key by scanning a QR code. With this key, it encrypts and decrypts image or audio files, allowing access to the file again.

## Features

- **AES Encryption & Decryption**: Encrypt and decrypt data using AES algorithm.

- **QR Code Scanning**: Scan and process QR codes using `qr_code_scanner_plus`.

- **Image & Audio Encryption**: Encrypt and decrypt image and audio files.

## Installation

1. Install dependencies:
   ```sh
   flutter pub get
   ```
2. Run the project:
   ```sh
   flutter run
   ```

## Dependencies

The project utilizes the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  encrypt: ^5.0.3
  video_player: ^2.9.2
  firebase_core: ^3.6.0
  path_provider: ^2.1.4
  path: ^1.8.0
  qr_code_scanner_plus: ^2.0.6
  just_audio: ^0.9.42
  audio_video_progress_bar: ^2.0.3
```

## AES Encryption Implementation

The project uses the `encrypt` package to securely encrypt and decrypt data.

### Encryption Example:

```dart
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptText(String text) {
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText) {
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
```

### Usage:

```dart
String encrypted = EncryptionHelper.encryptText("Hello, Flutter!");
print("Encrypted: $encrypted");

String decrypted = EncryptionHelper.decryptText(encrypted);
print("Decrypted: $decrypted");
```

