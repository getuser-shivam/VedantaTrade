import 'device_media_store_contract.dart';
import 'device_media_store_stub.dart'
    if (dart.library.io) 'device_media_store_io.dart'
    if (dart.library.html) 'device_media_store_web.dart'
    as impl;

DeviceMediaStore createDeviceMediaStore() => impl.createDeviceMediaStore();
