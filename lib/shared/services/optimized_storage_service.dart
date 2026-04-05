import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Optimized Storage Service with improved performance and maintainability
/// Features: Lazy initialization, caching, compression, and better error handling
class OptimizedStorageService {
  static OptimizedStorageService? _instance;
  static OptimizedStorageService get instance => _instance ??= OptimizedStorageService._();
  
  OptimizedStorageService._();
  
  // Lazy initialization
  Directory? _appDirectory;
  Directory? _documentsDirectory;
  Directory? _tempDirectory;
  late FlutterSecureStorage _secureStorage;
  
  // Cache for performance optimization
  final Map<String, String> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Timer?> _cacheTimers = {};
  
  // Constants
  static const int maxCacheSize = 100;
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  
  Future<void> initialize() async {
    if (_appDirectory != null) return; // Already initialized
    
    try {
      _appDirectory = await getApplicationDocumentsDirectory();
      _documentsDirectory = await getApplicationDocumentsDirectory();
      _tempDirectory = await getTemporaryDirectory();
      _secureStorage = const FlutterSecureStorage();
      
      // Create necessary directories
      await _createDirectories();
      
      // Clean expired cache entries
      _cleanExpiredCache();
      
      print('Storage service initialized successfully');
    } catch (e) {
      print('Failed to initialize storage service: $e');
      rethrow;
    }
  }
  
  Future<void> _createDirectories() async {
    final directories = [
      '${_appDirectory!.path}/images',
      '${_appDirectory!.path}/documents',
      '${_appDirectory!.path}/cache',
      '${_appDirectory!.path}/logs',
      '${_appDirectory!.path}/backups',
      '${_appDirectory!.path}/temp',
    ];
    
    await Future.wait(
      directories.map((dirPath) => _createDirectoryIfNotExists(dirPath)),
    );
  }
  
  Future<void> _createDirectoryIfNotExists(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e) {
      print('Failed to create directory $dirPath: $e');
    }
  }
  
  // Optimized File Operations
  Future<void> writeStringToFile(String fileName, String content, {
    String? subDirectory,
    bool compress = false,
    bool cache = true,
  }) async {
    try {
      // Validate inputs
      if (fileName.isEmpty) {
        throw ArgumentError('File name cannot be empty');
      }
      
      if (content.length > maxFileSize) {
        throw ArgumentError('File content too large');
      }
      
      // Process content
      String processedContent = content;
      if (compress) {
        processedContent = _compressContent(content);
      }
      
      final file = await _getFile(fileName, subDirectory: subDirectory);
      await file.writeAsString(processedContent);
      
      // Cache if requested
      if (cache) {
        _cacheData(fileName, processedContent);
      }
      
      print('Successfully wrote to file: $fileName');
    } catch (e) {
      print('Failed to write to file $fileName: $e');
      rethrow;
    }
  }
  
  Future<String> readStringFromFile(String fileName, {
    String? subDirectory,
    bool useCache = true,
  }) async {
    try {
      // Check cache first
      if (useCache && _memoryCache.containsKey(fileName)) {
        final timestamp = _cacheTimestamps[fileName];
        if (timestamp != null && 
            DateTime.now().difference(timestamp).inMinutes < 60) {
          return _memoryCache[fileName]!;
        }
      }
      
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (!await file.exists()) {
        throw FileSystemException('File not found: $fileName', fileName);
      }
      
      final content = await file.readAsString();
      
      // Cache the result
      if (useCache) {
        _cacheData(fileName, content);
      }
      
      return content;
    } catch (e) {
      print('Failed to read from file $fileName: $e');
      rethrow;
    }
  }
  
  Future<void> writeJsonToFile(String fileName, Map<String, dynamic> json, {
    String? subDirectory,
    bool compress = true,
  }) async {
    try {
      final jsonString = jsonEncode(json);
      await writeStringToFile(fileName, jsonString, 
        subDirectory: subDirectory, 
        compress: compress);
    } catch (e) {
      print('Failed to write JSON to file $fileName: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> readJsonFromFile(String fileName, {
    String? subDirectory,
  }) async {
    try {
      final content = await readStringFromFile(fileName, subDirectory: subDirectory);
      if (content.isEmpty) return null;
      
      return jsonDecode(content) as Map<String, dynamic>?;
    } catch (e) {
      print('Failed to read JSON from file $fileName: $e');
      return null;
    }
  }
  
  Future<void> deleteFile(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        await file.delete();
        
        // Remove from cache
        _memoryCache.remove(fileName);
        _cacheTimestamps.remove(fileName);
        
        print('Successfully deleted file: $fileName');
      }
    } catch (e) {
      print('Failed to delete file $fileName: $e');
    }
  }
  
  Future<bool> fileExists(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  // Cache Management
  void _cacheData(String key, String data) {
    // Remove oldest cache entry if cache is full
    if (_memoryCache.length >= maxCacheSize) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
    
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    // Set up cache expiry timer
    _cacheTimers[key]?.cancel();
    _cacheTimers[key] = Timer(cacheExpiry, () {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      _cacheTimers.remove(key);
    });
  }
  
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value).inMinutes >= 60) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      _cacheTimers[key]?.cancel();
      _cacheTimers.remove(key);
    }
  }
  
  Future<void> clearCache() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    
    for (final timer in _cacheTimers.values) {
      timer?.cancel();
    }
    _cacheTimers.clear();
    
    print('Cache cleared');
  }
  
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _memoryCache.length,
      'maxCacheSize': maxCacheSize,
      'cacheHitRatio': _calculateCacheHitRatio(),
    };
  }
  
  double _calculateCacheHitRatio() {
    // This would require tracking cache hits/misses
    // For now, return an estimated ratio based on cache usage
    return _memoryCache.length / maxCacheSize;
  }
  
  // Backup Operations
  Future<void> createBackup({
    String? backupName,
    List<String>? includeFiles,
    bool compress = true,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = backupName ?? 'backup_$timestamp';
      final backupDir = Directory('${_appDirectory!.path}/backups/$name');
      
      await _createDirectoryIfNotExists(backupDir.path);
      
      final files = includeFiles ?? await _getBackupableFiles();
      
      for (final filePath in files) {
        final file = File(filePath);
        if (await file.exists()) {
          final fileName = file.path.split('/').last;
          final backupFile = File('${backupDir.path}/$fileName');
          
          if (compress) {
            final content = await file.readAsBytes();
            final compressedContent = _compressBytes(content);
            await backupFile.writeAsBytes(compressedContent);
          } else {
            await file.copy(backupFile.path);
          }
        }
      }
      
      print('Backup created: $name');
    } catch (e) {
      print('Failed to create backup: $e');
      rethrow;
    }
  }
  
  Future<List<String>> _getBackupableFiles() async {
    final backupableFiles = <String>[];
    
    // Get all files from important directories
    final directories = [
      '${_appDirectory!.path}/documents',
      '${_appDirectory!.path}/images',
    ];
    
    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (final file in files) {
          if (file is File) {
            backupableFiles.add(file.path);
          }
        }
      }
    }
    
    return backupableFiles;
  }
  
  Future<void> restoreBackup(String backupName) async {
    try {
      final backupDir = Directory('${_appDirectory!.path}/backups/$backupName');
      
      if (!await backupDir.exists()) {
        throw ArgumentError('Backup not found: $backupName');
      }
      
      final files = await backupDir.list().toList();
      
      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final targetPath = await _getRestorePath(fileName);
          
          if (targetPath != null) {
            await file.copy(targetPath!);
          }
        }
      }
      
      print('Backup restored: $backupName');
    } catch (e) {
      print('Failed to restore backup: $e');
      rethrow;
    }
  }
  
  Future<String?> _getRestorePath(String fileName) async {
    // Determine the appropriate restore path based on file type
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '${_appDirectory!.path}/images/$fileName';
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return '${_appDirectory!.path}/documents/$fileName';
      default:
        return '${_appDirectory!.path}/$fileName';
    }
  }
  
  Future<List<String>> listBackups() async {
    try {
      final backupDir = Directory('${_appDirectory!.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final backups = await backupDir.list().toList();
      final backupNames = <String>[];
      
      for (final entity in backups) {
        if (entity is Directory) {
          backupNames.add(entity.path.split('/').last);
        }
      }
      
      return backupNames;
    } catch (e) {
      print('Failed to list backups: $e');
      return [];
    }
  }
  
  Future<void> deleteBackup(String backupName) async {
    try {
      final backupDir = Directory('${_appDirectory!.path}/backups/$backupName');
      
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
        print('Backup deleted: $backupName');
      }
    } catch (e) {
      print('Failed to delete backup: $e');
    }
  }
  
  // Logging Operations
  Future<void> writeLog(String message, {String logLevel = 'INFO'}) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$timestamp] [$logLevel] $message\n';
      
      final logFile = await _getLogFile();
      await logFile.writeAsString(logMessage, mode: FileMode.append);
      
      // Keep only last 1000 log entries
      await _trimLogFile(logFile);
    } catch (e) {
      print('Failed to write log: $e');
    }
  }
  
  Future<File> _getLogFile() async {
    final logDir = Directory('${_appDirectory!.path}/logs');
    await _createDirectoryIfNotExists(logDir.path);
    
    final today = DateTime.now();
    final logFileName = 'app_${today.year}_${today.month}_${today.day}.log';
    
    return File('${logDir.path}/$logFileName');
  }
  
  Future<void> _trimLogFile(File logFile) async {
    try {
      final lines = await logFile.readAsLines();
      
      if (lines.length > 1000) {
        final trimmedLines = lines.sublist(lines.length - 1000);
        await logFile.writeAsString(trimmedLines.join('\n'));
      }
    } catch (e) {
      print('Failed to trim log file: $e');
    }
  }
  
  Future<List<String>> readLogs({int maxLines = 100}) async {
    try {
      final logFile = await _getLogFile();
      if (!await logFile.exists()) {
        return [];
      }
      
      final lines = await logFile.readAsLines();
      final startIndex = lines.length > maxLines ? lines.length - maxLines : 0;
      
      return lines.sublist(startIndex);
    } catch (e) {
      print('Failed to read logs: $e');
      return [];
    }
  }
  
  Future<void> clearLogs() async {
    try {
      final logDir = Directory('${_appDirectory!.path}/logs');
      
      if (await logDir.exists()) {
        await for (final entity in logDir.list()) {
          await entity.delete(recursive: true);
        }
        print('Logs cleared');
      }
    } catch (e) {
      print('Failed to clear logs: $e');
    }
  }
  
  // Image Operations
  Future<void> saveImage(String fileName, List<int> imageBytes, {
    String? subDirectory,
    int quality = 85,
  }) async {
    try {
      if (imageBytes.isEmpty) {
        throw ArgumentError('Image bytes cannot be empty');
      }
      
      // Compress image if needed
      final compressedBytes = _compressImage(imageBytes, quality);
      
      final file = await _getFile(fileName, subDirectory: 'images');
      await file.writeAsBytes(compressedBytes);
      
      print('Image saved: $fileName');
    } catch (e) {
      print('Failed to save image: $e');
      rethrow;
    }
  }
  
  Future<List<int>?> loadImage(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: 'images');
      if (!await file.exists()) {
        return null;
      }
      
      return await file.readAsBytes();
    } catch (e) {
      print('Failed to load image: $e');
      return null;
    }
  }
  
  // Utility Methods
  Future<File> _getFile(String fileName, {String? subDirectory}) async {
    String basePath = _appDirectory!.path;
    
    if (subDirectory != null) {
      basePath = '$basePath/$subDirectory';
    }
    
    return File('$basePath/$fileName');
  }
  
  String _compressContent(String content) {
    // Simple compression - in a real app, you'd use proper compression
    return content.replaceAll(RegExp(r'\s+'), ' ');
  }
  
  List<int> _compressBytes(List<int> bytes, int quality) {
    // In a real app, you'd use image compression library
    // For now, just return the original bytes
    return bytes;
  }
  
  List<int> _compressImage(List<int> imageBytes, int quality) {
    // In a real app, you'd use image compression library
    // For now, just return the original bytes
    return imageBytes;
  }
  
  // Storage Information
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final appDir = _appDirectory!;
      final documentsDir = _documentsDirectory!;
      final tempDir = _tempDirectory!;
      
      // Calculate directory sizes
      final appDirSize = await _calculateDirectorySize(appDir);
      final documentsDirSize = await _calculateDirectorySize(documentsDir);
      final tempDirSize = await _calculateDirectorySize(tempDir);
      
      return {
        'appDirectory': appDir.path,
        'documentsDirectory': documentsDir.path,
        'tempDirectory': tempDir.path,
        'appDirectorySize': appDirSize,
        'documentsDirectorySize': documentsDirSize,
        'tempDirectorySize': tempDirSize,
        'totalSize': appDirSize + documentsDirSize + tempDirSize,
        'freeSpace': await _getFreeSpace(),
        'cacheStats': getCacheStats(),
      };
    } catch (e) {
      print('Failed to get storage info: $e');
      return {};
    }
  }
  
  Future<int> _calculateDirectorySize(Directory directory) async {
    try {
      int totalSize = 0;
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Failed to calculate directory size: $e');
      return 0;
    }
  }
  
  Future<int> _getFreeSpace() async {
    try {
      final appDir = _appDirectory!;
      return await appDir.parent.availableSpace();
    } catch (e) {
      print('Failed to get free space: $e');
      return 0;
    }
  }
  
  // Cleanup Operations
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = _tempDirectory!;
      
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            print('Failed to delete temp file: $e');
          }
        }
        
        print('Temp files cleaned up');
      }
    } catch (e) {
      print('Failed to cleanup temp files: $e');
    }
  }
  
  Future<void> cleanupOldBackups({int maxBackups = 5}) async {
    try {
      final backups = await listBackups();
      
      if (backups.length > maxBackups) {
        // Sort by date (newest first)
        backups.sort((a, b) => b.compareTo(a));
        
        final oldBackups = backups.sublist(maxBackups);
        
        for (final backup in oldBackups) {
          await deleteBackup(backup);
        }
        
        print('Cleaned up ${oldBackups.length} old backups');
      }
    } catch (e) {
      print('Failed to cleanup old backups: $e');
    }
  }
  
  Future<void> optimizeStorage() async {
    try {
      // Clear expired cache
      _cleanExpiredCache();
      
      // Cleanup temp files
      await cleanupTempFiles();
      
      // Cleanup old backups
      await cleanupOldBackups();
      
      // Trim logs
      final logFile = await _getLogFile();
      await _trimLogFile(logFile);
      
      print('Storage optimization completed');
    } catch (e) {
      print('Failed to optimize storage: $e');
    }
  }
  
  // Secure Storage Operations
  Future<void> writeSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      print('Failed to write secure data: $e');
    }
  }
  
  Future<String?> readSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Failed to read secure data: $e');
      return null;
    }
  }
  
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('Failed to delete secure data: $e');
    }
  }
  
  Future<void> clearSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Failed to clear secure data: $e');
    }
  }
  
  // Dispose
  Future<void> dispose() async {
    try {
      await clearCache();
      
      for (final timer in _cacheTimers.values) {
        timer?.cancel();
      }
      _cacheTimers.clear();
      
      print('Storage service disposed');
    } catch (e) {
      print('Failed to dispose storage service: $e');
    }
  }
}
