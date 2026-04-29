import 'package:api_network/api_network.dart';
import 'package:app_example/core/storage/app_storage.dart';
import 'package:app_example/features/auth/data/data.dart';
import 'package:app_example/features/auth/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_storage/memory_storage.dart';

// Minimal stub — only the methods called by AuthRepositoryImpl are needed.
final class _StubDatasource implements AuthDatasource {
  _StubDatasource({required this.response});

  final UserResponse response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ObjectResponse<UserResponse>> signIn({
    required String email,
    required String password,
  }) async =>
      ObjectResponse(data: response);

  @override
  Future<ObjectResponse<void>> signOut() async => ObjectResponse(data: null);
}

// Minimal NetworkCallHandler stub that just calls through.
final class _PassthroughHandler extends NetworkCallHandler {
  @override
  Future<T> handle<T>(Future<T> Function() apiCall) => apiCall();
}

void main() {
  late InMemorySecureStorage secureStorage;
  late InMemoryKeyValueStorage cacheStorage;
  late AppStorage appStorage;
  late AuthStorage authStorage;
  late AuthRepositoryImpl repository;

  const tUser = User(id: '1', email: 'test@example.com', name: 'Test User');

  setUp(() {
    secureStorage = InMemorySecureStorage();
    cacheStorage = InMemoryKeyValueStorage();
    appStorage = AppStorage(secureStorage: secureStorage);
    authStorage = AuthStorage(cacheStorage: cacheStorage);
    repository = AuthRepositoryImpl(
      dataSource: _StubDatasource(
        response: UserResponse(id: tUser.id, email: tUser.email, name: tUser.name),
      ),
      networkCallHandler: _PassthroughHandler(),
      appStorage: appStorage,
      authStorage: authStorage,
    );
  });

  group('getSignedInUser', () {
    test('returns null when no user is stored', () async {
      expect(await repository.getSignedInUser(), isNull);
    });

    test('returns user after sign-in', () async {
      await repository.signIn(email: tUser.email, password: 'pass');
      expect(await repository.getSignedInUser(), tUser);
    });

    test('returns null after sign-out', () async {
      await repository.signIn(email: tUser.email, password: 'pass');
      await repository.signOut();
      expect(await repository.getSignedInUser(), isNull);
    });
  });

  group('getCachedUser', () {
    test('returns null when cache is empty', () async {
      expect(await repository.getCachedUser(), isNull);
    });

    test('returns user after sign-in', () async {
      await repository.signIn(email: tUser.email, password: 'pass');
      expect(await repository.getCachedUser(), tUser);
    });

    test('returns null after sign-out clears cache', () async {
      await repository.signIn(email: tUser.email, password: 'pass');
      await repository.signOut();
      expect(await repository.getCachedUser(), isNull);
    });
  });

  group('signIn', () {
    test('writes user to both app and cache storage', () async {
      await repository.signIn(email: tUser.email, password: 'pass');

      // Verify through repository methods (domain layer).
      expect(await repository.getSignedInUser(), tUser);
      expect(await repository.getCachedUser(), tUser);

      // Optionally inspect raw store via entries (test-only escape hatch).
      expect(secureStorage.entries, isNotEmpty);
      expect(cacheStorage.entries, isNotEmpty);
    });

    test('returns the signed-in user', () async {
      final result = await repository.signIn(email: tUser.email, password: 'pass');
      expect(result, tUser);
    });
  });

  group('signOut', () {
    test('clears both storages', () async {
      await repository.signIn(email: tUser.email, password: 'pass');
      await repository.signOut();

      expect(secureStorage.entries, isEmpty);
      expect(cacheStorage.entries, isEmpty);
    });
  });
}
