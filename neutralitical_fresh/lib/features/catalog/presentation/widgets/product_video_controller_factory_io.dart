import 'dart:io';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createProductVideoController(String uri) async {
  final controller = uri.startsWith('http://') || uri.startsWith('https://')
      ? VideoPlayerController.networkUrl(Uri.parse(uri))
      : VideoPlayerController.file(File(uri));
  await controller.initialize();
  return controller;
}
