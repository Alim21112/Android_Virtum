import 'package:mobile/models/health_metrics.dart';
import 'package:mobile/models/health_metrics_record.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static const _dbName = 'virtum.db';
  static const _dbVersion = 1;

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE auth_session(
            token TEXT PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE metrics(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            heartRate INTEGER,
            bloodPressure TEXT,
            steps INTEGER,
            waterIntake REAL,
            oxygen INTEGER,
            temperature REAL,
            insight TEXT,
            savedAt INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> saveUser(UserProfile user) async {
    final db = await _open();
    await db.insert(
      'user_profile',
      {'id': user.id, 'name': user.name, 'email': user.email},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserProfile?> getUser() async {
    final db = await _open();
    final rows = await db.query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromJson(rows.first);
  }

  static Future<void> saveToken(String token) async {
    final db = await _open();
    await db.delete('auth_session');
    await db.insert('auth_session', {'token': token});
  }

  static Future<String?> getToken() async {
    final db = await _open();
    final rows = await db.query('auth_session', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['token'] as String?;
  }

  static Future<void> saveMetrics(HealthMetrics metrics) async {
    final db = await _open();
    await db.insert('metrics', {
      'heartRate': metrics.heartRate,
      'bloodPressure': metrics.bloodPressure,
      'steps': metrics.steps,
      'waterIntake': metrics.waterIntakeLiters,
      'oxygen': metrics.oxygen,
      'temperature': metrics.temperature,
      'insight': metrics.insight,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<HealthMetrics?> getLatestMetrics() async {
    final db = await _open();
    final rows = await db.query(
      'metrics',
      orderBy: 'savedAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return HealthMetrics(
      heartRate: row['heartRate'] as int? ?? 0,
      bloodPressure: row['bloodPressure'] as String? ?? '--',
      steps: row['steps'] as int? ?? 0,
      waterIntakeLiters: (row['waterIntake'] as num?)?.toDouble() ?? 0,
      oxygen: row['oxygen'] as int? ?? 0,
      temperature: (row['temperature'] as num?)?.toDouble() ?? 0,
      insight: row['insight'] as String? ?? '',
    );
  }

  static Future<List<HealthMetricsRecord>> getMetricsHistory({
    int limit = 50,
  }) async {
    final db = await _open();
    final rows = await db.query(
      'metrics',
      orderBy: 'savedAt DESC',
      limit: limit,
    );
    return rows.map((row) {
      final metrics = HealthMetrics(
        heartRate: row['heartRate'] as int? ?? 0,
        bloodPressure: row['bloodPressure'] as String? ?? '--',
        steps: row['steps'] as int? ?? 0,
        waterIntakeLiters: (row['waterIntake'] as num?)?.toDouble() ?? 0,
        oxygen: row['oxygen'] as int? ?? 0,
        temperature: (row['temperature'] as num?)?.toDouble() ?? 0,
        insight: row['insight'] as String? ?? '',
      );
      final savedAt = DateTime.fromMillisecondsSinceEpoch(
        row['savedAt'] as int? ?? 0,
      );
      return HealthMetricsRecord(metrics: metrics, savedAt: savedAt);
    }).toList();
  }

  static Future<void> clearMetrics() async {
    final db = await _open();
    await db.delete('metrics');
  }

  static Future<void> clearAll() async {
    final db = await _open();
    await db.delete('metrics');
    await db.delete('auth_session');
    await db.delete('user_profile');
  }
}
