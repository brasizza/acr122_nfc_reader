import 'dart:async';
import 'dart:convert';

import '../acr122_nfc_reader.dart';

class CardStateMonitor {
  final Acr122NfcReader _reader;
  StreamSubscription<CardState?>? _subscription;
  CardState lastState = CardState.unknown;
  CardStateMonitor(this._reader);

  // Starts a periodic stream that checks the card state every second.
  Stream<String> startMonitoring({int block = 0}) async* {
    while (true) {
      final currentState = await _reader.getCardState();
      print("currentState => $currentState");
      if (currentState != null) {
        if (currentState == CardState.present &&
            lastState != CardState.present) {
          final responseAuth = await auth(block: block);
          if (responseAuth != null) {
            if (responseAuth['status'] == 'success') {
              await _reader.powerOn();
              await _reader.protocol(block: block);
              final response = await read(block: block);
              yield response ?? 'ERROR_READING_CARD';
            } else {
              yield 'ERROR_READING_CARD';
            }
          } else {
            yield 'AUTH_FAIL';
          }
        }
        lastState = currentState;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<String?> read({int block = 0}) async {
    final response = await _reader
        .read(block: block, command: [0xFF, 0xB0, 0x0, 0x01, 0x10]);
    return response;
  }

  Future<Map?> auth({int block = 0}) async {
    final auth = await _reader.auth();
    if (auth == null) {
      return null;
    }
    return json.decode(auth);
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }
}
