# Mobile Platform

A Flutter monorepo that provides reusable, independently-versioned packages for state management, navigation, networking, dependency injection, and shared utilities. It enables consistent patterns across all applications built on top of it.

---

## Documentation

Centralized documentation is available on Notion:

**[📱 Mobile Platform — Notion](https://www.notion.so/Mobile-Platform-4127703e10f54784aad6be8d328c4100)**

| Section | Purpose |
|---------|---------|
| [🏛️ Architecture](https://www.notion.so/Architecture-34f69c872e0081a6a016f6c4964aea90) | Monorepo structure, layer design, package catalog, and design principles |
| [🚀 Onboarding](https://www.notion.so/Onboarding-34f69c872e008122b3adf37ae856a98b) | Step-by-step guides to get set up and start contributing |
| [📖 Developer Reference](https://www.notion.so/Developer-Reference-34f69c872e00816f87b5c31d90ddc5af) | In-depth guides for each major platform subsystem |

---

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.41.6 | UI framework |
| Dart | 3.11.4 | Language |
| Melos | 7.5.1 | Monorepo management |
| FVM | Latest | Flutter SDK version manager |

---

## Package Structure

The codebase is organized into five layers:

```
core/
  failures/          ← Sealed Failure hierarchy (v2.0.0)
  models/            ← Shared data structures: Paginated<T> (v1.1.1)

fondation/
  state_management/  ← BLoC + one-shot Effect pattern (v2.0.0)
  navigation/        ← Type-safe, vendor-agnostic routing (v1.1.0)

infrastructure/
  network/
    api_network/     ← NetworkCallHandler contract + response types (v1.2.1)
    dio_network/     ← Dio implementation of NetworkCallHandler (v1.3.1)

shared/
  dependencies/      ← Centralized third-party version pinning (v1.3.0)
  di/                ← DiBoot + IsolatedScope DI scaffolding (v1.1.0)
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
git clone <repository-url>
cd mobile-platform
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