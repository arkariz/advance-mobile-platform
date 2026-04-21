# models

Core models package for the mobile platform. Provides shared data structures used across features and layers.

## Features

### `Paginated<T>`

A generic class representing a paginated response. Extends `Equatable` for value-based equality.

```dart
const paginated = Paginated<String>(
  items: ['a', 'b', 'c'],
  totalItems: 10,
  totalPages: 4,
  currentPage: 1,
  itemsPerPage: 3,
);
```

Use the `empty()` factory to create a zero-value instance:

```dart
final empty = Paginated<String>.empty();
```

| Property       | Type      | Description                              |
|----------------|-----------|------------------------------------------|
| `items`        | `List<T>` | Items on the current page                |
| `totalItems`   | `int`     | Total number of items across all pages   |
| `totalPages`   | `int`     | Total number of pages                    |
| `currentPage`  | `int`     | Current page number                      |
| `itemsPerPage` | `int`     | Number of items per page                 |

---

### `PaginatedMapper`

An abstract contract for mapping raw JSON into a `Paginated<T>` instance. Implement this class to provide feature-specific mapping logic.

```dart
class UserPaginatedMapper implements PaginatedMapper {
  @override
  Paginated<User> map<User>(Map<String, dynamic> json) {
    return Paginated(
      items: (json['data'] as List).map((e) => User.fromJson(e)).toList(),
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      itemsPerPage: json['itemsPerPage'] as int,
    );
  }
}
```

## Installation

This package is part of the mobile platform monorepo and is resolved via the workspace. Add it as a dependency in your package's `pubspec.yaml`:

```yaml
dependencies:
  models:
```

## Usage

```dart
import 'package:models/models.dart';
```
