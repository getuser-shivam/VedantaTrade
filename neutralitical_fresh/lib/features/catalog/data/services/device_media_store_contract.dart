import 'package:file_picker/file_picker.dart';

import '../../domain/models/product_media.dart';

abstract class DeviceMediaStore {
  bool get supportsUploads;

  Future<ProductMedia> persistFile({
    required String productId,
    required PlatformFile file,
    required ProductMediaType type,
  });

  Future<void> deleteMedia(ProductMedia media);
}
