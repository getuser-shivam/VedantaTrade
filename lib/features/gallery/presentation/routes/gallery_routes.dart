import 'package:flutter/material.dart';
import '../screens/app_gallery_screen.dart';
import '../screens/gallery_screen.dart';

class GalleryRoutes {
  static const String appGallery = '/gallery/app';
  static const String gallery = '/gallery';
  
  static Map<String, WidgetBuilder> get routes => {
    appGallery: (context) => const AppGalleryScreen(),
    gallery: (context) => const GalleryScreen(),
  };

  static void navigateToAppGallery(BuildContext context) {
    Navigator.pushNamed(context, appGallery);
  }

  static void navigateToGallery(BuildContext context) {
    Navigator.pushNamed(context, gallery);
  }
}
