import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/core/errors/failures.dart';
import 'package:leadx_crm/core/errors/result.dart';
import 'package:leadx_crm/core/logging/app_logger.dart';
import 'package:leadx_crm/data/repositories/auth_repository_impl.dart';
import 'package:leadx_crm/domain/entities/app_auth_state.dart';
import 'package:leadx_crm/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// -- Mocks --
class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

/// Custom fake for SupabaseClient that avoids mocking `from()` which returns
/// a Future-implementing type that confuses mocktail.
class FakeSupabaseClient extends Fake implements supabase.SupabaseClient {
  final MockGoTrueClient mockAuth;
  final FakeQueryChain queryChain;

  FakeSupabaseClient({required this.mockAuth, required this.queryChain});

  @override
  supabase.GoTrueClient get auth => mockAuth;

  @override
  supabase.SupabaseQueryBuilder from(String table) => queryChain;
}

/// Fake query chain: simulates from('table').select().eq().single() and
/// from('table').update({...}).eq()
class FakeQueryChain extends Fake implements supabase.SupabaseQueryBuilder {
  Map<String, dynamic>? _singleResult;
  Object? _singleError;

  void setSingleResult(Map<String, dynamic> result) {
    _singleResult = result;
    _singleError = null;
  }

  void setSingleError(Object error) {
    _singleError = error;
    _singleResult = null;
  }

  @override
  supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
      [String columns = '*']) {
    return _FakeFilterBuilder(this);
  }

  @override
  supabase.PostgrestFilterBuilder<void> update(Map values) {
    return _FakeFilterBuilderVoid();
  }
}

class _FakeFilterBuilder extends Fake
    implements supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final FakeQueryChain _parent;
  _FakeFilterBuilder(this._parent);

  @override
  supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
      String column, Object value) => this;

  @override
  supabase.PostgrestTransformBuilder<Map<String, dynamic>> single() =>
      _FakeTransformBuilder(_parent);
}

class _FakeFilterBuilderVoid extends Fake
    implements supabase.PostgrestFilterBuilder<void> {
  @override
  supabase.PostgrestFilterBuilder<void> eq(String column, Object value) =>
      this;

  @override
  Future<S> then<S>(FutureOr<S> Function(void value) onValue,
      {Function? onError}) async {
    return onValue(null);
  }

  @override
  Future<void> timeout(Duration timeLimit,
      {FutureOr<void> Function()? onTimeout}) async {}
}

class _FakeTransformBuilder extends Fake
    implements supabase.PostgrestTransformBuilder<Map<String, dynamic>> {
  final FakeQueryChain _parent;
  late final Future<Map<String, dynamic>> _future;

  _FakeTransformBuilder(this._parent) {
    if (_parent._singleError != null) {
      _future = Future<Map<String, dynamic>>.error(_parent._singleError!);
    } else {
      _future = Future<Map<String, dynamic>>.value(_parent._singleResult!);
    }
  }

  @override
  Future<S> then<S>(FutureOr<S> Function(Map<String, dynamic> value) onValue,
      {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<Map<String, dynamic>> timeout(Duration timeLimit,
      {FutureOr<Map<String, dynamic>> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<Map<String, dynamic>> catchError(Function onError,
          {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<Map<String, dynamic>> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Stream<Map<String, dynamic>> asStream() => _future.asStream();
}

void main() {
  setUpAll(() {
    AppLogger.init();
  });

  late AuthRepositoryImpl repository;
  late MockGoTrueClient mockAuth;
  late FakeQueryChain fakeQueryChain;

  final testUserJson = {
    'id': 'test-user-id',
    'email': 'test@example.com',
    'name': 'Test User',
    'nip': '12345',
    'phone': '+6281234567890',
    'role': 'RM',
    'parent_id': null,
    'branch_id': 'branch-1',
    'regional_office_id': 'ro-1',
    'photo_url': null,
    'is_active': true,
    'last_login_at': null,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  };

  setUp(() {
    mockAuth = MockGoTrueClient();
    fakeQueryChain = FakeQueryChain();

    final fakeClient = FakeSupabaseClient(
      mockAuth: mockAuth,
      queryChain: fakeQueryChain,
    );

    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream<supabase.AuthState>.empty(),
    );

    repository = AuthRepositoryImpl(fakeClient);
  });

  group('AuthRepositoryImpl', () {
    group('signIn', () {
      test('returns User on successful login', () async {
        // Arrange
        final mockSession = _createMockSession();
        final mockUser = _createMockSupabaseUser();
        final authResponse = supabase.AuthResponse(
          session: mockSession,
          user: mockUser,
        );

        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => authResponse);

        fakeQueryChain.setSingleResult(testUserJson);

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, isA<Success<User>>());
        final user = (result as Success<User>).value;
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, UserRole.rm);
      });

      test('returns AuthFailure when credentials are invalid', () async {
        // Arrange
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(supabase.AuthException('Invalid login credentials'));

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        // Assert
        expect(result, isA<ResultFailure<User>>());
        final failure = (result as ResultFailure<User>).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Email atau password salah'));
      });

      test('returns AuthFailure when user is inactive', () async {
        // Arrange
        final mockSession = _createMockSession();
        final mockUser = _createMockSupabaseUser();
        final authResponse = supabase.AuthResponse(
          session: mockSession,
          user: mockUser,
        );

        final inactiveUserJson = Map<String, dynamic>.from(testUserJson);
        inactiveUserJson['is_active'] = false;

        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => authResponse);

        fakeQueryChain.setSingleResult(inactiveUserJson);
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, isA<ResultFailure<User>>());
        final failure = (result as ResultFailure<User>).failure;
        expect(failure.message, contains('inactive'));
        verify(() => mockAuth.signOut()).called(1);
      });

      test('returns AuthFailure when no session returned', () async {
        // Arrange
        final authResponse = supabase.AuthResponse(session: null);

        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => authResponse);

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, isA<ResultFailure<User>>());
        final failure = (result as ResultFailure<User>).failure;
        expect(failure.message, contains('No session returned'));
      });
    });

    group('signOut', () {
      test('returns Success(null) on successful sign out', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockAuth.signOut()).called(1);
      });

      test('returns ResultFailure when sign out fails', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenThrow(Exception('Sign out error'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<ResultFailure<void>>());
        final failure = (result as ResultFailure<void>).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Sign out failed'));
      });
    });

    group('getCurrentUser', () {
      test('returns null when no session exists', () async {
        // Arrange
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act
        final user = await repository.getCurrentUser();

        // Assert
        expect(user, isNull);
      });

      test('returns User when session exists', () async {
        // Arrange
        final mockSession = _createMockSession();
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        fakeQueryChain.setSingleResult(testUserJson);

        // Act
        final user = await repository.getCurrentUser();

        // Assert
        expect(user, isNotNull);
        expect(user!.email, 'test@example.com');
        expect(user.name, 'Test User');
      });

      test('returns minimal user when remote fetch fails (offline fallback)', () async {
        // Arrange
        final mockSession = _createMockSession();
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        fakeQueryChain.setSingleError(Exception('Database error'));

        // Act
        final user = await repository.getCurrentUser();

        // Assert - falls back to minimal user from session (no DB in test)
        expect(user, isNotNull);
        expect(user!.id, 'test-user-id');
      });
    });

    group('refreshSession', () {
      test('returns AuthSession on successful refresh', () async {
        // Arrange
        final mockSession = _createMockSession();
        final mockUser = _createMockSupabaseUser();
        final authResponse = supabase.AuthResponse(
          session: mockSession,
          user: mockUser,
        );

        when(() => mockAuth.refreshSession())
            .thenAnswer((_) async => authResponse);
        fakeQueryChain.setSingleResult(testUserJson);

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result, isA<Success<AuthSession>>());
        final session = (result as Success<AuthSession>).value;
        expect(session.accessToken, 'test-access-token');
        expect(session.user.email, 'test@example.com');
      });

      test('returns ResultFailure when refresh fails', () async {
        // Arrange
        when(() => mockAuth.refreshSession())
            .thenThrow(Exception('Session refresh error'));

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result, isA<ResultFailure<AuthSession>>());
        final failure = (result as ResultFailure<AuthSession>).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Session refresh failed'));
      });

      test('returns ResultFailure when session is null', () async {
        // Arrange
        final authResponse = supabase.AuthResponse(session: null);
        when(() => mockAuth.refreshSession())
            .thenAnswer((_) async => authResponse);

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result, isA<ResultFailure<AuthSession>>());
      });
    });

    group('getAuthState', () {
      test('returns unauthenticated when no session', () async {
        // Arrange
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act
        final state = await repository.getAuthState();

        // Assert
        state.when(
          initial: () => fail('Expected unauthenticated'),
          loading: () => fail('Expected unauthenticated'),
          authenticated: (_) => fail('Expected unauthenticated'),
          unauthenticated: () {}, // expected
          error: (_) => fail('Expected unauthenticated'),
          passwordRecovery: () => fail('Expected unauthenticated'),
        );
      });

      test('returns authenticated when session exists', () async {
        // Arrange
        final mockSession = _createMockSession();
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        fakeQueryChain.setSingleResult(testUserJson);

        // Act
        final state = await repository.getAuthState();

        // Assert
        state.when(
          initial: () => fail('Expected authenticated'),
          loading: () => fail('Expected authenticated'),
          authenticated: (user) {
            expect(user.email, 'test@example.com');
          },
          unauthenticated: () => fail('Expected authenticated'),
          error: (_) => fail('Expected authenticated'),
          passwordRecovery: () => fail('Expected authenticated'),
        );
      });
    });

    group('requestPasswordReset', () {
      test('returns Success(null) on success', () async {
        // Arrange
        when(() => mockAuth.resetPasswordForEmail(
              any(),
              redirectTo: any(named: 'redirectTo'),
            )).thenAnswer((_) async {});

        // Act
        final result =
            await repository.requestPasswordReset('test@example.com');

        // Assert
        expect(result, isA<Success<void>>());
      });

      test('returns ResultFailure on error', () async {
        // Arrange
        when(() => mockAuth.resetPasswordForEmail(
              any(),
              redirectTo: any(named: 'redirectTo'),
            )).thenThrow(Exception('Reset error'));

        // Act
        final result =
            await repository.requestPasswordReset('test@example.com');

        // Assert
        expect(result, isA<ResultFailure<void>>());
      });
    });

    group('isAuthenticated', () {
      test('returns false when no session', () {
        expect(repository.isAuthenticated, false);
      });
    });
  });
}

// Helper to create mock Supabase session
supabase.Session _createMockSession() {
  return supabase.Session(
    accessToken: 'test-access-token',
    tokenType: 'Bearer',
    refreshToken: 'test-refresh-token',
    expiresIn: 3600,
    user: _createMockSupabaseUser(),
  );
}

supabase.User _createMockSupabaseUser() {
  return supabase.User(
    id: 'test-user-id',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00Z',
  );
}
