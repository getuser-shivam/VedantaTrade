import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/product_media.dart';
import 'device_media_store.dart';
import 'device_media_store_contract.dart';

abstract class ProductMediaPicker {
  Future<List<PlatformFile>> pickMedia();
}

class FilePickerProductMediaPicker implements ProductMediaPicker {
  const FilePickerProductMediaPicker();

  static const _allowedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
    'mp4',
    'mov',
    'avi',
    'm4v',
    'webm',
  ];

  @override
  Future<List<PlatformFile>> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    return result?.files ?? const <PlatformFile>[];
  }
}

abstract class ProductMediaLibraryService {
  bool get supportsUploads;

  Future<Map<String, List<ProductMedia>>> loadUploadedMedia();

  Future<List<ProductMedia>> addMedia({required String productId});

  Future<void> removeMedia({
    required String productId,
    required ProductMedia media,
  });
}

class LocalProductMediaLibraryService implements ProductMediaLibraryService {
  LocalProductMediaLibraryService({
    ProductMediaPicker mediaPicker = const FilePickerProductMediaPicker(),
    DeviceMediaStore? deviceMediaStore,
  }) : _mediaPicker = mediaPicker,
       _deviceMediaStore = deviceMediaStore ?? createDeviceMediaStore();

  static const _storageKey = 'neutralitical_uploaded_product_media_v1';

  final ProductMediaPicker _mediaPicker;
  final DeviceMediaStore _deviceMediaStore;

  @override
  bool get supportsUploads => _deviceMediaStore.supportsUploads;

  @override
  Future<Map<String, List<ProductMedia>>> loadUploadedMedia() async {
    final preferences = await SharedPreferences.getInstance();
    final rawPayload = preferences.getString(_storageKey);
    if (rawPayload == null || rawPayload.trim().isEmpty) {
      return <String, List<ProductMedia>>{};
    }

    final decoded = json.decode(rawPayload);
    if (decoded is! Map<String, dynamic>) {
      return <String, List<ProductMedia>>{};
    }

    final restored = <String, List<ProductMedia>>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is! List) {
        continue;
      }

      final items = value
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => ProductMedia.fromJson(
              item,
              productId: entry.key,
              defaultOrigin: ProductMediaOrigin.uploaded,
            ),
          )
          .toList();

      if (items.isNotEmpty) {
        restored[entry.key] = items;
      }
    }

    return restored;
  }

  @override
  Future<List<ProductMedia>> addMedia({required String productId}) async {
    if (!supportsUploads) {
      throw UnsupportedError(
        'This build cannot store local uploads. Use the Android or desktop app to add media files.',
      );
    }

    final pickedFiles = await _mediaPicker.pickMedia();
    if (pickedFiles.isEmpty) {
      return const <ProductMedia>[];
    }

    final current = await loadUploadedMedia();
    final updatedForProduct = [
      ...(current[productId] ?? const <ProductMedia>[]),
    ];

    for (final file in pickedFiles) {
      final type = _resolveType(file.name);
      if (type == null) {
        continue;
      }

      final stored = await _deviceMediaStore.persistFile(
        productId: productId,
        file: file,
        type: type,
      );
      updatedForProduct.add(stored);
    }

    current[productId] = updatedForProduct;
    await _persist(current);
    return updatedForProduct;
  }

  @override
  Future<void> removeMedia({
    required String productId,
    required ProductMedia media,
  }) async {
    final current = await loadUploadedMedia();
    final existing = current[productId];
    if (existing == null || existing.isEmpty) {
      return;
    }

    current[productId] = existing
        .where((item) => item.id != media.id)
        .toList(growable: false);
    if (current[productId]!.isEmpty) {
      current.remove(productId);
    }

    await _deviceMediaStore.deleteMedia(media);
    await _persist(current);
  }

  Future<void> _persist(Map<String, List<ProductMedia>> items) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = <String, List<Map<String, dynamic>>>{};

    for (final entry in items.entries) {
      payload[entry.key] = entry.value.map((item) => item.toJson()).toList();
    }

    await preferences.setString(_storageKey, json.encode(payload));
  }

  ProductMediaType? _resolveType(String fileName) {
    final extension = fileName.contains('.')
        ? fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()
        : '';

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return ProductMediaType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'm4v':
      case 'webm':
        return ProductMediaType.video;
      default:
        return null;
    }
  }
}
