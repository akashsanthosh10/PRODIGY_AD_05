import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white12),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Clear result when resuming from background
      setState(() {
        result = null;
      });
      // Resume or restart QR scanning
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
      ),
      body: Column(
        children: [
          Spacer(flex: 1),
          Center(
            child: Container(
              height: 300,
              width: 300,
              child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
            ),
          ),
          Expanded(
              flex: 3,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result != null
                        ? 'QR Data: ${result!.code}'
                        : 'Scan the QR Code',
                    style: TextStyle(fontSize: 20, fontFamily: 'Roboto'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), padding: EdgeInsets.all(18)),
                    onPressed: result != null ? _performAction : null,
                    child: Icon(
                      Icons.search_sharp,
                      size: 60,
                    ),
                  ),
                ],
              )))
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController p1) {
    this.controller = p1;
    controller?.scannedDataStream.listen((scanData) {
      if (result == null || result!.code != scanData.code) {
        setState(() {
          result = scanData;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New QR code scanned: ${scanData.code}')),
        );
      }
    });
  }

  void _performAction() {
    if (result != null) {
      final code = result!.code;
      if (Uri.tryParse(code!)?.isAbsolute ?? false) {
        _launchInBrowser(code);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned data: $code')),
        );
      }
    }
  }

  void _launchInBrowser(String url) async {
    //final Uri uri = Uri.parse(url);
    if (await launchUrl(Uri.parse(url))) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
