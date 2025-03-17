import 'acr122_nfc_reader_platform_interface.dart';

class Acr122NfcReader {
  Future<String?> getPlatformVersion() {
    return Acr122NfcReaderPlatform.instance.getPlatformVersion();
  }

  Future<bool?> requestPermission({required int vendorId, required int productId}) async {
    return await Acr122NfcReaderPlatform.instance.requestPermission(productId: productId, vendorId: vendorId);
  }
}
