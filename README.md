# Mobile Platform

A Flutter monorepo that provides reusable, independently-versioned packages for state management, navigation, networking, dependency injection, and shared utilities. It enables consistent patterns across all applications built on top of it.

---

## Documentation

Documentation lives in this repository, not in an external tool:

| Section | Where |
|---------|-------|
| Architecture, layer design, package catalog | [Package Structure](#package-structure) below |
| Getting set up | [Getting Started](#getting-started) below |
| Per-package usage guides | Each package's own `README.md` (e.g. `core/failures/README.md`) |
| Design decisions and trade-offs | Each package's `CHANGELOG.md` |

---

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.44.1 (pinned in `.fvm/fvm_config.json`) | UI framework |
| Dart | `>=3.11.0 <4.0.0` (see `pubspec.yaml`) | Language |
| Melos | 7.5.1 | Monorepo management |
| FVM | Latest | Flutter SDK version manager |

---

## Package Structure

The codebase is organized into five layers:

```
core/
  failures/          ← Sealed Failure hierarchy (v2.0.3)
  models/            ← Shared data structures: Paginated<T> (v1.1.3)

fondation/
  state_management/  ← BLoC + one-shot Effect pattern (v2.2.0)
  navigation/        ← Type-safe, vendor-agnostic routing (v1.1.1)

infrastructure/
  network/
    api_network/     ← NetworkCallHandler contract + response types (v1.2.4)
    dio_network/     ← Dio implementation of NetworkCallHandler (v1.3.5)
  storage/
    api_storage/     ← Storage ports, serializers and key model (v1.1.1)
    hive_storage/    ← Hive CE adapters for KeyValueStorage and SecureStorage (v1.1.2)
    memory_storage/  ← In-memory adapters for tests (v1.1.2)
    firestore_storage/ ← Typed Firestore access, errors mapped to Failure (v1.0.0)
  security/
    secure_cipher/   ← Authenticated encryption: AES-256-CBC + HMAC-SHA256 (v1.0.1)

shared/
  dependencies/      ← Centralized third-party version pinning (v1.4.0)
  di/                ← DiBoot + IsolatedScope DI scaffolding (v1.1.2)
  linter/            ← Shared very_good_analysis linting config (v1.0.2)

app_example/         ← Reference app demonstrating all platform patterns
```

**Dependency flow**: App → Foundation / Infrastructure → Core → Shared. No package may import from a layer above it.

---

## Getting Started

### 1. Install prerequisites

```bash
dart pub global activate fvm
dart pub global activate melos
```

### 2. Clone and set up

```bash
git clone https://github.com/arkariz/advance-mobile-platform
cd advance-mobile-platform
```

### 3. Install the correct Flutter SDK

```bash
fvm install   # reads version from .fvm/fvm_config.json
fvm use
```

After this, use `fvm flutter` instead of `flutter` for all commands.

### 4. Bootstrap with Melos

```bash
melos bootstrap
```

Installs all package dependencies across the monorepo and links local packages. Re-run whenever any `pubspec.yaml` changes.

### 5. Verify the setup

```bash
melos run analyze
melos run test
```

Both should complete with zero errors.

### 6. Run the example app

```bash
cd app_example
fvm flutter run
```

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `melos bootstrap` | Install all dependencies and link local packages |
| `melos run analyze` | Run static analysis across all packages |
| `melos run test` | Run unit tests across all packages |
| `melos run build` | Run code generation (build_runner) across all packages |
| `melos run clean` | Clean all package build artifacts |
| `melos version` | Bump versions based on Conventional Commits and create Git tags |
| `melos list --mermaid` | Print the package dependency graph as a Mermaid diagram |

---

## IDE Setup

**VS Code**: Install the Flutter and Dart extensions. Open the repository root as the workspace.

**Android Studio / IntelliJ**: Open the repository root. The `.iml` files for each package are committed.

> Configure your IDE to use the FVM-managed Flutter SDK at `.fvm/flutter_sdk` within the repository.

---

## Versioning

Each package is independently versioned using semantic versioning. Use `melos version` to automate version bumps from Conventional Commits. See each package's `CHANGELOG.md` for history.


## 🤝 Contributing

Guidelines:

1. Follow existing architecture patterns  
2. Keep modules decoupled  
3. Write tests for critical logic  
4. Avoid introducing cross-layer dependencies  