import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_auth_state.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import 'database_provider.dart';

/// Provider for Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final database = ref.watch(databaseProvider);
  return AuthRepositoryImpl(client, database: database);
});

/// Provider for current auth state.
final authStateProvider = StreamProvider<AppAuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Provider for current user (null if not authenticated).
final currentUserProvider = FutureProvider<domain.User?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Provider for checking if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.isAuthenticated;
});

/// Provider for checking if current user is admin.
final isAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.maybeWhen(
      authenticated: (user) => user.isAdmin,
      orElse: () => false,
    ),
    orElse: () => false,
  );
});

/// Provider for current user's role.
final currentUserRoleProvider = Provider<domain.UserRole?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.maybeWhen(
      authenticated: (user) => user.role,
      orElse: () => null,
    ),
    orElse: () => null,
  );
});

/// Notifier for login actions.
class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  LoginNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _repository.signIn(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        // Set Sentry user context for crash reporting
        Sentry.configureScope((scope) {
          scope.setUser(SentryUser(
            id: user.id,
            email: user.email,
          ));
        });
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.signOut();
    // Clear Sentry user context
    Sentry.configureScope((scope) => scope.setUser(null));
    state = const AsyncValue.data(null);
  }

  void clearError() {
    state = const AsyncValue.data(null);
  }
}

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginNotifier(repository);
});
