import 'package:flutter/material.dart';

class GalleryRoutes {
  static const String galleryOverview = '/gallery/overview';
  static const String appGallery = '/gallery/app';
  static const String versionComparison = '/gallery/comparison';
  static const String galleryStatistics = '/gallery/statistics';
  static const String versionDetails = '/gallery/version/:version';
}

class GalleryRouteArguments {
  final String? version;
  final Map<String, dynamic>? versionData;

  GalleryRouteArguments({this.version, this.versionData});
}
