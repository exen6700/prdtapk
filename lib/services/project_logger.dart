import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ProjectLogger {
  static final ProjectLogger _instance = ProjectLogger._internal();
  factory ProjectLogger() => _instance;
  ProjectLogger._internal();

  static const String logFileName = 'prdtapk_development_log.json';
  static const String projectName = 'PRDT APK Mobile Application';
  static const String version = '1.0.0';

  // Log entry types
  static const String typeFeature = 'feature';
  static const String typeBugfix = 'bugfix';
  static const String typeUpdate = 'update';
  static const String typeTest = 'test';
  static const String typeDeploy = 'deploy';
  static const String typeConfig = 'config';

  // Log levels
  static const String levelInfo = 'info';
  static const String levelWarning = 'warning';
  static const String levelError = 'error';
  static const String levelSuccess = 'success';

  // Get log file path
  Future<String> get _logFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$logFileName';
  }

  // Initialize log file with project info
  Future<void> initializeLog() async {
    final logFile = File(await _logFilePath);
    
    if (!await logFile.exists()) {
      final initialLog = {
        'project_info': {
          'name': projectName,
          'version': version,
          'created_at': DateTime.now().toIso8601String(),
          'description': 'PRDT Token Mobile Application - Flutter based mobile app with test network blockchain simulation',
          'features': [
            'Test Network Blockchain',
            'PRDT Token Management',
            'Mining System',
            'Ad Reward System',
            'User Authentication',
            'Email Verification',
            'Dark Theme UI',
            'Social Media Integration'
          ],
          'tech_stack': [
            'Flutter',
            'Dart',
            'Provider State Management',
            'SharedPreferences',
            'HTTP Client',
            'Crypto Package',
            'Supabase (Planned)',
            'Vercel API (Planned)'
          ]
        },
        'development_log': [],
        'statistics': {
          'total_entries': 0,
          'features_added': 0,
          'bugfixes': 0,
          'tests': 0,
          'deployments': 0
        }
      };
      
      await logFile.writeAsString(jsonEncode(initialLog, toEncodable: (obj) => obj));
      await _logEntry('Project initialized', 'Project log system started', typeConfig, levelInfo);
    }
  }

  // Add log entry
  Future<void> _logEntry(String title, String description, String type, String level, {Map<String, dynamic>? details}) async {
    try {
      final logFile = File(await _logFilePath);
      
      if (!await logFile.exists()) {
        await initializeLog();
      }
      
      final logData = jsonDecode(await logFile.readAsString()) as Map<String, dynamic>;
      final developmentLog = logData['development_log'] as List<dynamic>;
      final statistics = logData['statistics'] as Map<String, dynamic>;
      
      final entry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'formatted_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'title': title,
        'description': description,
        'type': type,
        'level': level,
        'details': details ?? {},
        'session_info': {
          'flutter_version': await _getFlutterVersion(),
          'dart_version': await _getDartVersion(),
          'platform': Platform.operatingSystem,
          'platform_version': Platform.operatingSystemVersion,
        }
      };
      
      developmentLog.add(entry);
      
      // Update statistics
      statistics['total_entries'] = (statistics['total_entries'] as int) + 1;
      
      switch (type) {
        case typeFeature:
          statistics['features_added'] = (statistics['features_added'] as int) + 1;
          break;
        case typeBugfix:
          statistics['bugfixes'] = (statistics['bugfixes'] as int) + 1;
          break;
        case typeTest:
          statistics['tests'] = (statistics['tests'] as int) + 1;
          break;
        case typeDeploy:
          statistics['deployments'] = (statistics['deployments'] as int) + 1;
          break;
      }
      
      await logFile.writeAsString(jsonEncode(logData, toEncodable: (obj) => obj));
      
      // Console output for debugging
      final emoji = _getLevelEmoji(level);
      print('$emoji [${entry['formatted_time']}] $title');
      if (description.isNotEmpty) {
        print('   $description');
      }
      
    } catch (e) {
      print('❌ Log entry error: $e');
    }
  }

  // Get Flutter version
  Future<String> _getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      final output = result.stdout.toString();
      final versionMatch = RegExp(r'Flutter (\d+\.\d+\.\d+)').firstMatch(output);
      return versionMatch?.group(1) ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get Dart version
  Future<String> _getDartVersion() async {
    try {
      final result = await Process.run('dart', ['--version']);
      final output = result.stdout.toString();
      final versionMatch = RegExp(r'Dart SDK version: (\d+\.\d+\.\d+)').firstMatch(output);
      return versionMatch?.group(1) ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get level emoji
  String _getLevelEmoji(String level) {
    switch (level) {
      case levelInfo:
        return 'ℹ️';
      case levelWarning:
        return '⚠️';
      case levelError:
        return '❌';
      case levelSuccess:
        return '✅';
      default:
        return '📝';
    }
  }

  // Public logging methods
  Future<void> logFeature(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeFeature, levelSuccess, details: details);
  }

  Future<void> logBugfix(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeBugfix, levelInfo, details: details);
  }

  Future<void> logUpdate(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeUpdate, levelInfo, details: details);
  }

  Future<void> logTest(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeTest, levelInfo, details: details);
  }

  Future<void> logDeploy(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeDeploy, levelSuccess, details: details);
  }

  Future<void> logError(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeUpdate, levelError, details: details);
  }

  Future<void> logWarning(String title, String description, {Map<String, dynamic>? details}) async {
    await _logEntry(title, description, typeUpdate, levelWarning, details: details);
  }

  // Get all log entries
  Future<List<Map<String, dynamic>>> getLogEntries() async {
    try {
      final logFile = File(await _logFilePath);
      if (!await logFile.exists()) {
        await initializeLog();
        return [];
      }
      
      final logData = jsonDecode(await logFile.readAsString()) as Map<String, dynamic>;
      final developmentLog = logData['development_log'] as List<dynamic>;
      
      return developmentLog.map((entry) => entry as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Get log entries error: $e');
      return [];
    }
  }

  // Get project statistics
  Future<Map<String, dynamic>> getProjectStatistics() async {
    try {
      final logFile = File(await _logFilePath);
      if (!await logFile.exists()) {
        await initializeLog();
        return {};
      }
      
      final logData = jsonDecode(await logFile.readAsString()) as Map<String, dynamic>;
      return logData['statistics'] as Map<String, dynamic>;
    } catch (e) {
      print('❌ Get statistics error: $e');
      return {};
    }
  }

  // Export log to file
  Future<String> exportLog() async {
    try {
      final logFile = File(await _logFilePath);
      if (!await logFile.exists()) {
        await initializeLog();
      }
      
      final exportPath = '${Directory.current.path}/prdtapk_log_export_${DateTime.now().millisecondsSinceEpoch}.json';
      await logFile.copy(exportPath);
      
      return exportPath;
    } catch (e) {
      print('❌ Export log error: $e');
      return '';
    }
  }

  // Clear log (keep project info)
  Future<void> clearLog() async {
    try {
      final logFile = File(await _logFilePath);
      if (await logFile.exists()) {
        final logData = jsonDecode(await logFile.readAsString()) as Map<String, dynamic>;
        logData['development_log'] = [];
        logData['statistics'] = {
          'total_entries': 0,
          'features_added': 0,
          'bugfixes': 0,
          'tests': 0,
          'deployments': 0
        };
        
        await logFile.writeAsString(jsonEncode(logData, toEncodable: (obj) => obj));
        await _logEntry('Log cleared', 'Development log has been cleared', typeConfig, levelInfo);
      }
    } catch (e) {
      print('❌ Clear log error: $e');
    }
  }
} 