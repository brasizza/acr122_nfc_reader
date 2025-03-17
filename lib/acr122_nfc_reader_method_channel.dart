import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'acr122_nfc_reader_platform_interface.dart';

/// An implementation of [Acr122NfcReaderPlatform] that uses method channels.
class MethodChannelAcr122NfcReader extends Acr122NfcReaderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('acr122_nfc_reader');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> requestPermission(
      {required int vendorId, required int productId}) async {
    return await methodChannel.invokeMethod<bool>('requestPermission', {
      'vendorId': vendorId,
      'productId': productId,
    });
  }

  @override
  Future<void> powerOn() async {
    await methodChannel.invokeMethod<bool>('powerOn');
  }

  @override
  Future<int?> getCardState() async {
    return await methodChannel.invokeMethod<int>('getCardState');
  }

  @override
  Future<String?> auth({required String password, int block = 0}) async {
    return await methodChannel
        .invokeMethod<String>('auth', {'password': password, "block": block});
  }

  @override
  Future<String?> read({required int block, required List<int> command}) async {
    return await methodChannel
        .invokeMethod<String>('read', {'block': block, "command": command});
  }

  @override
  Future<int?> protocol({required int block, required int protocol}) async {
    return await methodChannel
        .invokeMethod<int>('protocol', {'block': block, "protocol": protocol});
  }
}
