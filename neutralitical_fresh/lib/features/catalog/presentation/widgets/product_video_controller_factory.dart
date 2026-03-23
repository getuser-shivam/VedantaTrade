import 'package:video_player/video_player.dart';

import 'product_video_controller_factory_stub.dart'
    if (dart.library.io) 'product_video_controller_factory_io.dart'
    if (dart.library.html) 'product_video_controller_factory_web.dart'
    as impl;

Future<VideoPlayerController> createProductVideoController(String uri) {
  return impl.createProductVideoController(uri);
}
