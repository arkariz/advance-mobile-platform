# state_management

BLoC foundation layer for the mobile platform. Provides base classes for states, one-shot side effects, effect routing, and a global bloc observer.

---

## Concepts

### UiState

Abstract base for all bloc states. Carries an optional one-shot `UiEffect`.

```dart
sealed class AuthState extends UiState<AuthState> {
  const AuthState({super.effect});

  @override
  AuthState copyWith({UiEffect? effect});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.effect});

  @override
  AuthState copyWith({UiEffect? effect}) => AuthLoading(effect: effect);

  @override
  List<Object?> get props => [];
}
```

Key points:
- `effect` is intentionally excluded from `props` — widget rebuilds are driven by data fields only.
- `==` and `hashCode` include `effect`, so bloc still emits when only the effect changes.
- Every subclass implements `copyWith({UiEffect? effect, ...})` with its own fields.

---

### UiEffect

Base class for one-shot side effects. Each instance is unique by timestamp, so re-emitting the same effect type always triggers the handler.

```dart
// Always unique — safe to emit the same effect twice
emitWithEffect(emit, state, ShowSnackBarEffect(message: 'Saved'));
emitWithEffect(emit, state, ShowSnackBarEffect(message: 'Saved')); // both fire
```

Effect hierarchy:

| Class | Purpose |
|---|---|
| `UiEffect` | Base — unique by timestamp |
| `AutoDismissEffect` | Extends `UiEffect` — declares `autoDismissDuration` |
| `InteractiveEffect` | Extends `UiEffect` — declares `intentId` for user responses |
| `NavigationEffect` | Extends `UiEffect` — base for navigation |

Built-in concrete effects:

| Effect | Type | Description |
|---|---|---|
| `NavigateGoEffect` | `NavigationEffect` | Navigate to a named route with optional args/query |
| `NavigatePushEffect` | `NavigationEffect` | Push a route |
| `NavigatePopEffect` | `NavigationEffect` | Pop the current route |
| `NavigateReplaceEffect` | `NavigationEffect` | Replace the current route |
| `ShowSnackBarEffect` | `AutoDismissEffect` | Show a snackbar with severity level |
| `ShowDialogEffect` | `InteractiveEffect` | Show a dialog with intent-based actions |

---

### Emitting effects

Effects are attached directly in the state constructor or via `withEffect` — no base class required, just extend `Bloc` normally.

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(...) : super(const AuthInitial()) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Signing in...'));
    try {
      final user = await _repo.signIn(email: event.email, password: event.password);
      // Effect passed directly in the constructor
      emit(AuthAuthenticated(user, effect: _effectNavigateToHome));
    } on Failure catch (f) {
      emit(AuthUnauthenticated(effect: _effectAuthError(f.message)));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Signing out...'));
    try {
      await _repo.signOut();
      emit(AuthUnauthenticated(effect: _effectNavigateToLogin));
    } on Failure catch (f) {
      // Attach effect to the current state without changing it
      emit(state.withEffect(_effectAuthError(f.message)));
    }
  }
}
```

Two patterns:
- **Constructor** — `emit(MyState(data, effect: someEffect))` — use when the new state and effect are emitted together.
- **`withEffect`** — `emit(state.withEffect(someEffect))` — use when you need to attach an effect to the *current* state without changing its other fields.

---

### EffectRegistry

Maps effect types to handlers. Decouple side-effect handling from widget logic.

```dart
final registry = EffectRegistry()
  ..register<ShowSnackBarEffect>((context, effect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(effect.message)),
    );
  })
  ..register<NavigateGoEffect>((context, effect) {
    Navigator.of(context).pushNamed(effect.route, arguments: effect.arguments);
  });
```

Registries can be created as `late final` in `initState` and reused — or extracted into a factory function shared across multiple pages.

---

### EffectListener

A widget that listens to state changes and dispatches effects. By default it uses `globalEffectRegistry`, which is pre-configured at app startup with the platform-wide handlers:

```dart
// Primary usage — relies on globalEffectRegistry
EffectListener<AuthBloc, AuthState>(
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) => ...,
  ),
)
```

For feature-specific overrides, supply an explicit registry:

```dart
// Override with a local registry (e.g., feature-specific navigation)
EffectListener<AuthBloc, AuthState>(
  registry: buildAuthEffectRegistry(),
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) => ...,
  ),
)
```

Only fires when `state.hasEffect == true` and the effect instance changes — prevents double-firing on unrelated rebuilds.

---

### AppBlocObserver

Drop-in observer that logs bloc lifecycle events via `dart:developer`. Register once at app startup.

```dart
void main() {
  Bloc.observer = const AppBlocObserver();
  runApp(const App());
}
```

---

---

### BlocContext

`BlocContext<T>` holds data that a BLoC needs internally across events but that should **never be emitted** to the widget stream. It keeps `UiState` clean — no debug data, retry counts, or intermediate values leak to the UI.

```dart
// bloc/context/auth_context.dart
final class AuthContext extends BlocContext<AuthContext> {
  final String? pendingEmail;
  final int retryCount;

  const AuthContext({this.pendingEmail, this.retryCount = 0});

  // Computed getter — derived from stored fields
  bool get isLockedOut => retryCount > 3;

  // Setter helpers — return a new instance (immutable)
  AuthContext setPendingEmail(String email) => copyWith(pendingEmail: email);
  AuthContext incrementRetryCount() => copyWith(retryCount: retryCount + 1);

  @override
  AuthContext copyWith({String? pendingEmail, int? retryCount}) {
    return AuthContext(
      pendingEmail: pendingEmail ?? this.pendingEmail,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  List<Object?> get props => [pendingEmail, retryCount];
}
```

Usage inside a BLoC — store it as a field, update it by reassigning:

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(...) : super(const AuthInitial()) {
    _ctx = const AuthContext();
    on<AuthSignInRequested>(_onSignIn);
  }

  late AuthContext _ctx;

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    if (_ctx.isLockedOut) {
      emit(state.withEffect(
          ShowSnackBarEffect(message: 'Too many retries. Try later.')));
      return;
    }
    try {
      _ctx = _ctx.setPendingEmail(event.email); // update context — not emitted
      await _repo.signIn(email: event.email, password: event.password);
      emit(AuthAuthenticated(effect: _effectNavigateToHome));
    } on Failure catch (_) {
      _ctx = _ctx.incrementRetryCount(); // track retry count internally
      emit(state.withEffect(ShowSnackBarEffect(message: 'Sign in failed')));
    }
  }
}
```

Key points:
- `_ctx` is a plain BLoC field — it is **never** passed to `emit()`.
- Widgets cannot observe `BlocContext` — it is completely invisible to the stream.
- Because `BlocContext` extends `Equatable`, equality checks in tests are straightforward.

---

## Typical file structure

```
features/auth/presentation/
├── bloc/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   ├── auth_state.dart
│   ├── auth_side_effect.dart   ← part of auth_bloc.dart
│   └── context/
│       └── auth_context.dart  ← BlocContext for this feature
└── pages/
    ├── login_page.dart
    └── home_page.dart
```

Side effects are grouped in a `part` extension on the bloc:

```dart
// auth_side_effect.dart
part of 'auth_bloc.dart';

extension AuthSideEffect on AuthBloc {
  NavigateGoEffect get _effectNavigateToHome => NavigateGoEffect(route: 'home');

  ShowSnackBarEffect _effectAuthError(String message) =>
      ShowSnackBarEffect(message: message, severity: FeedbackSeverity.error);
}
```
