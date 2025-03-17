import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acr122_nfc_reader/acr122_nfc_reader_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAcr122NfcReader platform = MethodChannelAcr122NfcReader();
  const MethodChannel channel = MethodChannel('acr122_nfc_reader');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
