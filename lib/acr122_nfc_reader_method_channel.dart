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
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> requestPermission({required int vendorId, required int productId}) async {
    return await methodChannel.invokeMethod<bool>('requestPermission', {
      'vendorId': vendorId,
      'productId': productId,
    });
  }
}
