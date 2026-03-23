import 'package:file_picker/file_picker.dart';

import '../../domain/models/product_media.dart';
import 'device_media_store_contract.dart';

class _WebDeviceMediaStore implements DeviceMediaStore {
  @override
  bool get supportsUploads => false;

  @override
  Future<ProductMedia> persistFile({
    required String productId,
    required PlatformFile file,
    required ProductMediaType type,
  }) {
    throw UnsupportedError(
      'Local image and video uploads are available in Android, iOS, Windows, Linux, and macOS builds.',
    );
  }

  @override
  Future<void> deleteMedia(ProductMedia media) async {}
}

DeviceMediaStore createDeviceMediaStore() => _WebDeviceMediaStore();
