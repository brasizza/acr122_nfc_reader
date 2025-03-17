import 'package:flutter_test/flutter_test.dart';
import 'package:acr122_nfc_reader/acr122_nfc_reader.dart';
import 'package:acr122_nfc_reader/acr122_nfc_reader_platform_interface.dart';
import 'package:acr122_nfc_reader/acr122_nfc_reader_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAcr122NfcReaderPlatform
    with MockPlatformInterfaceMixin
    implements Acr122NfcReaderPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Acr122NfcReaderPlatform initialPlatform = Acr122NfcReaderPlatform.instance;

  test('$MethodChannelAcr122NfcReader is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAcr122NfcReader>());
  });

  test('getPlatformVersion', () async {
    Acr122NfcReader acr122NfcReaderPlugin = Acr122NfcReader();
    MockAcr122NfcReaderPlatform fakePlatform = MockAcr122NfcReaderPlatform();
    Acr122NfcReaderPlatform.instance = fakePlatform;

    expect(await acr122NfcReaderPlugin.getPlatformVersion(), '42');
  });
}
