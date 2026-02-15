import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Logger for import operations
class ImportLogger {
  static final ImportLogger _instance = ImportLogger._internal();
  factory ImportLogger() => _instance;
  ImportLogger._internal();

  final List<LogEntry> _logs = [];
  bool _enableConsoleLog = true;
  bool _enableFileLog = true;
  String? _logFilePath;

  /// Initialize logger
  Future<void> initialize() async {
    if (_logFilePath != null) return;
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      final now = DateTime.now();
      final fileName = 'import_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.log';
      _logFilePath = '${logDir.path}/$fileName';
    } catch (e) {
      developer.log('Failed to initialize logger: $e', name: 'ImportLogger');
    }
  }

  /// Log an info message
  void info(String message) {
    _log('INFO', message);
  }

  /// Log a debug message
  void debug(String message) {
    _log('DEBUG', message);
  }

  /// Log a warning message
  void warning(String message) {
    _log('WARN', message);
  }

  /// Log an error message
  void error(String message) {
    _log('ERROR', message);
  }

  /// Log a success message
  void success(String message) {
    _log('SUCCESS', message);
  }

  void _log(String level, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );

    _logs.add(entry);

    // Console log - 使用print()确保在flutter run控制台可见
    if (_enableConsoleLog) {
      print('[Import] [${entry.formattedTime}] [$level] $message');
    }

    // File log
    if (_enableFileLog && _logFilePath != null) {
      _writeToFile(entry);
    }
  }

  Future<void> _writeToFile(LogEntry entry) async {
    try {
      final file = File(_logFilePath!);
      final line = '${entry.toString()}\n';
      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (e) {
      developer.log('Failed to write to log file: $e', name: 'ImportLogger');
    }
  }

  /// Get all logs
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Get logs as string
  String get logsAsString {
    return _logs.map((e) => e.toString()).join('\n');
  }

  /// Clear logs
  void clear() {
    _logs.clear();
  }

  /// Get log file path
  String? get logFilePath => _logFilePath;

  /// Enable/disable console logging
  set enableConsoleLog(bool value) {
    _enableConsoleLog = value;
  }

  /// Enable/disable file logging
  set enableFileLog(bool value) {
    _enableFileLog = value;
  }
}

/// Log entry
class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  @override
  String toString() {
    return '[$formattedTime] [$level] $message';
  }
}

/// Global logger instance
final importLogger = ImportLogger();
