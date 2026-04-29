// PersistenceFailure is a domain type, not an Exception/Error subclass by design.
// ignore_for_file: only_throw_errors

import 'package:api_storage/api_storage.dart';
import 'package:failures/failures.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:hive_storage/src/mappers/hive_failure_mapper.dart';

/// [KeyValueStorage] adapter backed by a Hive CE [Box].
///
/// Construct via the DI root after opening the box:
/// ```dart
/// final box = await Hive.openBox<String>('app_kv');
/// final storage = HiveKeyValueStorage(box: box);
/// ```
///
/// Every operation translates Hive exceptions into [PersistenceFailure].
final class HiveKeyValueStorage implements KeyValueStorage {
  /// Creates a [HiveKeyValueStorage] wrapping the given Hive [box].
  const HiveKeyValueStorage._({required Box<String> box}) : _box = box;

  final Box<String> _box;

  /// Opens (or creates) a Hive box and returns a corresponding [HiveKeyValueStorage].
  ///
  /// The box is initialized in the app's documents directory by default, but a custom path can be set via [Hive.init].
  static Future<HiveKeyValueStorage> initialize({
    String boxName = 'app_kv',
  }) async {
    await Hive.initFlutter();

    final box = await Hive.openBox<String>(boxName);

    return HiveKeyValueStorage._(box: box);
  }

  @override
  Future<String?> read(String key) async {
    try {
      return _box.get(key);
    } catch (e, st) {
      throw HiveFailureMapper.map(e, st, code: FailureCode.readFailed);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _box.put(key, value);
    } catch (e, st) {
      throw HiveFailureMapper.map(e, st, code: FailureCode.writeFailed);
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _box.delete(key);
    } catch (e, st) {
      throw HiveFailureMapper.map(e, st, code: FailureCode.deleteFailed);
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      return _box.containsKey(key);
    } catch (e, st) {
      throw HiveFailureMapper.map(e, st, code: FailureCode.readFailed);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e, st) {
      throw HiveFailureMapper.map(e, st, code: FailureCode.deleteFailed);
    }
  }
}
