import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/product_media.dart';
import 'device_media_store_contract.dart';

class _IoDeviceMediaStore implements DeviceMediaStore {
  @override
  bool get supportsUploads => true;

  @override
  Future<ProductMedia> persistFile({
    required String productId,
    required PlatformFile file,
    required ProductMediaType type,
  }) async {
    final sourcePath = file.path;
    if (sourcePath == null || sourcePath.trim().isEmpty) {
      throw UnsupportedError('The selected file could not be read.');
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw UnsupportedError('The selected file is no longer available.');
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final targetDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}product_media'
      '${Platform.pathSeparator}$productId',
    );
    await targetDirectory.create(recursive: true);

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final extension = _normalizedExtension(file);
    final safeStem = _sanitizeFileName(
      file.name.replaceFirst(RegExp(r'\.[^.]+$'), ''),
    );
    final targetPath =
        '${targetDirectory.path}${Platform.pathSeparator}$safeStem'
        '_$timestamp$extension';
    final copiedFile = await sourceFile.copy(targetPath);

    return ProductMedia(
      id: '${productId}_$timestamp',
      productId: productId,
      type: type,
      origin: ProductMediaOrigin.uploaded,
      uri: copiedFile.path,
      title: file.name,
      caption: 'Uploaded from this device',
      isPrimary: false,
    );
  }

  @override
  Future<void> deleteMedia(ProductMedia media) async {
    final file = File(media.uri);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _normalizedExtension(PlatformFile file) {
    final rawExtension = file.extension?.trim();
    if (rawExtension == null || rawExtension.isEmpty) {
      return file.name.contains('.')
          ? file.name.substring(file.name.lastIndexOf('.'))
          : '';
    }

    return '.${rawExtension.toLowerCase()}';
  }

  String _sanitizeFileName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (cleaned.isEmpty) {
      return 'product_media';
    }

    return cleaned;
  }
}

DeviceMediaStore createDeviceMediaStore() => _IoDeviceMediaStore();
