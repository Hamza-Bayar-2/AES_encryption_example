import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/services.dart';
import 'package:lab2_app_2/pages/encrypted_file_page.dart';
import 'package:lab2_app_2/pages/image_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  enc.Key key = enc.Key.fromSecureRandom(32);
  enc.IV iv = enc.IV.fromSecureRandom(16);
  final List<bool> _selectedNumber = [false, false, true];
  final List<Text> numbers = const [Text("128"), Text("192"), Text("256")];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            button(Icons.image, "Show Decrypted Image", () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ImagePage(fileName: "decryptedFoto.jpg")),
              );
            }),
            button(Icons.file_copy, "Show Encrypted file", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncryptedFilePage(
                        fileName: "encryptedBytes.enc")),
              );
            }),
            button(Icons.delete, "Delete Files", () async {
              await deleteFile("decryptedFoto.jpg");
              await deleteFile("encryptedBytes.enc");
            }),
            button(Icons.camera_alt, "Open Camera", () {}),
            ToggleButtons(
              onPressed: (int index) {
                setState(() {
                  // The button that is tapped is set to true, and the others to false.
                  for (int i = 0; i < _selectedNumber.length; i++) {
                    _selectedNumber[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.deepPurple,
              selectedColor: Colors.white,
              fillColor: Colors.deepPurple,
              color: Colors.deepPurple,
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
              isSelected: _selectedNumber,
              children: numbers,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: "lock",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open_rounded),
            label: "un luck",
          ),
        ],
        onTap: (value) async {
          print(key.bytes);
          if (value == 0) {
            Uint8List fileBytes =
                await loadFileAsBytes("assets/images/Atomium.jpg");
            Uint8List encryptedBytes = await encryptFile(fileBytes);
            await saveFile(
              encryptedBytes,
              "encryptedBytes.enc",
            );
          } else if (value == 1) {
            final directory = await getApplicationDocumentsDirectory();
            final filePath = p.join(directory.path, "encryptedBytes.enc");
            final file = File(filePath);
            Uint8List decryptedFoto =
                await decryptFile(file.readAsBytesSync(), key, iv);
            await saveFile(
              decryptedFoto,
              "decryptedFoto.jpg",
            );
          }
        },
      ),
    );
  }

  TextButton button(IconData icon, String text, Function() function) {
    return TextButton.icon(
      onPressed: () async {
        function();
      },
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
      ),
      icon: Icon(icon),
      label: Text(text),
    );
  }

  Future<Uint8List> loadFileAsBytes(String filePath) async {
    final ByteData data = await rootBundle.load(filePath);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> encryptFile(Uint8List fileBytes) async {
    final encrypter = enc.Encrypter(enc.AES(key));
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

    return encrypted.bytes;
  }

  Future<Uint8List> decryptFile(
      Uint8List encryptedBytes, enc.Key key, enc.IV iv) async {
    final encrypter = enc.Encrypter(enc.AES(key));
    final decrypted =
        encrypter.decryptBytes(enc.Encrypted(encryptedBytes), iv: iv);

    return Uint8List.fromList(decrypted);
  }

  Future<void> saveFile(Uint8List fileAsBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    await file.writeAsBytes(fileAsBytes);
    print('File saved: $filePath');
  }

  Future<void> deleteFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    await file.delete();
    print('File deleted at: $filePath');
  }
}
