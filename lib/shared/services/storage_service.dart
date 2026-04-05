import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();
  
  late Directory _appDirectory;
  late Directory _documentsDirectory;
  late Directory _tempDirectory;
  
  Future<void> initialize() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    _documentsDirectory = await getApplicationDocumentsDirectory();
    _tempDirectory = await getTemporaryDirectory();
    
    // Create necessary directories
    await _createDirectories();
  }
  
  Future<void> _createDirectories() async {
    final directories = [
      '${_appDirectory.path}/images',
      '${_appDirectory.path}/documents',
      '${_appDirectory.path}/cache',
      '${_appDirectory.path}/logs',
      '${_appDirectory.path}/backups',
    ];
    
    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }
  
  // File Operations
  Future<void> writeStringToFile(String fileName, String content, {String? subDirectory}) async {
    final file = await _getFile(fileName, subDirectory: subDirectory);
    await file.writeAsString(content);
  }
  
  Future<String> readStringFromFile(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      // Handle error
    }
    return '';
  }
  
  Future<void> writeJsonToFile(String fileName, Map<String, dynamic> data, {String? subDirectory}) async {
    final jsonString = jsonEncode(data);
    await writeStringToFile(fileName, jsonString, subDirectory: subDirectory);
  }
  
  Future<Map<String, dynamic>> readJsonFromFile(String fileName, {String? subDirectory}) async {
    try {
      final jsonString = await readStringFromFile(fileName, subDirectory: subDirectory);
      if (jsonString.isNotEmpty) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle error
    }
    return {};
  }
  
  Future<void> writeBytesToFile(String fileName, List<int> bytes, {String? subDirectory}) async {
    final file = await _getFile(fileName, subDirectory: subDirectory);
    await file.writeAsBytes(bytes);
  }
  
  Future<List<int>> readBytesFromFile(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }
  
  Future<bool> fileExists(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  Future<void> deleteFile(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> deleteFilesInDirectory(String subDirectory) async {
    try {
      final directory = Directory('${_appDirectory.path}/$subDirectory');
      if (await directory.exists()) {
        await for (final file in directory.list()) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<List<String>> listFilesInDirectory(String subDirectory) async {
    try {
      final directory = Directory('${_appDirectory.path}/$subDirectory');
      if (await directory.exists()) {
        final files = <String>[];
        await for (final file in directory.list()) {
          if (file is File) {
            files.add(file.path.split('/').last);
          }
        }
        return files;
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }
  
  Future<int> getFileSize(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // Handle error
    }
    return 0;
  }
  
  Future<DateTime?> getFileModifiedDate(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.modified;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
  
  // Cache Operations
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'expiry': expiry?.inMilliseconds ?? AppConstants.cacheExpiry.inMilliseconds,
    };
    await writeJsonToFile('cache_$key.json', cacheData, subDirectory: 'cache');
  }
  
  Future<T?> getCachedData<T>(String key) async {
    try {
      final cacheData = await readJsonFromFile('cache_$key.json', subDirectory: 'cache');
      if (cacheData.isNotEmpty) {
        final timestamp = DateTime.parse(cacheData['timestamp']);
        final expiry = cacheData['expiry'] as int;
        
        if (DateTime.now().difference(timestamp).inMilliseconds < expiry) {
          return cacheData['data'] as T?;
        } else {
          // Cache expired, delete it
          await deleteFile('cache_$key.json', subDirectory: 'cache');
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
  
  Future<void> clearCache() async {
    await deleteFilesInDirectory('cache');
  }
  
  Future<void> clearExpiredCache() async {
    try {
      final directory = Directory('${_appDirectory.path}/cache');
      if (await directory.exists()) {
        await for (final file in directory.list()) {
          if (file is File && file.path.endsWith('.json')) {
            final cacheData = await readJsonFromFile(file.path.split('/').last, subDirectory: 'cache');
            if (cacheData.isNotEmpty) {
              final timestamp = DateTime.parse(cacheData['timestamp']);
              final expiry = cacheData['expiry'] as int;
              
              if (DateTime.now().difference(timestamp).inMilliseconds >= expiry) {
                await file.delete();
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }
  
  // Backup Operations
  Future<void> createBackup(String backupName, Map<String, dynamic> data) async {
    final backupData = {
      'backupName': backupName,
      'timestamp': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
      'data': data,
    };
    final fileName = 'backup_${backupName}_${DateTime.now().millisecondsSinceEpoch}.json';
    await writeJsonToFile(fileName, backupData, subDirectory: 'backups');
  }
  
  Future<Map<String, dynamic>?> restoreBackup(String fileName) async {
    try {
      final backupData = await readJsonFromFile(fileName, subDirectory: 'backups');
      if (backupData.isNotEmpty) {
        return backupData['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
  
  Future<List<String>> listBackups() async {
    final files = await listFilesInDirectory('backups');
    return files.where((file) => file.startsWith('backup_') && file.endsWith('.json')).toList();
  }
  
  Future<void> deleteBackup(String fileName) async {
    await deleteFile(fileName, subDirectory: 'backups');
  }
  
  Future<void> cleanOldBackups() async {
    try {
      final backups = await listBackups();
      final now = DateTime.now();
      
      for (final backup in backups) {
        final file = await _getFile(backup, subDirectory: 'backups');
        final modifiedDate = await file.stat();
        
        if (now.difference(modifiedDate.modified).inDays > AppConstants.backupRetention.inDays) {
          await file.delete();
        }
      }
    } catch (e) {
      // Handle error
    }
  }
  
  // Log Operations
  Future<void> writeLog(String logLevel, String message, {String? error}) async {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': logLevel,
      'message': message,
      'error': error,
    };
    
    final fileName = 'app_log_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}.json';
    await writeJsonToFile(fileName, logEntry, subDirectory: 'logs');
  }
  
  Future<List<Map<String, dynamic>>> readLogs(DateTime date) async {
    final fileName = 'app_log_${date.year}_${date.month}_${date.day}.json';
    final logs = await readJsonFromFile(fileName, subDirectory: 'logs');
    
    if (logs.isNotEmpty) {
      return logs['logs'] as List<Map<String, dynamic>> ?? [];
    }
    return [];
  }
  
  Future<void> cleanOldLogs() async {
    try {
      final directory = Directory('${_appDirectory.path}/logs');
      if (await directory.exists()) {
        await for (final file in directory.list()) {
          if (file is File && file.path.endsWith('.json')) {
            final modifiedDate = await file.stat();
            
            if (DateTime.now().difference(modifiedDate.modified).inDays > AppConstants.logRetention.inDays) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }
  
  // Image Operations
  Future<String> saveImage(String fileName, List<int> imageBytes, {String? subDirectory}) async {
    final directory = subDirectory ?? 'images';
    await writeBytesToFile(fileName, imageBytes, subDirectory: directory);
    return '${_appDirectory.path}/$directory/$fileName';
  }
  
  Future<List<int>> loadImage(String fileName, {String? subDirectory}) async {
    final directory = subDirectory ?? 'images';
    return await readBytesFromFile(fileName, subDirectory: directory);
  }
  
  Future<String> saveImageFromUrl(String url, String fileName) async {
    try {
      // In a real implementation, you would download the image from URL
      // For now, this is a placeholder
      final imageBytes = []; // Download image bytes from URL
      return await saveImage(fileName, imageBytes);
    } catch (e) {
      // Handle error
      return '';
    }
  }
  
  // Utility Methods
  Future<File> _getFile(String fileName, {String? subDirectory}) async {
    final directory = subDirectory != null 
        ? Directory('${_appDirectory.path}/$subDirectory')
        : _appDirectory;
    
    return File('${directory.path}/$fileName');
  }
  
  Future<String> getApplicationPath() async {
    return _appDirectory.path;
  }
  
  Future<int> getTotalStorageSize() async {
    try {
      int totalSize = 0;
      await for (final file in _appDirectory.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      final cacheDirectory = Directory('${_appDirectory.path}/cache');
      if (await cacheDirectory.exists()) {
        await for (final file in cacheDirectory.list(recursive: true)) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  Future<void> clearAllData() async {
    try {
      await for (final file in _appDirectory.list(recursive: true)) {
        if (file is File) {
          await file.delete();
        }
      }
      await _createDirectories();
    } catch (e) {
      // Handle error
    }
  }
  
  Future<bool> exportData(String exportPath, Map<String, dynamic> data) async {
    try {
      final exportFile = File(exportPath);
      await exportFile.writeAsString(jsonEncode(data));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> importData(String importPath) async {
    try {
      final importFile = File(importPath);
      if (await importFile.exists()) {
        final content = await importFile.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
  
  Future<void> compressOldFiles() async {
    try {
      final directories = ['cache', 'logs', 'backups'];
      
      for (final dirName in directories) {
        final directory = Directory('${_appDirectory.path}/$dirName');
        if (await directory.exists()) {
          await for (final file in directory.list()) {
            if (file is File) {
              final modifiedDate = await file.stat();
              final age = DateTime.now().difference(modifiedDate.modified);
              
              // Compress files older than 30 days
              if (age.inDays > 30) {
                // In a real implementation, you would compress the file
                // For now, this is a placeholder
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<Map<String, dynamic>> getStorageInfo() async {
    final totalSize = await getTotalStorageSize();
    final cacheSize = await getCacheSize();
    final freeSpace = await _getFreeSpace();
    
    return {
      'totalSize': totalSize,
      'cacheSize': cacheSize,
      'freeSpace': freeSpace,
      'usedSpace': totalSize - cacheSize,
      'appDirectory': _appDirectory.path,
      'documentsDirectory': _documentsDirectory.path,
      'tempDirectory': _tempDirectory.path,
    };
  }
  
  Future<int> _getFreeSpace() async {
    try {
      final directory = _appDirectory.parent;
      // In a real implementation, you would get free space from the directory
      // For now, return a placeholder value
      return 1024 * 1024 * 1024; // 1GB placeholder
    } catch (e) {
      return 0;
    }
  }
  
  Future<void> optimizeStorage() async {
    // Clean expired cache
    await clearExpiredCache();
    
    // Clean old logs
    await cleanOldLogs();
    
    // Clean old backups
    await cleanOldBackups();
    
    // Compress old files
    await compressOldFiles();
  }
  
  Future<bool> isValidFile(String fileName, {List<String>? allowedExtensions}) async {
    final extension = fileName.split('.').last.toLowerCase();
    final extensions = allowedExtensions ?? AppConstants.allowedMimeTypes;
    
    return extensions.any((ext) => ext.contains(extension));
  }
  
  Future<String> generateUniqueFileName(String fileName) async {
    final nameWithoutExtension = fileName.contains('.') 
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final extension = fileName.contains('.') 
        ? fileName.substring(fileName.lastIndexOf('.'))
        : '';
    
    var counter = 1;
    var uniqueFileName = fileName;
    
    while (await fileExists(uniqueFileName)) {
      uniqueFileName = '${nameWithoutExtension}_$counter$extension';
      counter++;
    }
    
    return uniqueFileName;
  }
  
  Future<void> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);
      
      if (await sourceFile.exists()) {
        await sourceFile.rename(destinationPath);
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);
      
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<bool> isFileAccessible(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        await file.openRead().first;
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
  
  Future<void> setFilePermissions(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        // In a real implementation, you would set file permissions
        // For now, this is a placeholder
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<Map<String, dynamic>> getFileMetadata(String fileName, {String? subDirectory}) async {
    try {
      final file = await _getFile(fileName, subDirectory: subDirectory);
      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'fileName': fileName,
          'path': file.path,
          'size': stat.size,
          'modified': stat.modified.toIso8601String(),
          'accessed': stat.accessed.toIso8601String(),
          'type': stat.type.name,
          'isReadable': await isFileAccessible(fileName, subDirectory: subDirectory),
        };
      }
    } catch (e) {
      // Handle error
    }
    return {};
  }
}
