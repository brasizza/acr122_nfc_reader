import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'acr122_nfc_reader_method_channel.dart';

abstract class Acr122NfcReaderPlatform extends PlatformInterface {
  /// Constructs a Acr122NfcReaderPlatform.
  Acr122NfcReaderPlatform() : super(token: _token);

  static final Object _token = Object();

  static Acr122NfcReaderPlatform _instance = MethodChannelAcr122NfcReader();

  /// The default instance of [Acr122NfcReaderPlatform] to use.
  ///
  /// Defaults to [MethodChannelAcr122NfcReader].
  static Acr122NfcReaderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Acr122NfcReaderPlatform] when
  /// they register themselves.
  static set instance(Acr122NfcReaderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> requestPermission(
      {required int vendorId, required int productId}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<int?> getCardState() async {
    throw UnimplementedError('getCardState() has not been implemented.');
  }

  Future<void> powerOn() async {
    throw UnimplementedError('powerOff() has not been implemented.');
  }

  Future<String?> auth({required String password}) async {
    throw UnimplementedError('auth() has not been implemented.');
  }

  Future<String?> read({required int block, required List<int> command}) async {
    throw UnimplementedError('read() has not been implemented.');
  }

  Future<int?> protocol({required int block, required int protocol}) async {
    throw UnimplementedError('protocol() has not been implemented.');
  }
}
