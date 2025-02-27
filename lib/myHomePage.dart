import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/services.dart';
import 'package:lab2_app_2/pages/audio_page.dart';
import 'package:lab2_app_2/pages/encrypted_file_page.dart';
import 'package:lab2_app_2/pages/image_page.dart';
import 'package:lab2_app_2/pages/qr_scann_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

String qrReturn = "";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  enc.Key? key;
  enc.IV? iv;
  final List<bool> _selectedNumber = [false, false, false];
  final List<Text> numbers = const [Text("128"), Text("192"), Text("256")];
  final List<bool> _selectedType = [true, false];
  final List<Text> types = const [Text("image"), Text("audio")];
  int? selectedKeySizeByte;
  String decryptedAndSavedFileName = "decryptedFoto.jpg";
  String fileToLoad = "assets/images/Atomium.jpg";

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                button(_selectedType.first == true ? Icons.image : Icons.audio_file, "Show Decrypted File", () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _selectedType.first == true
                            ? ImagePage(fileName: decryptedAndSavedFileName)
                            : AudioPage(fileName: decryptedAndSavedFileName),
                      ));
                }),
                button(Icons.file_copy, "Show Encrypted File", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EncryptedFilePage(
                            fileName: "encryptedBytes.enc")),
                  );
                }),
                button(Icons.delete, "Delete Files", () async {
                  setState(() {
                    key = null;
                    iv = null;
                  });
                  await deleteFile(decryptedAndSavedFileName);
                  await deleteFile("encryptedBytes.enc");
                }),
                ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _selectedNumber.length; i++) {
                        _selectedNumber[i] = i == index;
                      }
                      if (index == 0) {
                        selectedKeySizeByte = 16;
                      } else if (index == 1) {
                        selectedKeySizeByte = 24;
                      } else if (index == 2) {
                        selectedKeySizeByte = 32;
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
                ToggleButtons(
                  onPressed: (int index) async {
                    setState(() {
                      for (int i = 0; i < _selectedType.length; i++) {
                        _selectedType[i] = i == index;
                      }
                      if (index == 0) {
                        decryptedAndSavedFileName = "decryptedFoto.jpg";
                        fileToLoad = "assets/images/Atomium.jpg";
                      } else {
                        decryptedAndSavedFileName = "decryptedFile.mp3";
                        fileToLoad = "assets/audios/wind_chimes.mp3";
                      }

                      key = null;
                      iv = null;
                    });
                    await deleteFile(decryptedAndSavedFileName);
                    await deleteFile("encryptedBytes.enc");
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
                  isSelected: _selectedType,
                  children: types,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Key: ${key?.bytes}",
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "IV: ${iv?.bytes}",
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
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
            label: "un lock",
          ),
        ],
        onTap: (value) async {
          if (value == 0) {
            if(selectedKeySizeByte == null) {
              showSnackBar(context, message: 'Please select key size', backgroundColor: Colors.redAccent);
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QrScanPage()),
            ).then(
              (value) async {
                if (qrReturn == "" || value == "cancel") {
                  return;
                }
                iv = enc.IV.fromSecureRandom(16);
                setAESKey(selectedKeySizeByte!, qrReturn);
                Uint8List fileBytes = await loadFileAsBytes(
                  fileToLoad,
                );
                Uint8List? encryptedBytes =
                    await encryptFile(context, fileBytes);
                if (encryptedBytes != null) {
                  await saveFile(
                    encryptedBytes,
                    "encryptedBytes.enc",
                  );
                } else {
                  deleteFile("encryptedBytes.enc");
                }
              },
            );
          } else if (value == 1) {
            if(selectedKeySizeByte == null) {
              showSnackBar(context, message: 'Please select key size', backgroundColor: Colors.redAccent);
              return;
            }else if (key == null) {
              showSnackBar(context, message: 'There is no file to encrypt', backgroundColor: Colors.redAccent);
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QrScanPage()),
            ).then(
              (value) async {
                if (qrReturn == "" || value == "cancel") {
                  return;
                }
                setAESKey(selectedKeySizeByte!, qrReturn);
                final directory = await getApplicationDocumentsDirectory();
                final filePath = p.join(directory.path, "encryptedBytes.enc");
                final file = File(filePath);
                Uint8List? decryptedFoto = await decryptFile(
                    context, file.readAsBytesSync(), key!, iv!);
                if (decryptedFoto != null) {
                  await saveFile(
                    decryptedFoto,
                    decryptedAndSavedFileName,
                  );
                } else {
                  deleteFile(decryptedAndSavedFileName);
                }
              },
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

  void setAESKey(int keySizeByte, String keyAsString) {
    List<int> tempKeyByteList = List<int>.from(utf8.encode(keyAsString));

    tempKeyByteList = paddingTheKey(tempKeyByteList, keySizeByte);

    setState(() {
      key = enc.Key(Uint8List.fromList(tempKeyByteList));
    });
  }

  List<int> paddingTheKey(List<int> tempKeyByteList, int keySizeByte) {
    if (tempKeyByteList.length < keySizeByte) {
      int paddingAmount = keySizeByte - tempKeyByteList.length;
      tempKeyByteList.addAll(List.filled(paddingAmount, 0));
    } else if (tempKeyByteList.length > keySizeByte) {
      tempKeyByteList = tempKeyByteList.sublist(0, keySizeByte);
    }

    return tempKeyByteList;
  }

  Future<Uint8List> loadFileAsBytes(String filePath) async {
    final ByteData data = await rootBundle.load(filePath);
    return data.buffer.asUint8List();
  }

  Future<Uint8List?> encryptFile(BuildContext context, Uint8List fileBytes) async {
    final encrypter = enc.Encrypter(enc.AES(key!));

    try {
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      showSnackBar(context, message: 'Encryption completed', backgroundColor: Colors.green);
      return encrypted.bytes;
    } catch (e) {
      showSnackBar(context, message: 'An error occurred during the encryption process', backgroundColor: Colors.redAccent);
      return null;
    }
  }

  Future<Uint8List?> decryptFile(BuildContext context, Uint8List encryptedBytes, enc.Key key, enc.IV iv) async {
    final encrypter = enc.Encrypter(enc.AES(key));

    try {
      final decrypted =
          encrypter.decryptBytes(enc.Encrypted(encryptedBytes), iv: iv);
      showSnackBar(context, message: 'Decryption completed', backgroundColor: Colors.green);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      showSnackBar(context, message: 'An error occurred during the decryption process', backgroundColor: Colors.redAccent);
      return null;
    }
  }

  Future<void> saveFile(Uint8List fileAsBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    await file.writeAsBytes(fileAsBytes);
  }

  Future<void> deleteFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    if (file.existsSync()) {
      await file.delete();
    }
  }

  void showSnackBar(BuildContext context, {required String message, required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(5),
            topLeft: Radius.circular(5),
          ),
        ),
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: const TextStyle(fontSize: 17),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

}
