# package:navigation

Modular, type-safe navigation framework for Flutter. Decouples route declarations from routing implementation — features never need to know which router vendor is being used.

---

## Abstractions

```
RouteInput         → Strongly typed input parameters for a screen
RouteKey<TInput>   → Unique token that binds a keyId to a specific input type
RouteNode          → Descriptor: key + builder + transition
FeatureRouteModule → Contract for declaring routes per feature
RouteRegistry      → Immutable map of all RouteNodes, built once at app startup
```

---

## Usage

### 1. Declare `RouteInput`

Every screen has one `RouteInput`. Screens without parameters still must declare one to make the contract explicit.

```dart
// No parameters
final class HomeInput extends RouteInput {
  const HomeInput();
}

// With parameters
final class ProfileInput extends RouteInput {
  const ProfileInput({required this.userId});
  final String userId;
}
```

### 2. Declare `RouteKey` constants

One `*_route_keys.dart` file per feature. This is the only file other features are allowed to import for navigation purposes.

```dart
abstract final class ProfileRouteKeys {
  static const view = RouteKey<ProfileInput>('profile.view');
  static const settings = RouteKey<ProfileInput>('profile.settings');
}
```

`keyId` naming convention: `'<feature>.<screen>'` — must be **globally unique** across the entire app.

### 3. Create a `FeatureRouteModule`

```dart
final class ProfileRouteModule extends FeatureRouteModule {
  const ProfileRouteModule();

  @override
  List<RouteNode> get routes => [
    RouteNode.typed<ProfileInput>(
      key: ProfileRouteKeys.view,
      builder: (context, input) => ProfilePage(userId: input.userId),
      transition: RouteTransition.slideFromRight,
      // Optional: fallback input when the screen is opened via deep link
      defaultInput: () => const ProfileInput(userId: 'guest'),
    ),
  ];

  // Optional: entries in the Dev Menu (debug builds only)
  @override
  List<DevEntry> get devEntries => [
    DevEntry.typed<ProfileInput>(
      label: 'Profile — dev user',
      category: 'Profile',
      key: ProfileRouteKeys.view,
      inputFactory: () => const ProfileInput(userId: 'dev-user-1'),
    ),
  ];
}
```

### 4. Build the `RouteRegistry`

In the app layer, collect all modules into a single registry. This registry is used by the router adapter and `DevMenuScreen`.

```dart
final registry = RouteRegistry.fromModules([
  const AuthRouteModule(),
  const ProfileRouteModule(),
]);
```

`RouteRegistry` automatically detects duplicate `keyId`s in debug builds.

---

## Flutter Navigator Integration

> **Platform default**: The mobile platform uses **GoRouter** as the router adapter. The `RouteNode` → GoRouter bridge is implemented in `route_node_go_router_ext.dart` in the app layer. The vanilla `Navigator` example below illustrates how the abstraction works — use it as a reference when building a new adapter, not as production navigation code.

`package:navigation` has no dependency on any routing vendor. Below is an example using Flutter's built-in `Navigator` as the adapter.

### Adapt `RouteNode` → `Route`

Since `buildWidget` requires a `BuildContext`, the most practical adapter uses `MaterialPageRoute` or `PageRouteBuilder`:

```dart
extension RouteNodeNavigatorExt on RouteNode {
  MaterialPageRoute<Object?> toMaterialRoute(RouteInput input) {
    return MaterialPageRoute<Object?>(
      builder: (context) => buildWidget(context, input),
      settings: RouteSettings(name: keyId),
    );
  }

  PageRouteBuilder<Object?> toAnimatedRoute(RouteInput input) {
    return PageRouteBuilder<Object?>(
      settings: RouteSettings(name: keyId),
      pageBuilder: (context, _, __) => buildWidget(context, input),
      transitionsBuilder: switch (transition) {
        RouteTransition.fadeIn => (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        RouteTransition.slideFromRight => (_, animation, __, child) =>
            SlideTransition(
              position: Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
        RouteTransition.slideFromBottom => (_, animation, __, child) =>
            SlideTransition(
              position: Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
        RouteTransition.none => (_, __, ___, child) => child,
        RouteTransition.material => (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      },
    );
  }
}
```

### Navigate using registry + Navigator

```dart
Future<void> navigateTo<TInput extends RouteInput>(
  BuildContext context,
  RouteRegistry registry,
  RouteKey<TInput> key,
  TInput input,
) async {
  final node = registry.resolve(key);
  assert(node != null, 'Route "${key.id}" is not registered in the registry.');
  await Navigator.of(context).push(node!.toAnimatedRoute(input));
}
```

### Navigate with a result

```dart
// Push ProfilePage and wait for a result
final result = await navigateTo<ProfileInput>(
  context,
  registry,
  ProfileRouteKeys.view,
  ProfileInput(userId: user.id),
);

// Inside ProfilePage, send a result on pop:
Navigator.of(context).pop('updated');
```

### Register routes in `MaterialApp`

To use `initialRoute` + `onGenerateRoute`:

```dart
MaterialApp(
  initialRoute: '/${AuthRouteKeys.login.id}',
  onGenerateRoute: (settings) {
    final keyId = settings.name?.replaceFirst('/', '') ?? '';
    final node = registry.resolveById(keyId);
    if (node == null) return null;

    final input = (settings.arguments as RouteInput?)
        ?? node.defaultInput
        ?? (throw StateError(
            'Route "$keyId" received no RouteInput. '
            'Pass a RouteInput via arguments, or register a defaultInput.',
          ));

    return node.toAnimatedRoute(input);
  },
);
```

---

## Transition Animations

| `RouteTransition` | Description |
|---|---|
| `material` | Platform-adaptive transition (default) |
| `fadeIn` | Cross-fade |
| `slideFromRight` | Slide from the right (standard push) |
| `slideFromBottom` | Slide from the bottom (modal-style) |
| `none` | No animation |

---

## Deep Link Support

If a screen can be opened via a deep link (without an input passed by the navigator), register a `defaultInput`:

```dart
RouteNode.typed<HomeInput>(
  key: HomeRouteKeys.main,
  builder: (context, input) => const HomePage(),
  defaultInput: () => const HomeInput(),
),
```

Without `defaultInput`, opening the route without an input will throw a `StateError` with a clear message.

---

## Dev Menu

`DevMenuScreen` displays all registered `DevEntry` items grouped by feature, allowing developers and QA to open any screen directly without going through the normal app flow.

```dart
DevMenuScreen(
  registry: registry,
  onEntryTap: (entry) {
    // navigate to entry.keyId with entry.createInput()
  },
)
```

`DevMenuScreen` automatically becomes a `SizedBox.shrink()` in release builds.

---

## Feature File Structure

```
features/
  profile/
    navigation/
      profile_route_keys.dart    ← RouteInput + RouteKey (may be imported by other features)
      profile_route_module.dart  ← FeatureRouteModule   (imported by app layer only)
    presentation/
      pages/
        profile_page.dart
```

> **Import rules:**
> - Another feature that wants to navigate to Profile → import `profile_route_keys.dart`
> - Only `profile_route_module.dart` may import `ProfilePage`
> - No feature imports another feature's page widgets directly
