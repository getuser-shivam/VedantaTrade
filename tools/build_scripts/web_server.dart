import 'dart:io';
import 'dart:convert';

/// Simple Web Server for Testing
/// Used during build process for performance testing
class WebServer {
  static const int _port = 8080;
  static const String _buildPath = 'build/web';

  /// Start web server for testing
  static Future<void> start() async {
    final server = await HttpServer.bind('localhost', _port);
    
    print('🌐 Web server started on http://localhost:$_port');
    print('📁 Serving from: $_buildPath');
    print('⚡ Press Ctrl+C to stop');
    
    await for (HttpRequest request in server) {
      await _handleRequest(request);
    }
  }

  /// Handle HTTP requests
  static Future<void> _handleRequest(HttpRequest request) async {
    final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
    final filePath = '$_buildPath$path';
    
    try {
      final file = File(filePath);
      
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final mimeType = _getMimeType(path);
        
        request.response
          ..headers.contentType = mimeType
          ..headers.add('Access-Control-Allow-Origin', '*')
          ..headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ..headers.add('Access-Control-Allow-Headers', 'Content-Type')
          ..add(bytes)
          ..close();
      } else {
        _send404(request);
      }
    } catch (e) {
      _send500(request, e.toString());
    }
  }

  /// Get MIME type for file
  static String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'html':
        return 'text/html; charset=utf-8';
      case 'css':
        return 'text/css; charset=utf-8';
      case 'js':
        return 'application/javascript; charset=utf-8';
      case 'json':
        return 'application/json; charset=utf-8';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'ico':
        return 'image/x-icon';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Send 404 response
  static void _send404(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('File not found')
      ..close();
  }

  /// Send 500 response
  static void _send500(HttpRequest request, String error) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('Internal server error: $error')
      ..close();
  }
}

/// Main entry point
void main() async {
  await WebServer.start();
}
