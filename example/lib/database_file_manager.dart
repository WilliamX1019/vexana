// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:sqflite/sqflite.dart';
import 'package:vexana/vexana.dart';

class DatabaseFileManager implements IFileManager {
  late Database _database;

  Future<void> init() async {
    _database = await openDatabase(
      '${await getDatabasesPath()}/cache.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE Cache (key TEXT PRIMARY KEY, value TEXT, expiry INTEGER)',
        );
      },
    );
  }

  @override
  Future<String?> getUserRequestDataOnString(String key) async {
    final result = await _database.query(
      'Cache',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      final expiry = result.first['expiry']! as int;
      if (DateTime.now().millisecondsSinceEpoch < expiry) {
        return result.first['value']! as String;
      } else {
        await removeUserRequestCache(key);
      }
    }
    return null;
  }

  @override
  Future<bool> writeUserRequestDataWithTime(String key, String value, Duration? expiration) async {
    if (expiration == null) {
      return false;
    }
    final expiry = DateTime.now().add(expiration).millisecondsSinceEpoch;
    final result = await _database.insert(
      'Cache',
      {'key': key, 'value': value, 'expiry': expiry},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result > 0;
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    final count = await _database.delete(
      'Cache',
      where: 'key = ?',
      whereArgs: [key],
    );
    return count > 0;
  }
  @override
  Future<bool> removeUserRequestCache(String key) async {
    final count = await _database.delete(
      'Cache',
      where: 'key = ?',
      whereArgs: [key],
    );
    return count > 0;
  }
}
