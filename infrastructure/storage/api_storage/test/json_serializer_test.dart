import 'package:api_storage/api_storage.dart';
import 'package:failures/failures.dart';
import 'package:test/test.dart';

// _Point is a test-only value object; == and hashCode overrides are intentional.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

// Minimal model for testing without code generation.
final class _Point {
  const _Point({required this.x, required this.y});

  factory _Point.fromJson(Map<String, dynamic> json) =>
      _Point(x: json['x'] as int, y: json['y'] as int);

  final int x;
  final int y;

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      other is _Point && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

void main() {
  final serializer = JsonSerializer<_Point>(
    fromJson: _Point.fromJson,
    toJson: (p) => p.toJson(),
  );

  group('JsonSerializer', () {
    test('encode then decode round-trips the original value', () {
      const point = _Point(x: 3, y: 7);
      final encoded = serializer.encode(point);
      final decoded = serializer.decode(encoded);
      expect(decoded, point);
    });

    test('encode produces valid JSON string', () {
      const point = _Point(x: 1, y: 2);
      final json = serializer.encode(point);
      expect(json, '{"x":1,"y":2}');
    });

    test('decode throws PersistenceFailure on invalid JSON', () {
      expect(
        () => serializer.decode('not-valid-json{{{'),
        throwsA(
          isA<PersistenceFailure>().having(
            (f) => f.code,
            'code',
            StorageFailureCode.serializationFailed,
          ),
        ),
      );
    });

    test('decode throws PersistenceFailure when JSON is not an object', () {
      // Valid JSON but not a Map — fromJson will fail the cast.
      expect(
        () => serializer.decode('[1, 2, 3]'),
        throwsA(isA<PersistenceFailure>()),
      );
    });
  });
}
