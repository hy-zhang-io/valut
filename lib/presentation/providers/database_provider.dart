import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/database_service.dart';

/// Provider for the database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Provider for database initialization state
final databaseInitProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  await db.initialize();
});
