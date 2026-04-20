# dependencies

A shared package for managing all external dependencies in one place. Instead of declaring the same packages in every module's `pubspec.yaml`, each module simply depends on this package to get a consistent, version-locked set of libraries across the entire project.

## Why

- **Single source of truth** — dependency versions are declared once and shared across all modules.
- **Easier upgrades** — bumping a library version only requires a change in this package.
- **Consistency** — all modules use the exact same version of every library, eliminating version conflicts.

## Usage

Add this package to your module's `pubspec.yaml`:

```yaml
dependencies:
  dependencies:
    path: ../../shared/dependencies
```

Then import it in your Dart code:

```dart
import 'package:dependencies/dependencies.dart';
```

All packages are re-exported from the single entry point, so no additional imports are needed.

## Adding a new dependency

1. Add the package to `pubspec.yaml` in this package.
2. Re-export it in `lib/dependencies.dart`.
3. Run `dart pub get` from the workspace root.
