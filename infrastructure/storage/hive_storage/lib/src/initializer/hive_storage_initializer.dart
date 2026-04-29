import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Initialises the Hive CE runtime for Flutter applications.
///
/// Call [init] once during app startup before opening any boxes:
/// ```dart
/// await HiveStorageInitializer.init();
/// ```
///
/// In pure-Dart tests, bypass Flutter path-provider by calling
/// `Hive.init(Directory.current.path)` directly instead.
final class HiveStorageInitializer {
  const HiveStorageInitializer._();

  /// Initialises Hive with the app's documents directory.
  ///
  /// Idempotent — safe to call multiple times.
  static Future<void> init() => Hive.initFlutter();
}
