import 'dart:convert';

import 'package:acr122_nfc_reader/core/enum/card_state.dart';
import 'package:acr122_nfc_reader/core/utils/utils.dart';

import 'acr122_nfc_reader_platform_interface.dart';

export 'core/card_monitor.dart';
export 'core/enum/card_state.dart';

class Acr122NfcReader {
  final String? password;

  Acr122NfcReader({this.password});
  Future<String?> getPlatformVersion() {
    return Acr122NfcReaderPlatform.instance.getPlatformVersion();
  }

  Future<bool?> requestPermission(
      {required int vendorId, required int productId}) async {
    return await Acr122NfcReaderPlatform.instance
        .requestPermission(productId: productId, vendorId: vendorId);
  }

  Future<CardState?> getCardState() async {
    final state = (await Acr122NfcReaderPlatform.instance.getCardState());
    if (state == null) {
      return CardState.unknown;
    }
    return CardState.values.firstWhere(
      (element) => element.index == state,
      orElse: () => CardState.unknown,
    );
  }

  Future<void> powerOn() async {
    await Acr122NfcReaderPlatform.instance.powerOn();
  }

  Future<String?> auth() async {
    if (password != null) {
      return await Acr122NfcReaderPlatform.instance
          .auth(password: Utils.toHexString(password!));
    } else {
      final data = {
        'status': 'success',
        'errorCode': '',
        'message': 'No password set'
      };
      return json.encode(data);
    }
  }

  Future<int?> protocol({int block = 0, int protocol = 0x01 | 0x02}) async {
    final data = await Acr122NfcReaderPlatform.instance
        .protocol(block: block, protocol: protocol);
    return data;
  }

  Future<String?> read({int block = 0, required List<int> command}) async {
    final data = await Acr122NfcReaderPlatform.instance
        .read(block: block, command: command);
    return data;
  }
}
