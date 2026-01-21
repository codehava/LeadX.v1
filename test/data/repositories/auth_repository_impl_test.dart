import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/core/errors/failures.dart';
import 'package:leadx_crm/data/repositories/auth_repository_impl.dart';
import 'package:leadx_crm/domain/entities/app_auth_state.dart';
import 'package:leadx_crm/domain/entities/user.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

@GenerateMocks([
  supabase.SupabaseClient,
  supabase.GoTrueClient,
  supabase.SupabaseQueryBuilder,
  supabase.PostgrestFilterBuilder,
  supabase.PostgrestTransformBuilder,
])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

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
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    when(mockClient.auth).thenReturn(mockAuth);
    when(mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream<supabase.AuthState>.empty(),
    );

    repository = AuthRepositoryImpl(mockClient);
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

        when(mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => authResponse);

        when(mockClient.from('users')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'test-user-id'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => testUserJson);
        
        // For updating last_login_at
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (user) {
            expect(user.email, 'test@example.com');
            expect(user.name, 'Test User');
            expect(user.role, UserRole.rm);
          },
        );
      });

      test('returns AuthFailure when credentials are invalid', () async {
        // Arrange
        when(mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(supabase.AuthException('Invalid login credentials'));

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Email atau password salah'));
          },
          (user) => fail('Expected Left but got Right'),
        );
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

        when(mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => authResponse);

        when(mockClient.from('users')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'test-user-id'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenAnswer((_) async => inactiveUserJson);
        when(mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, contains('inactive'));
          },
          (user) => fail('Expected Left but got Right'),
        );
        verify(mockAuth.signOut()).called(1);
      });

      test('returns AuthFailure when no session returned', () async {
        // Arrange
        final authResponse = supabase.AuthResponse(session: null);

        when(mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => authResponse);

        // Act
        final result = await repository.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, contains('No session returned'));
          },
          (user) => fail('Expected Left but got Right'),
        );
      });
    });

    group('signOut', () {
      test('returns Right(null) on successful sign out', () async {
        // Arrange
        when(mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isRight(), true);
        verify(mockAuth.signOut()).called(1);
      });

      test('returns AuthFailure when sign out fails', () async {
        // Arrange
        when(mockAuth.signOut()).thenThrow(Exception('Sign out error'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Sign out failed'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('getCurrentUser', () {
      test('returns null when no session exists', () async {
        // Arrange
        when(mockAuth.currentSession).thenReturn(null);

        // Act
        final user = await repository.getCurrentUser();

        // Assert
        expect(user, isNull);
      });

      test('returns User when session exists', () async {
        // Arrange
        final mockSession = _createMockSession();
        when(mockAuth.currentSession).thenReturn(mockSession);

        when(mockClient.from('users')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'test-user-id'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => testUserJson);

        // Act
        final user = await repository.getCurrentUser();

        // Assert
        expect(user, isNotNull);
        expect(user!.email, 'test@example.com');
        expect(user.name, 'Test User');
      });

      test('returns null when fetching user profile fails', () async {
        // Arrange
        final mockSession = _createMockSession();
        when(mockAuth.currentSession).thenReturn(mockSession);

        when(mockClient.from('users')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'test-user-id'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(Exception('Database error'));

        // Act
        final user = await repository.getCurrentUser();

        // Assert
        expect(user, isNull);
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

        when(mockAuth.refreshSession()).thenAnswer((_) async => authResponse);

        when(mockClient.from('users')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'test-user-id'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => testUserJson);

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (session) {
            expect(session.accessToken, 'test-access-token');
            expect(session.user.email, 'test@example.com');
          },
        );
      });

      test('returns AuthFailure when refresh fails', () async {
        // Arrange
        when(mockAuth.refreshSession())
            .thenThrow(Exception('Session refresh error'));

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Session refresh failed'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('returns AuthFailure when session is null', () async {
        // Arrange
        final authResponse = supabase.AuthResponse(session: null);
        when(mockAuth.refreshSession()).thenAnswer((_) async => authResponse);

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('getAuthState', () {
      test('returns unauthenticated when no session', () async {
        // Arrange
        when(mockAuth.currentSession).thenReturn(null);

        // Act
        final state = await repository.getAuthState();

        // Assert
        expect(state, isA<AppAuthStateUnauthenticated>());
      });

      test('returns authenticated when session exists', () async {
        // Arrange
        final mockSession = _createMockSession();
        when(mockAuth.currentSession).thenReturn(mockSession);

        when(mockClient.from('users')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'test-user-id'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => testUserJson);

        // Act
        final state = await repository.getAuthState();

        // Assert
        expect(state, isA<AppAuthStateAuthenticated>());
      });
    });

    group('requestPasswordReset', () {
      test('returns Right(null) on success', () async {
        // Arrange
        when(mockAuth.resetPasswordForEmail(any)).thenAnswer((_) async {});

        // Act
        final result = await repository.requestPasswordReset('test@example.com');

        // Assert
        expect(result.isRight(), true);
        verify(mockAuth.resetPasswordForEmail('test@example.com')).called(1);
      });

      test('returns AuthFailure on error', () async {
        // Arrange
        when(mockAuth.resetPasswordForEmail(any))
            .thenThrow(Exception('Reset error'));

        // Act
        final result = await repository.requestPasswordReset('test@example.com');

        // Assert
        expect(result.isLeft(), true);
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
    expiresAt: DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
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
