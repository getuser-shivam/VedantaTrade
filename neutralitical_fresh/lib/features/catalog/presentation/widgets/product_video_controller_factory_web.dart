import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createProductVideoController(String uri) async {
  if (!uri.startsWith('http://') && !uri.startsWith('https://')) {
    throw UnsupportedError(
      'Local video playback is unavailable in web builds.',
    );
  }

  final controller = VideoPlayerController.networkUrl(Uri.parse(uri));
  await controller.initialize();
  return controller;
}
