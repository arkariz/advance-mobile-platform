import 'package:app_example/analytics/analytics_service.dart';
import 'package:app_example/di/root_registrar.dart';
import 'package:app_example/features/auth/api/auth_repository.dart';
import 'package:app_example/features/auth/di/auth_scope.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';

final GetIt rootGetIt = GetIt.instance;

final _boot = DiBoot(
  init: (c) => RootRegistrar.init(c, environment: 'prod'),
  warmups: RootRegistrar.warmUp(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[DI] Phase 1 — blocking init...');
  await _boot.run(rootGetIt);
  debugPrint('[DI] Phase 1 complete — all blocking deps ready. Starting app...');

  runApp(App(getIt: rootGetIt));

  // Phase 2: fire-and-forget warmups start here, after the first frame.
  _boot.warmUp(rootGetIt);
}

// ─────────────────────────────────────────────────────────────────────────────
// App widget — receives the fully initialised root container.
// ─────────────────────────────────────────────────────────────────────────────
class App extends StatelessWidget {
  const App({required this.getIt, super.key});

  final GetIt getIt;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DI Architecture Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: DemoScreen(getIt: getIt),
    );
  }
}

/// Interactive demo screen.
///
/// Shows the dual-container lifecycle:
/// - [AuthScope]: session-tied (created on sign-in, disposed on sign-out).
class DemoScreen extends StatefulWidget {
  const DemoScreen({required this.getIt, super.key});

  final GetIt getIt;

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  String _log = '';
  AuthScope? _authScope;
  int _analyticsCount = 0;

  void _appendLog(String msg) {
    setState(() => _log = '$_log\n$msg');
    debugPrint(msg);
  }

  // ── Fire-and-forget analytics demo ──────────────────────────────────

  void _logAnalyticsEvent() {
    _analyticsCount++;
    final analytics = widget.getIt<AnalyticsService>();
    final event = 'demo_button_tap_$_analyticsCount';

    if (analytics.isReady) {
      analytics.logEvent(event, params: {'count': _analyticsCount});
      _appendLog('[Analytics] ✓ Event "$event" sent.');
    } else {
      analytics.logEvent(event); // triggers internal no-op + debugPrint
      _appendLog('[Analytics] ✗ Not ready — "$event" dropped (SDK still initialising).');
    }
  }

  // ── Session-tied AuthScope lifecycle ──────────────────────────────

  Future<void> _simulateSignIn() async {
    _appendLog('[Auth] Signing in...');

    _authScope = AuthScope(
      parentContainer: widget.getIt,
    );
    await _authScope!.init();

    _appendLog('[Auth] AuthScope initialised — session-tied scope is live.');
    _appendLog('[Auth] rootGetIt still holds AuthRepository + UserSessionProvider.');
    _appendLog('[Auth] AuthScope._container holds feature-specific deps only.');

    _appendLog('[Auth] Simulating API call via AuthRepository (session-tied) — should succeed:');
    final repo = _authScope!.container.get<AuthRepository>();
    await repo.signIn(email: "email", password: "password");
    _appendLog('[Auth] API call successful — AuthScope is properly wired with root deps (e.g. Dio).');
  }

  void _simulateSignOut() async {
    final repo = _authScope!.container.get<AuthRepository>();
    await repo.signOut();
    _authScope?.dispose();
    _authScope = null;
    _appendLog('[Auth] Signed out — AuthScope.dispose() called, container.reset() ran.');
    _appendLog('[Auth] All session-tied singletons released. Root container intact.');
  }

  @override
  void dispose() {
    _authScope?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DI Architecture Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _authScope == null ? _simulateSignIn : null,
              child: const Text('Sign In → create AuthScope (session-tied)'),
            ),
            ElevatedButton(
              onPressed: _authScope != null ? _simulateSignOut : null,
              child: const Text('Sign Out → dispose AuthScope'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _logAnalyticsEvent,
              child: const Text('Log analytics event (fire-and-forget demo)'),
            ),
            const Divider(height: 24),
            Text(
              'Log:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log, style: const TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}