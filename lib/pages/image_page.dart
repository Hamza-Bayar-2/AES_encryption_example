import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  Future<File?> loadImage(String fileName) async {
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
          future: loadImage("decryptedFoto.jpg"),
          builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text("Error loading image");
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text("No such file");
            } else {
              return Image.file(snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}
