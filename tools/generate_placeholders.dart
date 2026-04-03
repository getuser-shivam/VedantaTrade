import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

/// Placeholder screenshot generator for App Gallery
/// Run: dart tools/generate_placeholders.dart
void main() {
  final screenshots = [
    {
      'name': 'v3_2_0_gps_tracking.png',
      'title': 'Background GPS Tracking',
      'subtitle': 'Continuous MR Location Monitoring',
    },
    {
      'name': 'v3_2_0_product_catalog.png',
      'title': 'Product Catalog',
      'subtitle': 'Clean Architecture Implementation',
    },
    {
      'name': 'v3_2_0_distribution.png',
      'title': 'Distribution Management',
      'subtitle': 'Marketing & Sales Analytics',
    },
    {
      'name': 'v3_2_0_ui_transitions.png',
      'title': 'Enhanced UI/UX',
      'subtitle': 'Page Transitions & Animations',
    },
  ];

  final outputDir = Directory('assets/screenshots');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  for (final screenshot in screenshots) {
    final image = _generatePlaceholder(
      title: screenshot['title']!,
      subtitle: screenshot['subtitle']!,
    );
    
    final file = File('${outputDir.path}/${screenshot['name']}');
    file.writeAsBytesSync(img.encodePng(image));
    debugPrint('Generated: ${file.path}');
  }
  
  debugPrint('\n✅ All placeholder screenshots generated!');
}

img.Image _generatePlaceholder({
  required String title,
  required String subtitle,
  int width = 1080,
  int height = 1920,
}) {
  // Create dark slate background
  final image = img.Image(width: width, height: height);
  
  // Fill with dark slate color (1A1F2C)
  final bgColor = img.ColorRgba8(26, 31, 44, 255);
  img.fill(image, color: bgColor);
  
  // Add gradient overlay
  for (int y = 0; y < height; y++) {
    final opacity = (y / height * 0.3).clamp(0.0, 1.0);
    final gradientColor = img.ColorRgba8(
      (26 * (1 - opacity) + 99 * opacity).toInt(),
      (31 * (1 - opacity) + 102 * opacity).toInt(),
      (44 * (1 - opacity) + 241 * opacity).toInt(),
      255,
    );
    img.drawLine(image, x1: 0, y1: y, x2: width, y2: y, color: gradientColor);
  }
  
  // Draw title
  final titleY = height ~/ 2 - 100;
  img.drawString(
    image,
    title,
    font: img.arial48,
    x: width ~/ 2 - (title.length * 15),
    y: titleY,
    color: img.ColorRgba8(255, 255, 255, 255),
  );
  
  // Draw subtitle
  img.drawString(
    image,
    subtitle,
    font: img.arial24,
    x: width ~/ 2 - (subtitle.length * 6),
    y: titleY + 80,
    color: img.ColorRgba8(156, 163, 175, 255),
  );
  
  // Draw version badge
  img.fillRect(
    image,
    x1: width ~/ 2 - 80,
    y1: titleY - 150,
    x2: width ~/ 2 + 80,
    y2: titleY - 110,
    color: img.ColorRgba8(99, 102, 241, 255),
    radius: 20,
  );
  
  img.drawString(
    image,
    'v3.2.0',
    font: img.arial24,
    x: width ~/ 2 - 40,
    y: titleY - 140,
    color: img.ColorRgba8(255, 255, 255, 255),
  );
  
  return image;
}
