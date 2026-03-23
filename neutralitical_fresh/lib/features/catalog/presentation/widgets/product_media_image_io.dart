import 'dart:io';

import 'package:flutter/material.dart';

Widget buildProductMediaImage({
  required String uri,
  required BoxFit fit,
  required BorderRadius borderRadius,
  required Widget fallback,
}) {
  final image = uri.startsWith('http://') || uri.startsWith('https://')
      ? Image.network(
          uri,
          fit: fit,
          errorBuilder: (_, _, _) => fallback,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const ColoredBox(
              color: Color(0xFFF1EBDF),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        )
      : Image.file(File(uri), fit: fit, errorBuilder: (_, _, _) => fallback);

  return ClipRRect(borderRadius: borderRadius, child: image);
}
