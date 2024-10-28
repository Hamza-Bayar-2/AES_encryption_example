import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lab2_app_2/myHomePage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
        leading: IconButton(onPressed: () {
          Navigator.pop(context, "cancel");
        }, icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: <Widget>[
          /*Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),*/
          ElevatedButton(onPressed: () {
            _returnTemp();
          }, child: Text("bas")),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                  'Veri: ${result!.code}')
                  : const Text('Bir kod taratın'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        qrReturn = result!.code.toString();
      });
    });
  }

  void _returnTemp() {
      setState(() {
        qrReturn = "abuzer";
        Navigator.pop(context);
      });

  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}