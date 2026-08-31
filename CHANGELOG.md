# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-08-31

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dependencies` - `v1.4.0`](#dependencies---v140)
 - [`dio_network` - `v1.3.4`](#dio_network---v134)
 - [`models` - `v1.1.3`](#models---v113)
 - [`state_management` - `v2.1.3`](#state_management---v213)
 - [`api_network` - `v1.2.4`](#api_network---v124)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `models` - `v1.1.3`
 - `state_management` - `v2.1.3`
 - `api_network` - `v1.2.4`

---

#### `dependencies` - `v1.4.0`

 - **FEAT**(dependencies): update dio dependency version to ^5.11.0.

#### `dio_network` - `v1.3.4`

 - **FIX**(dio_network): add transformTimeout to NetworkFailure mapping.


## 2026-05-06

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`state_management` - `v2.1.2`](#state_management---v212)

---

#### `state_management` - `v2.1.2`

 - **FIX**(state_management): update dependency reference to v1.3.0 in pubspec.yaml.


## 2026-05-06

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`hive_storage` - `v1.1.1`](#hive_storage---v111)
 - [`memory_storage` - `v1.1.1`](#memory_storage---v111)
 - [`state_management` - `v2.1.1`](#state_management---v211)

---

#### `hive_storage` - `v1.1.1`

 - **FIX**(hive_storage): correct path for api_storage dependency in pubspec.yaml.

#### `memory_storage` - `v1.1.1`

 - **FIX**(memory_storage): correct path for api_storage dependency in pubspec.yaml.

#### `state_management` - `v2.1.1`

 - **FIX**(state_management): update path for shared dependencies in pubspec.yaml.


## 2026-04-29

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`api_storage` - `v1.1.0`](#api_storage---v110)
 - [`di` - `v1.1.2`](#di---v112)
 - [`hive_storage` - `v1.1.0`](#hive_storage---v110)
 - [`memory_storage` - `v1.1.0`](#memory_storage---v110)

---

#### `api_storage` - `v1.1.0`

 - **FEAT**(api_storage): implement storage contract layer with serializers, models, and ports.

#### `di` - `v1.1.2`

 - **FIX**(di): make initState and dispose methods synchronous and handle async cleanup.

#### `hive_storage` - `v1.1.0`

 - **REFACTOR**(hive_storage): replace HiveStorageInitializer with direct Hive initialization and remove unused initializer.
 - **FEAT**(hive_storage): add Hive CE-backed storage adapters with initialization and error mapping.

#### `memory_storage` - `v1.1.0`

 - **FEAT**(memory_storage): add in-memory storage adapters for testing with comprehensive documentation and tests.


## 2026-04-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`api_network` - `v1.2.3`](#api_network---v123)
 - [`models` - `v1.1.2`](#models---v112)
 - [`dio_network` - `v1.3.3`](#dio_network---v133)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dio_network` - `v1.3.3`

---

#### `api_network` - `v1.2.3`

 - **FIX**(api_network): remove unused flutter dependency.

#### `models` - `v1.1.2`

 - **FIX**(model): remove unused flutter dependency.


## 2026-04-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`failures` - `v2.0.2`](#failures---v202)

---

#### `failures` - `v2.0.2`

 - **FIX**(failure): remove unused flutter dependency.


## 2026-04-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`api_network` - `v1.2.2`](#api_network---v122)
 - [`di` - `v1.1.1`](#di---v111)
 - [`dio_network` - `v1.3.2`](#dio_network---v132)
 - [`failures` - `v2.0.1`](#failures---v201)
 - [`navigation` - `v1.1.1`](#navigation---v111)
 - [`state_management` - `v2.1.0`](#state_management---v210)

---

#### `api_network` - `v1.2.2`

 - **DOCS**: update README files for improved clarity and structure across multiple packages.

#### `di` - `v1.1.1`

 - **DOCS**: update README files for improved clarity and structure across multiple packages.

#### `dio_network` - `v1.3.2`

 - **DOCS**: update README files for improved clarity and structure across multiple packages.

#### `failures` - `v2.0.1`

 - **DOCS**: update README files for improved clarity and structure across multiple packages.

#### `navigation` - `v1.1.1`

 - **DOCS**: update README files for improved clarity and structure across multiple packages.

#### `state_management` - `v2.1.0`

 - **FEAT**(state_management): add BlocContext class for internal BLoC data management.
 - **DOCS**: update README files for improved clarity and structure across multiple packages.


## 2026-04-24

### Changes

---

Packages with breaking changes:

 - [`state_management` - `v2.0.0`](#state_management---v200)

Packages with other changes:

 - [`navigation` - `v1.1.0`](#navigation---v110)

---

#### `state_management` - `v2.0.0`

 - **BREAKING** **FEAT**(state_management): enhance navigation effects with improved documentation and structure.

#### `navigation` - `v1.1.0`

 - **FEAT**(navigation): add navigation framework with modular structure and type-safe routing.


## 2026-04-23

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`state_management` - `v1.1.0`](#state_management---v110)

---

#### `state_management` - `v1.1.0`

 - **FEAT**: add initial state management package with BLoC pattern implementation.


## 2026-04-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dependencies` - `v1.3.0`](#dependencies---v130)
 - [`linter` - `v1.0.2`](#linter---v102)
 - [`models` - `v1.1.1`](#models---v111)
 - [`dio_network` - `v1.3.1`](#dio_network---v131)
 - [`api_network` - `v1.2.1`](#api_network---v121)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `models` - `v1.1.1`
 - `dio_network` - `v1.3.1`
 - `api_network` - `v1.2.1`

---

#### `dependencies` - `v1.3.0`

 - **FEAT**(dependencies): add fpdart package to dependencies and exports.

#### `linter` - `v1.0.2`

 - **FIX**(linter): ensure comment_references rule is set to false.


## 2026-04-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`di` - `v1.1.0`](#di---v110)

---

#### `di` - `v1.1.0`

 - **FEAT**(di): add initial implementation of dependency injection framework with core components.


## 2026-04-21

### Changes

---

Packages with breaking changes:

 - [`failures` - `v2.0.0`](#failures---v200)

Packages with other changes:

 - [`api_network` - `v1.2.0`](#api_network---v120)
 - [`dio_network` - `v1.3.0`](#dio_network---v130)
 - [`models` - `v1.1.0`](#models---v110)

---

#### `failures` - `v2.0.0`

 - **BREAKING** **FEAT**(failures): remove RestApiHandler and related documentation.

#### `api_network` - `v1.2.0`

 - **FEAT**(api_network): refactor directory form core/response into infrastructure/network/api_network.

#### `dio_network` - `v1.3.0`

 - **FEAT**(dio_network): update imports and refactor RestApiHandler to NetworkCallHandler.

#### `models` - `v1.1.0`

 - **FEAT**(models): add core models package with pagination support and tests.


## 2026-04-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dependencies` - `v1.2.0`](#dependencies---v120)
 - [`response` - `v1.1.2`](#response---v112)
 - [`dio_network` - `v1.2.1`](#dio_network---v121)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `response` - `v1.1.2`
 - `dio_network` - `v1.2.1`

---

#### `dependencies` - `v1.2.0`

 - **FEAT**(dependencies): add equatable.


## 2026-04-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dio_network` - `v1.2.0`](#dio_network---v120)

---

#### `dio_network` - `v1.2.0`

 - **FEAT**(dio_network): refactor directory form infrastructure/network into infrastructure/network/dio_network.


## 2026-04-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`network` - `v1.1.1`](#network---v111)
 - [`response` - `v1.1.1`](#response---v111)

---

#### `network` - `v1.1.1`

 - **FIX**(network): correct path for dependencies in pubspec.yaml.

#### `response` - `v1.1.1`

 - **FIX**(response): correct path for shared dependencies in pubspec.yaml.


## 2026-04-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`network` - `v1.1.0`](#network---v110)

---

#### `network` - `v1.1.0`

 - **FEAT**(network): create dio network adapter & failure mapper.


## 2026-04-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`failures` - `v1.1.0`](#failures---v110)

---

#### `failures` - `v1.1.0`

 - **FEAT**(failures): implement core failure model with detailed error handling and recovery options.


## 2026-04-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`response` - `v1.1.0`](#response---v110)

---

#### `response` - `v1.1.0`

 - **FEAT**(response): feat create api error, object, and paginated response.


## 2026-04-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dependencies` - `v1.1.0`](#dependencies---v110)

---

#### `dependencies` - `v1.1.0`

 - **FEAT**(dependencies): add shared dependencies package with initial configuration and documentation.


## 2026-04-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linter` - `v1.0.1`](#linter---v101)

---

#### `linter` - `v1.0.1`

 - **FIX**(linter): patch adding rule lines_longer_than_80_chars to false.


## 2026-04-17

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linter` - `v1.0.0`](#linter---v100)

---

#### `linter` - `v1.0.0`

 - **FEAT**(linter): initial release.

