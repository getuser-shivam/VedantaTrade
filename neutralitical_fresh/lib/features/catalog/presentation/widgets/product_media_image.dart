import 'package:flutter/material.dart';

import 'product_media_image_stub.dart'
    if (dart.library.io) 'product_media_image_io.dart'
    if (dart.library.html) 'product_media_image_web.dart'
    as impl;

Widget buildProductMediaImage({
  required String uri,
  required BoxFit fit,
  required BorderRadius borderRadius,
  required Widget fallback,
}) {
  return impl.buildProductMediaImage(
    uri: uri,
    fit: fit,
    borderRadius: borderRadius,
    fallback: fallback,
  );
}
