import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EncryptedFilePage extends StatefulWidget {
  final String fileName;

  const EncryptedFilePage({super.key, required this.fileName});

  @override
  State<EncryptedFilePage> createState() => _EncryptedFilePageState(fileName: fileName);
}

class _EncryptedFilePageState extends State<EncryptedFilePage> {
  final String fileName;

  _EncryptedFilePageState({required this.fileName});

  Future<File?> loadFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    var filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Decrypted Image"),
      ),
      body: Center(
        child: FutureBuilder<File?>(
          future: loadFile(fileName),
          builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text("Error loading file");
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text("No such file");
            } else {
              return SingleChildScrollView(child: Text("${snapshot.data!.readAsBytesSync().sublist(0, 1000)}..."));
            }
          },
        ),
      ),
    );
  }
}
