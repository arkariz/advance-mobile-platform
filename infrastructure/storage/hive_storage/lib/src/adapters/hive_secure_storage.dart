// PersistenceFailure is a domain type, not an Exception/Error subclass by design.
// ignore_for_file: only_throw_errors

import 'dart:convert';

import 'package:api_storage/api_storage.dart';
import 'package:failures/failures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:hive_storage/src/mappers/hive_failure_mapper.dart';

/// [SecureStorage] adapter backed by an AES-256 encrypted Hive CE [Box].
///
/// The AES key is generated on first launch and persisted in the platform's
/// native secure storage (iOS Keychain / Android Keystore) via
/// [FlutterSecureStorage]. The key is never stored unencrypted on disk.
///
/// Use the async factory to obtain an instance:
/// ```dart
/// final secureStorage = await HiveSecureStorage.initialize();
/// ```
///
/// `clear()` is intentionally absent — see [SecureStorage] for rationale.
final class HiveSecureStorage implements SecureStorage {
  HiveSecureStorage._({required Box<String> box}) : _box = box;

  final Box<String> _box;

  static const _keyStorageKey = 'hive_secure_box_key';

  /// Opens (or creates) an AES-encrypted Hive box.
  ///
  /// If no encryption key exists it is generated via
  /// [Hive.generateSecureKey] and stored in the platform keychain.
  static Future<HiveSecureStorage> initialize({
    String boxName = 'secure_kv',
  }) async {
    await Hive.initFlutter();

    const keyStorage = FlutterSecureStorage();

    final existingKey = await keyStorage.read(key: _keyStorageKey);
    final List<int> keyBytes;

    if (existingKey == null) {
      keyBytes = Hive.generateSecureKey();
      await keyStorage.write(
        key: _keyStorageKey,
        value: base64UrlEncode(keyBytes),
      );
    } else {
      keyBytes = base64Url.decode(existingKey);
    }

    final box = await Hive.openBox<String>(
      boxName,
      encryptionCipher: HiveAesCipher(keyBytes),
    );

    return HiveSecureStorage._(box: box);
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
}
