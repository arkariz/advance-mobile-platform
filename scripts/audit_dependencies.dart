#!/usr/bin/env dart
// scripts/audit_dependencies.dart
//
// Flutter/Dart Dependency Health Auditor — Monorepo Edition
//
// Based on the 5-criteria rubric from:
// "Flutter Package Graveyard 2026: I Audited 47 Dependencies..."
//
// Usage:
//   dart run scripts/audit_dependencies.dart
//   dart run scripts/audit_dependencies.dart --strict   # exit 1 if WARNING present
//   dart run scripts/audit_dependencies.dart --json     # JSON output
//   dart run scripts/audit_dependencies.dart --no-color
//
// Scoring criteria (10 pts total):
//   1. Last Meaningful Update  : 0–3 pts
//   2. SDK Constraint          : 0–3 pts
//   3. Pub Score (proxy maint) : 0–2 pts
//   4. Popularity              : 0–1 pt
//   5. Version Gap             : 0–1 pt
//
// Interpretation:
//   8–10 : HEALTHY  — safe to use
//   5–7  : WATCH    — monitor periodically
//   2–4  : WARNING  — consider migrating
//   0–1  : CRITICAL — replace immediately

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — loaded from scripts/audit_config.yaml
// ─────────────────────────────────────────────────────────────────────────────

const _pubDevApiBase = 'pub.dev';
const _configFileName = 'scripts/audit_config.yaml';

class _AuditConfig {
  final Set<String> skipExact;
  final List<String> skipPrefixes;
  final Map<String, String> deprecated;

  // Criterion 1 — last update thresholds (months)
  final int updateExcellent;
  final int updateGood;
  final int updateAcceptable;

  // Criterion 3 — pub score thresholds (percentage)
  final double pubScoreExcellent;
  final double pubScoreGood;

  // Criterion 4 — download minimum
  final int downloadMin;

  // Status thresholds
  final int scoreHealthy;
  final int scoreWatch;
  final int scoreWarning;

  // Cache
  final bool cacheEnabled;
  final int cacheTtlHours;
  final String cachePath;

  // HTTP
  Duration get httpTimeout => const Duration(seconds: 15);

  const _AuditConfig({
    required this.skipExact,
    required this.skipPrefixes,
    required this.deprecated,
    required this.updateExcellent,
    required this.updateGood,
    required this.updateAcceptable,
    required this.pubScoreExcellent,
    required this.pubScoreGood,
    required this.downloadMin,
    required this.scoreHealthy,
    required this.scoreWatch,
    required this.scoreWarning,
    required this.cacheEnabled,
    required this.cacheTtlHours,
    required this.cachePath,
  });

  /// Default values identical to the original script behaviour.
  factory _AuditConfig.defaults() => const _AuditConfig(
        skipExact: {'sky_engine', 'flutter_web_plugins', 'flutter_test', 'flutter_driver'},
        skipPrefixes: ['flutter', 'dart'],
        deprecated: {},
        updateExcellent: 3,
        updateGood: 6,
        updateAcceptable: 12,
        pubScoreExcellent: 90,
        pubScoreGood: 70,
        downloadMin: 10000,
        scoreHealthy: 8,
        scoreWatch: 5,
        scoreWarning: 2,
        cacheEnabled: true,
        cacheTtlHours: 24,
        cachePath: '.dart_tool/audit_cache.json',
      );

  /// Load from YAML file. Falls back to defaults if the file does not exist.
  factory _AuditConfig.load(String workspaceRoot) {
    final file = File('$workspaceRoot/$_configFileName');
    if (!file.existsSync()) return _AuditConfig.defaults();
    try {
      return _AuditConfig._parse(file.readAsStringSync());
    } catch (_) {
      return _AuditConfig.defaults();
    }
  }

  /// Minimal YAML parser — supports only the audit_config.yaml schema.
  /// No external package dependency.
  factory _AuditConfig._parse(String yaml) {
    final skipExact = <String>{};
    final skipPrefixes = <String>[];
    final deprecated = <String, String>{};
    final thresholds = <String, num>{};
    final cache = <String, dynamic>{};

    String? section;
    String? subsection;

    for (var rawLine in yaml.split('\n')) {
      // Strip inline comments (outside of strings)
      final ci = rawLine.indexOf(' #');
      if (ci > 0) rawLine = rawLine.substring(0, ci);
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      // Top-level section (no indent, ends with ':')
      if (!rawLine.startsWith(' ') && trimmed.endsWith(':')) {
        section = trimmed.substring(0, trimmed.length - 1);
        subsection = null;
        continue;
      }

      // Sub-section (2-space indent, ends with ':')
      if (rawLine.startsWith('  ') && !rawLine.startsWith('    ') &&
          trimmed.endsWith(':')) {
        subsection = trimmed.substring(0, trimmed.length - 1);
        continue;
      }

      // List item '  - value' or '    - value'
      if (trimmed.startsWith('- ')) {
        final value = trimmed.substring(2).trim();
        if (section == 'skip') {
          if (subsection == 'exact') skipExact.add(value);
          if (subsection == 'prefix') skipPrefixes.add(value);
        }
        continue;
      }

      // Key: value
      final ci2 = trimmed.indexOf(':');
      if (ci2 <= 0) continue;
      final key = trimmed.substring(0, ci2).trim();
      var value = trimmed.substring(ci2 + 1).trim();
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      if (value.startsWith("'") && value.endsWith("'")) {
        value = value.substring(1, value.length - 1);
      }

      switch (section) {
        case 'thresholds':
          final n = num.tryParse(value);
          if (n != null) thresholds[key] = n;
        case 'cache':
          if (value == 'true') cache[key] = true;
          else if (value == 'false') cache[key] = false;
          else cache[key] = num.tryParse(value) ?? value;
        case 'deprecated':
          if (value.isNotEmpty) deprecated[key] = value;
      }
    }

    final def = _AuditConfig.defaults();
    return _AuditConfig(
      skipExact: skipExact.isEmpty ? def.skipExact : skipExact,
      skipPrefixes: skipPrefixes.isEmpty ? def.skipPrefixes : skipPrefixes,
      deprecated: deprecated,
      updateExcellent: (thresholds['update_excellent'] ?? def.updateExcellent).toInt(),
      updateGood: (thresholds['update_good'] ?? def.updateGood).toInt(),
      updateAcceptable: (thresholds['update_acceptable'] ?? def.updateAcceptable).toInt(),
      pubScoreExcellent: (thresholds['pub_score_excellent'] ?? def.pubScoreExcellent).toDouble(),
      pubScoreGood: (thresholds['pub_score_good'] ?? def.pubScoreGood).toDouble(),
      downloadMin: (thresholds['download_min'] ?? def.downloadMin).toInt(),
      scoreHealthy: (thresholds['score_healthy'] ?? def.scoreHealthy).toInt(),
      scoreWatch: (thresholds['score_watch'] ?? def.scoreWatch).toInt(),
      scoreWarning: (thresholds['score_warning'] ?? def.scoreWarning).toInt(),
      cacheEnabled: (cache['enabled'] as bool?) ?? def.cacheEnabled,
      cacheTtlHours: (cache['ttl_hours'] as num?)?.toInt() ?? def.cacheTtlHours,
      cachePath: (cache['path'] as String?) ?? def.cachePath,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANSI COLORS
// ─────────────────────────────────────────────────────────────────────────────

bool _useColor = true;

String _red(String s) => _useColor ? '\x1B[31m$s\x1B[0m' : s;
String _yellow(String s) => _useColor ? '\x1B[33m$s\x1B[0m' : s;
String _green(String s) => _useColor ? '\x1B[32m$s\x1B[0m' : s;
String _cyan(String s) => _useColor ? '\x1B[36m$s\x1B[0m' : s;
String _bold(String s) => _useColor ? '\x1B[1m$s\x1B[0m' : s;
String _dim(String s) => _useColor ? '\x1B[2m$s\x1B[0m' : s;

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class PackageInfo {
  final String name;
  final String? currentVersion;
  final String? latestVersion;
  final DateTime? lastPublished;
  final String? sdkConstraint;
  final int? pubPoints;
  final int? maxPubPoints;
  final int? downloadCount30Days;
  final int? likeCount;
  final String? publisher;
  final bool isDiscontinued;
  final String? upgradableVersion;
  final bool isDeprecated;
  final String? deprecationNote;
  final String? resolvedFrom; // name of the pubspec that declares this package
  final bool isDirect;

  PackageInfo({
    required this.name,
    this.currentVersion,
    this.latestVersion,
    this.lastPublished,
    this.sdkConstraint,
    this.pubPoints,
    this.maxPubPoints,
    this.downloadCount30Days,
    this.likeCount,
    this.publisher,
    this.isDiscontinued = false,
    this.upgradableVersion,
    this.isDeprecated = false,
    this.deprecationNote,
    this.resolvedFrom,
    this.isDirect = false,
  });
}

class AuditResult {
  final PackageInfo info;
  final int score;
  final String status;
  final String statusLabel;
  final Map<String, int> scoreBreakdown;
  final List<String> issues;
  final List<String> notes;

  AuditResult({
    required this.info,
    required this.score,
    required this.status,
    required this.statusLabel,
    required this.scoreBreakdown,
    required this.issues,
    required this.notes,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// YAML MINI-PARSER (dependencies block only)
// ─────────────────────────────────────────────────────────────────────────────

/// Extracts direct dependencies from pubspec.yaml content.
/// Ignores git-based and path-based deps.
Map<String, String?> parseDependencies(String content) {
  final result = <String, String?>{};
  final sections = [
    'dependencies',
    'dev_dependencies',
  ];

  for (final section in sections) {
    final sectionRegex = RegExp('^$section:\\s*\$', multiLine: true);
    final match = sectionRegex.firstMatch(content);
    if (match == null) continue;

    final start = match.end;
    // Find section end (unindented line or new section)
    final afterSection = content.substring(start);
    final lines = afterSection.split('\n');

    for (final line in lines) {
      // Empty line or comment — skip
      if (line.trim().isEmpty || line.trim().startsWith('#')) continue;
      // Unindented line → new section, stop
      if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
        break;
      }

      // Match "  package_name: ^1.2.3" or "  package_name: any"
      final pkgLine =
          RegExp(r'^\s{2}([a-z][a-z0-9_]*)\s*:\s*(\^?[\d]+[\d.]*\S*|any|\s*)$');
      final pkgMatch = pkgLine.firstMatch(line);
      if (pkgMatch != null) {
        final name = pkgMatch.group(1)!;
        final version = pkgMatch.group(2)?.trim();
        result[name] = version?.isEmpty == true ? null : version;
      }
    }
  }

  return result;
}

/// Reads all packages from pubspec.lock (resolved versions).
Map<String, Map<String, dynamic>> parseLockFile(String content) {
  final result = <String, Map<String, dynamic>>{};
  final lines = content.split('\n');

  String? currentPkg;
  var inPackages = false;
  final currentData = <String, dynamic>{};

  for (final line in lines) {
    if (line == 'packages:') {
      inPackages = true;
      continue;
    }
    if (!inPackages) continue;

    // Package name (2-space indent)
    final pkgNameMatch = RegExp(r'^  ([a-z][a-z0-9_]*):').firstMatch(line);
    if (pkgNameMatch != null && !line.startsWith('    ')) {
      if (currentPkg != null) {
        result[currentPkg] = Map.from(currentData);
        currentData.clear();
      }
      currentPkg = pkgNameMatch.group(1);
      continue;
    }

    if (currentPkg == null) continue;

    // version
    final versionMatch = RegExp(r'^\s+version:\s+"?([^"\s]+)"?').firstMatch(line);
    if (versionMatch != null) {
      currentData['version'] = versionMatch.group(1);
    }

    // dependency type
    final depMatch = RegExp(r'^\s+dependency:\s+(\S+)').firstMatch(line);
    if (depMatch != null) {
      currentData['dependency'] = depMatch.group(1);
    }

    // source
    final srcMatch = RegExp(r'^\s+source:\s+(\S+)').firstMatch(line);
    if (srcMatch != null) {
      currentData['source'] = srcMatch.group(1);
    }
  }

  if (currentPkg != null) {
    result[currentPkg] = Map.from(currentData);
  }

  return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// CACHE — stores pub.dev responses so subsequent runs skip network requests
// ─────────────────────────────────────────────────────────────────────────────

class _Cache {
  final String _path;
  final Duration _ttl;
  Map<String, dynamic> _data = {};

  _Cache(String path, int ttlHours)
      : _path = path,
        _ttl = Duration(hours: ttlHours) {
    _load();
  }

  void _load() {
    final file = File(_path);
    if (!file.existsSync()) return;
    try {
      _data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      _data = {};
    }
  }

  Future<void> save() async {
    final file = File(_path);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(_data));
  }

  /// Returns cached data if present and not yet stale.
  Map<String, dynamic>? get(String key) {
    final entry = _data[key] as Map<String, dynamic>?;
    if (entry == null) return null;
    final ts = entry['_ts'] as String?;
    if (ts == null) return null;
    if (DateTime.now().difference(DateTime.parse(ts)) > _ttl) return null;
    return entry;
  }

  void set(String key, Map<String, dynamic> value) {
    _data[key] = {...value, '_ts': DateTime.now().toIso8601String()};
  }

  bool get isEmpty => _data.isEmpty;
  int get size => _data.length;

  /// Removes stale entries. Called before save to keep the cache file compact.
  void evictStale() {
    _data.removeWhere((_, v) {
      if (v is! Map) return true;
      final ts = v['_ts'] as String?;
      if (ts == null) return true;
      return DateTime.now().difference(DateTime.parse(ts)) > _ttl;
    });
  }
}

// Singleton cache — initialised in main() after config is loaded.
_Cache? _cache;

// ─────────────────────────────────────────────────────────────────────────────
// PUB.DEV API
// ─────────────────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>?> _fetchJson(String path, _AuditConfig cfg) async {
  // Retry with exponential backoff: 0 s, 2 s, 4 s
  for (var attempt = 0; attempt < 3; attempt++) {
    if (attempt > 0) {
      await Future<void>.delayed(Duration(seconds: attempt * 2));
    }
    final client = HttpClient();
    client.connectionTimeout = cfg.httpTimeout;
    try {
      final request = await client.getUrl(Uri.https(_pubDevApiBase, path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      if (response.statusCode == 404) return null; // not on pub.dev — do not retry
      if (response.statusCode == 429) continue;     // rate-limited — retry
      if (response.statusCode != 200) continue;
      final body = await response.transform(utf8.decoder).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } on SocketException {
      continue;
    } on HttpException {
      continue;
    } on FormatException {
      return null;
    } finally {
      client.close();
    }
  }
  return null;
}

Future<PackageInfo?> fetchPackageInfo(
  String name,
  _AuditConfig cfg, {
  String? currentVersion,
  String? upgradableVersion,
  bool isDirect = false,
}) async {
  final isDeprecated = cfg.deprecated.containsKey(name);

  // ── Cache lookup
  Map<String, dynamic>? cachedMeta;
  Map<String, dynamic>? cachedScore;
  final cacheKey = 'pkg:$name';

  if (_cache != null) {
    final entry = _cache!.get(cacheKey);
    if (entry != null) {
      cachedMeta = entry['meta'] as Map<String, dynamic>?;
      cachedScore = entry['score'] as Map<String, dynamic>?;
    }
  }

  // ── Fetch from pub.dev on cache miss
  final meta = cachedMeta ?? await _fetchJson('/api/packages/$name', cfg);
  final score = cachedScore ?? await _fetchJson('/api/packages/$name/score', cfg);

  // Store in cache after a successful fetch
  if (_cache != null && meta != null && score != null && cachedMeta == null) {
    _cache!.set(cacheKey, {'meta': meta, 'score': score});
  }

  if (meta == null) {
    // Package not found on pub.dev (likely git-based or private)
    return PackageInfo(
      name: name,
      currentVersion: currentVersion,
      isDeprecated: isDeprecated,
      deprecationNote: cfg.deprecated[name],
      isDirect: isDirect,
    );
  }

  final latest = meta['latest'] as Map<String, dynamic>?;
  final latestVersion = latest?['version'] as String?;
  final publishedStr = latest?['published'] as String?;
  final lastPublished =
      publishedStr != null ? DateTime.tryParse(publishedStr) : null;

  // SDK constraint from the latest pubspec
  final pubspec = latest?['pubspec'] as Map<String, dynamic>?;
  final env = pubspec?['environment'] as Map<String, dynamic>?;
  final sdkConstraint = env?['sdk'] as String?;

  // Pub score
  final pubPoints = score?['grantedPoints'] as int?;
  final maxPubPoints = score?['maxPoints'] as int?;
  final downloadCount30Days = score?['downloadCount30Days'] as int?;
  final likeCount = score?['likeCount'] as int?;
  final tags = (score?['tags'] as List<dynamic>?)?.cast<String>() ?? [];
  final isDiscontinued = tags.contains('is:discontinued');
  final publisher = tags
      .where((t) => t.startsWith('publisher:'))
      .map((t) => t.replaceFirst('publisher:', ''))
      .firstOrNull;

  return PackageInfo(
    name: name,
    currentVersion: currentVersion,
    latestVersion: latestVersion,
    lastPublished: lastPublished,
    sdkConstraint: sdkConstraint,
    pubPoints: pubPoints,
    maxPubPoints: maxPubPoints,
    downloadCount30Days: downloadCount30Days,
    likeCount: likeCount,
    publisher: publisher,
    isDiscontinued: isDiscontinued,
    upgradableVersion: upgradableVersion,
    isDeprecated: isDeprecated,
    deprecationNote: cfg.deprecated[name],
    isDirect: isDirect,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUTTER PUB OUTDATED
// ─────────────────────────────────────────────────────────────────────────────

/// Runs `flutter pub outdated --json` and returns a map
/// package → {current, upgradable, resolvable, latest}.
Future<Map<String, Map<String, String?>>> runPubOutdated(
    String workDir) async {
  final result = await Process.run(
    'flutter',
    ['pub', 'outdated', '--json', '--no-color'],
    workingDirectory: workDir,
  );

  if (result.exitCode != 0 && result.stdout.toString().isEmpty) {
    return {};
  }

  try {
    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final packages = json['packages'] as List<dynamic>? ?? [];
    final map = <String, Map<String, String?>>{};

    for (final pkg in packages) {
      final name = pkg['package'] as String? ?? '';
      if (name.isEmpty) continue;
      map[name] = {
        'current': pkg['current']?['version'] as String?,
        'upgradable': pkg['upgradable']?['version'] as String?,
        'resolvable': pkg['resolvable']?['version'] as String?,
        'latest': pkg['latest']?['version'] as String?,
      };
    }
    return map;
  } on FormatException {
    return {};
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORING ENGINE
// ─────────────────────────────────────────────────────────────────────────────

AuditResult scorePackage(PackageInfo info, _AuditConfig cfg) {
  final breakdown = <String, int>{};
  final issues = <String>[];
  final notes = <String>[];

  // ── Criterion 1: Last Meaningful Update (0–3)
  int c1 = 0;
  if (info.lastPublished != null) {
    final age = DateTime.now().difference(info.lastPublished!);
    final months = age.inDays / 30;
    if (months <= cfg.updateExcellent) {
      c1 = 3;
    } else if (months <= cfg.updateGood) {
      c1 = 2;
    } else if (months <= cfg.updateAcceptable) {
      c1 = 1;
      notes.add('No update for ${months.toStringAsFixed(0)} months');
    } else {
      c1 = 0;
      issues.add('No update for ${months.toStringAsFixed(0)} months!');
    }
  } else {
    c1 = 0;
    notes.add('Could not retrieve publish date');
  }
  breakdown['last_update'] = c1;

  // ── Criterion 2: SDK Constraint (0–3)
  int c2 = 0;
  if (info.sdkConstraint != null) {
    final constraint = info.sdkConstraint!;
    // Check Dart 3.x support
    final supportsLatest =
        constraint.contains('>=3.') || constraint.contains('^3.');
    final open = constraint.endsWith('<4.0.0') ||
        constraint.endsWith('<4.0') ||
        constraint.contains('any');

    if (supportsLatest && open) {
      c2 = 3;
    } else if (supportsLatest) {
      c2 = 2;
      notes.add('SDK constraint may be too tight: $constraint');
    } else if (constraint.contains('>=2.')) {
      c2 = 1;
      issues.add('SDK constraint only supports Dart 2: $constraint');
    } else {
      c2 = 0;
      issues.add('Problematic SDK constraint: $constraint');
    }
  } else {
    c2 = 1;
    notes.add('Could not retrieve SDK constraint');
  }
  breakdown['sdk_constraint'] = c2;

  // ── Criterion 3: Pub Score as a proxy for maintainer health (0–2)
  int c3 = 0;
  if (info.pubPoints != null && info.maxPubPoints != null) {
    final pct = info.maxPubPoints! > 0
        ? (info.pubPoints! / info.maxPubPoints! * 100)
        : 0.0;
    if (pct >= cfg.pubScoreExcellent) {
      c3 = 2;
    } else if (pct >= cfg.pubScoreGood) {
      c3 = 1;
      notes.add('Pub score: ${info.pubPoints}/${info.maxPubPoints} (${pct.toStringAsFixed(0)}%)');
    } else {
      c3 = 0;
      issues.add('Low pub score: ${info.pubPoints}/${info.maxPubPoints} (${pct.toStringAsFixed(0)}%)');
    }
  } else {
    c3 = 0;
    notes.add('Pub score data unavailable');
  }
  breakdown['pub_score'] = c3;

  // ── Criterion 4: Popularity via download count (0–1)
  int c4 = 0;
  if (info.downloadCount30Days != null) {
    if (info.downloadCount30Days! >= cfg.downloadMin) {
      c4 = 1;
    } else {
      c4 = 0;
      notes.add('Low downloads: ${_formatDownloads(info.downloadCount30Days!)}/mo');
    }
  } else {
    c4 = 1; // benefit of the doubt
  }
  breakdown['popularity'] = c4;

  // ── Check discontinued tag from pub.dev
  if (info.isDiscontinued) {
    issues.insert(0, 'pub.dev has marked this package as DISCONTINUED');
  }

  // ── Criterion 5: Version Gap (0–1)
  int c5 = 1;
  if (info.currentVersion != null && info.latestVersion != null) {
    final curMajor =
        int.tryParse(info.currentVersion!.split('.').first) ?? 0;
    final latMajor =
        int.tryParse(info.latestVersion!.split('.').first) ?? 0;
    final gap = latMajor - curMajor;

    if (gap >= 2) {
      c5 = 0;
      issues.add(
          '$gap major versions behind: ${info.currentVersion} → ${info.latestVersion}');
    } else if (gap == 1) {
      c5 = 1;
      notes.add(
          '1 major version available: ${info.currentVersion} → ${info.latestVersion}');
    } else if (info.upgradableVersion != null &&
        info.upgradableVersion != info.currentVersion) {
      c5 = 1;
      notes.add('Update available: ${info.currentVersion} → ${info.upgradableVersion}');
    }
  }
  breakdown['version_gap'] = c5;

  // ── Known deprecated (manual list) override
  if (info.isDeprecated) {
    issues.insert(0,
        'DEPRECATED/DISCONTINUED: ${info.deprecationNote ?? "No details provided"}');
  }

  final total = breakdown.values.fold(0, (a, b) => a + b);

  String status;
  String statusLabel;
  // Force CRITICAL if discontinued
  if (info.isDiscontinued || info.isDeprecated) {
    status = 'CRITICAL';
    statusLabel = _red('● CRITICAL [$total/10]');
  } else if (total >= cfg.scoreHealthy) {
    status = 'HEALTHY';
    statusLabel = _green('● HEALTHY  [$total/10]');
  } else if (total >= cfg.scoreWatch) {
    status = 'WATCH';
    statusLabel = _cyan('● WATCH    [$total/10]');
  } else if (total >= cfg.scoreWarning) {
    status = 'WARNING';
    statusLabel = _yellow('● WARNING  [$total/10]');
  } else {
    status = 'CRITICAL';
    statusLabel = _red('● CRITICAL [$total/10]');
  }

  return AuditResult(
    info: info,
    score: total,
    status: status,
    statusLabel: statusLabel,
    scoreBreakdown: breakdown,
    issues: issues,
    notes: notes,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REPORT PRINTER
// ─────────────────────────────────────────────────────────────────────────────

void printReport(List<AuditResult> results, {bool jsonOutput = false}) {
  if (jsonOutput) {
    final output = results.map((r) => {
          'package': r.info.name,
          'score': r.score,
          'status': r.status,
          'current_version': r.info.currentVersion,
          'latest_version': r.info.latestVersion,
          'last_published': r.info.lastPublished?.toIso8601String(),
          'pub_points': r.info.pubPoints,
          'max_pub_points': r.info.maxPubPoints,
          'download_count_30d': r.info.downloadCount30Days,
          'like_count': r.info.likeCount,
          'publisher': r.info.publisher,
          'is_discontinued': r.info.isDiscontinued,
          'score_breakdown': r.scoreBreakdown,
          'issues': r.issues,
          'notes': r.notes,
        }).toList();
    print(const JsonEncoder.withIndent('  ').convert(output));
    return;
  }

  final separator = '─' * 72;

  // Header
  print('');
  print(_bold('┌${'─' * 70}┐'));
  print(_bold('│  FLUTTER DEPENDENCY HEALTH AUDIT${' ' * 36}│'));
  print(_bold('│  5-Criteria Rubric — Total Score: 10 pts${' ' * 28}│'));
  print(_bold('└${'─' * 70}┘'));
  print('');

  // Legend
  print(_bold('Criteria:'));
  print('  [1] Last Update   0–3 pts    [2] SDK Constraint  0–3 pts');
  print('  [3] Pub Score     0–2 pts    [4] Popularity      0–1 pt');
  print('  [5] Version Gap   0–1 pt');
  print('');
  print('  ${_green('● HEALTHY')}  8–10   ${_cyan('● WATCH')}  5–7   '
      '${_yellow('● WARNING')}  2–4   ${_red('● CRITICAL')}  0–1');
  print('');
  print(separator);

  // Group by status
  final critical = results.where((r) => r.status == 'CRITICAL').toList();
  final warning = results.where((r) => r.status == 'WARNING').toList();
  final watch = results.where((r) => r.status == 'WATCH').toList();
  final healthy = results.where((r) => r.status == 'HEALTHY').toList();

  void printGroup(String title, List<AuditResult> group) {
    if (group.isEmpty) return;
    print('');
    print(_bold(title));
    print('');

    for (final r in group) {
      final pub = r.info.lastPublished != null
          ? _formatAge(DateTime.now().difference(r.info.lastPublished!))
          : '?';
      final pts = r.info.pubPoints != null
          ? '${r.info.pubPoints}/${r.info.maxPubPoints}'
          : '?/?';
      final dl = r.info.downloadCount30Days != null
          ? '${_formatDownloads(r.info.downloadCount30Days!)}/mo'
          : '?';
      final cur = r.info.currentVersion ?? '?';
      final lat = r.info.latestVersion ?? '?';
      final pub2 = r.info.publisher != null ? '  by:${r.info.publisher}' : '';

      print('  ${r.statusLabel}  ${_bold(r.info.name)}$pub2');
      print(
          '  ${_dim("  current: $cur  latest: $lat  updated: $pub  score: $pts  dl: $dl")}');

      final breakdown = r.scoreBreakdown;
      print(
          '  ${_dim("  [1]${breakdown['last_update']} [2]${breakdown['sdk_constraint']} [3]${breakdown['pub_score']} [4]${breakdown['popularity']} [5]${breakdown['version_gap']}")}');

      for (final issue in r.issues) {
        print('    ${_red("✗ $issue")}');
      }
      for (final note in r.notes) {
        print('    ${_yellow("⚠ $note")}');
      }
      print('');
    }
  }

  printGroup(_red('━━━ CRITICAL (${critical.length}) ━━━'), critical);
  printGroup(_yellow('━━━ WARNING  (${warning.length}) ━━━'), warning);
  printGroup(_cyan('━━━ WATCH    (${watch.length}) ━━━'), watch);
  printGroup(_green('━━━ HEALTHY  (${healthy.length}) ━━━'), healthy);

  // Summary
  print(separator);
  print('');
  print(_bold('SUMMARY'));
  print('  Total audited : ${results.length} packages');
  print('  ${_green("Healthy  : ${healthy.length}")}');
  print('  ${_cyan("Watch    : ${watch.length}")}');
  print('  ${_yellow("Warning  : ${warning.length}")}');
  print('  ${_red("Critical : ${critical.length}")}');
  print('');

  if (critical.isNotEmpty) {
    print(_red(_bold('  ACTION REQUIRED: ${critical.length} critical package(s) must be replaced!')));
  }
  if (warning.isNotEmpty) {
    print(_yellow('  Consider migrating ${warning.length} WARNING package(s).'));
  }
  print('');
}

String _formatDownloads(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
  return '$count';
}

String _formatAge(Duration d) {
  if (d.inDays < 30) return '${d.inDays}d';
  if (d.inDays < 365) return '${(d.inDays / 30).toStringAsFixed(0)}mo';
  return '${(d.inDays / 365).toStringAsFixed(1)}yr';
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main(List<String> args) async {
  final strictMode = args.contains('--strict');
  final jsonMode = args.contains('--json');
  final noColor = args.contains('--no-color');
  final onlyDirect = args.contains('--direct');
  final clearCache = args.contains('--clear-cache');
  final helpMode = args.contains('--help') || args.contains('-h');

  if (noColor) _useColor = false;

  if (helpMode) {
    print('''
Flutter Dependency Health Auditor

Usage:
  dart run scripts/audit_dependencies.dart [options]

Options:
  --strict        Exit code 1 if any WARNING or CRITICAL packages found (default: CRITICAL only)
  --direct        Audit direct dependencies only (not transitive)
  --json          Output in JSON format
  --no-color      Disable terminal colours
  --clear-cache   Clear the pub.dev cache before running
  -h, --help      Show this help

Configuration:
  Edit scripts/audit_config.yaml to change thresholds, skip lists,
  and the deprecated list without touching Dart code.

Score (10 pts total):
  8–10  HEALTHY   — Safe to use
  5–7   WATCH     — Monitor periodically
  2–4   WARNING   — Consider migrating
  0–1   CRITICAL  — Replace immediately
''');
    exit(0);
  }

  // ── 1. Find workspace root + load config
  final workspaceRoot = _findWorkspaceRoot();
  final cfg = _AuditConfig.load(workspaceRoot);

  if (!jsonMode) {
    print(_dim('Workspace: $workspaceRoot'));
    print(_dim('Config: $workspaceRoot/$_configFileName'));
  }

  // ── 2. Initialise cache
  if (cfg.cacheEnabled) {
    final cachePath = '$workspaceRoot/${cfg.cachePath}';
    _cache = _Cache(cachePath, cfg.cacheTtlHours);
    if (clearCache) {
      final cacheFile = File(cachePath);
      if (cacheFile.existsSync()) {
        cacheFile.deleteSync();
        _cache = _Cache(cachePath, cfg.cacheTtlHours);
        if (!jsonMode) print(_dim('Cache cleared.'));
      }
    } else if (!jsonMode && _cache!.size > 0) {
      print(_dim('Cache: ${_cache!.size} entries (TTL ${cfg.cacheTtlHours}h)'));
    }
  }

  // ── 3. Read pubspec.lock to get resolved versions
  final lockFile = File('$workspaceRoot/pubspec.lock');
  Map<String, Map<String, dynamic>> lockData = {};
  if (lockFile.existsSync()) {
    lockData = parseLockFile(lockFile.readAsStringSync());
  }

  // ── 4. Collect all direct dependencies from every pubspec.yaml
  final directDeps = <String>{};
  final pubspecFiles = _findPubspecFiles(workspaceRoot);
  if (!jsonMode) {
    print(_dim('Found ${pubspecFiles.length} pubspec.yaml files'));
  }

  for (final file in pubspecFiles) {
    final content = File(file).readAsStringSync();
    final deps = parseDependencies(content);
    directDeps.addAll(deps.keys);
  }

  // ── 5. Determine packages to audit
  final toAudit = <String, Map<String, dynamic>>{};

  for (final entry in lockData.entries) {
    final name = entry.key;
    final data = entry.value;
    final source = data['source'] as String? ?? '';
    final dependency = data['dependency'] as String? ?? '';

    if (_shouldSkip(name, cfg)) continue;
    if (source != 'hosted') continue;
    if (onlyDirect && !directDeps.contains(name)) continue;

    final effectiveData = Map<String, dynamic>.from(data);
    if (directDeps.contains(name)) {
      effectiveData['dependency'] =
          dependency.isEmpty ? 'direct main' : dependency;
    }

    toAudit[name] = effectiveData;
  }

  if (!jsonMode) {
    print(_dim('Auditing ${toAudit.length} packages from pub.dev...'));
    print(_dim('Please wait, fetching data from the pub.dev API...'));
    print('');
  }

  // ── 6. Run pub outdated for more accurate version info
  if (!jsonMode) print(_dim('Running flutter pub outdated...'));
  final outdatedData = await runPubOutdated(workspaceRoot);

  // ── 7. Fetch & score all packages (concurrent with throttling)
  final results = <AuditResult>[];
  final semaphore = _Semaphore(5); // max 5 concurrent requests

  final futures = toAudit.entries.map((entry) async {
    await semaphore.acquire();
    try {
      final name = entry.key;
      final data = entry.value;
      final isDirect = (data['dependency'] as String? ?? '')
          .startsWith('direct');

      final currentVersion = (data['version'] as String?) ??
          outdatedData[name]?['current'];
      final upgradableVersion = outdatedData[name]?['upgradable'];

      if (!jsonMode) {
        stdout.write('\r${_dim("  Fetching: $name")}${" " * 20}');
      }

      final info = await fetchPackageInfo(
        name,
        cfg,
        currentVersion: currentVersion,
        upgradableVersion: upgradableVersion,
        isDirect: isDirect,
      );

      if (info != null) {
        return scorePackage(info, cfg);
      }
      return null;
    } finally {
      semaphore.release();
    }
  });

  final rawResults = await Future.wait(futures);
  results.addAll(rawResults.whereType<AuditResult>());

  if (!jsonMode) stdout.write('\r${" " * 60}\r');

  // ── 8. Save cache (evict stale entries first)
  if (_cache != null) {
    _cache!.evictStale();
    await _cache!.save();
  }

  // Sort: critical first, then by score ascending
  results.sort((a, b) => a.score.compareTo(b.score));

  // ── 9. Print report
  printReport(results, jsonOutput: jsonMode);

  // ── 10. Exit code
  final hasCritical = results.any((r) => r.status == 'CRITICAL');
  final hasWarning = results.any((r) => r.status == 'WARNING');

  if (hasCritical || (strictMode && hasWarning)) {
    exit(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILITIES
// ─────────────────────────────────────────────────────────────────────────────

bool _shouldSkip(String name, _AuditConfig cfg) {
  if (cfg.skipExact.contains(name)) return true;
  for (final prefix in cfg.skipPrefixes) {
    if (name == prefix) return true;
  }
  if (name.startsWith('_')) return true;
  return false;
}

String _findWorkspaceRoot() {
  // Look for melos.yaml or pubspec.yaml with a workspace: block
  var dir = Directory.current;
  for (var i = 0; i < 5; i++) {
    final melosYaml = File('${dir.path}/melos.yaml');
    final pubspecYaml = File('${dir.path}/pubspec.yaml');
    if (melosYaml.existsSync()) return dir.path;
    if (pubspecYaml.existsSync()) {
      final content = pubspecYaml.readAsStringSync();
      if (content.contains('workspace:') || content.contains('melos:')) {
        return dir.path;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return Directory.current.path;
}

List<String> _findPubspecFiles(String root) {
  final files = <String>[];
  final dir = Directory(root);

  void walk(Directory d, int depth) {
    if (depth > 5) return;
    try {
      for (final entity in d.listSync()) {
        if (entity is File && entity.path.endsWith('pubspec.yaml')) {
          // Skip build/ dan .dart_tool/
          if (!entity.path.contains('/build/') &&
              !entity.path.contains('/.dart_tool/') &&
              !entity.path.contains('/.pub-cache/')) {
            files.add(entity.path);
          }
        } else if (entity is Directory) {
          final name = entity.path.split('/').last;
          if (!name.startsWith('.') && name != 'build') {
            walk(entity, depth + 1);
          }
        }
      }
    } on FileSystemException {
      // skip unreadable directories
    }
  }

  walk(dir, 0);
  return files;
}

/// Simple semaphore to throttle concurrent HTTP requests.
class _Semaphore {
  final int maxCount;
  int _count = 0;
  final _queue = <Completer<void>>[];

  _Semaphore(this.maxCount);

  Future<void> acquire() async {
    if (_count < maxCount) {
      _count++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
    _count++;
  }

  void release() {
    _count--;
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      next.complete();
    }
  }
}
