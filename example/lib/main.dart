import 'dart:async';
import 'dart:developer';

import 'package:acr122_nfc_reader/acr122_nfc_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  late final CardStateMonitor _cardStateMonitor;
  StreamSubscription<String>? _streamSubscription;
  final _acr122NfcReaderPlugin = Acr122NfcReader(password: '4e5533');

  bool permission = false;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _cardStateMonitor.stopMonitoring();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _acr122NfcReaderPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      permission =
                          (await _acr122NfcReaderPlugin.requestPermission(
                                vendorId: 0x072F,
                                productId: 0x2200,
                              )) ??
                              false;
                      log(permission.toString());
                    } catch (e) {
                      permission = false;
                      log(e.toString());
                    }
                  },
                  child: const Text("Request USB")),
              ElevatedButton(
                  onPressed: () async {
                    if (permission) {
                      _cardStateMonitor =
                          CardStateMonitor(_acr122NfcReaderPlugin);
                      _streamSubscription ??= _cardStateMonitor
                          .startMonitoring(block: 0)
                          .listen((state) {
                        log('Card is present! $state'); // This prints only when a transition to present occurs.
                        // You can call any other method here instead of or in addition to printing.
                      });
                    } else {
                      log("SEM PERMISSAO OU SEM DEVICE!");
                    }
                  },
                  child: const Text("Start reading")),
            ],
          ),
        ),
      ),
    );
  }
}
