import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/scoring_entities.dart';
import '../../domain/entities/user.dart';
import 'admin/admin_4dx_providers.dart';
import 'admin_user_providers.dart';
import 'auth_providers.dart';

part 'team_target_providers.g.dart';

// ============================================
// TEAM TARGET PROVIDERS (Manager-facing)
// ============================================

/// Whether the current user can manage team targets (BH/BM/ROH, not admin/RM).
@riverpod
bool canManageTeamTargets(Ref ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;
  if (user == null) return false;
  return user.canManageSubordinates && !user.isAdmin;
}

/// Get subordinates for the current user (manager's direct reports).
@riverpod
Future<List<User>> mySubordinates(Ref ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];
  final subordinates =
      await ref.watch(userSubordinatesProvider(currentUser.id).future);
  return subordinates;
}

/// Get the manager's own targets for a period (for cascade reference).
@riverpod
Future<List<UserTarget>> managerOwnTargets(Ref ref, String periodId) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserTargetsForPeriod(currentUser.id, periodId);
}

/// Notifier for saving subordinate targets (delegates to existing bulk assign).
@riverpod
class TeamTargetAssignment extends _$TeamTargetAssignment {
  @override
  FutureOr<void> build() => null;

  /// Save targets for a specific subordinate.
  Future<bool> saveSubordinateTargets({
    required String userId,
    required String periodId,
    required Map<String, double> measureTargets,
  }) async {
    // Keep alive during the async operation to prevent auto-dispose
    final link = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      // Verify the user is a subordinate of the current user
      final subordinates = await ref.read(mySubordinatesProvider.future);
      final isSubordinate = subordinates.any((s) => s.id == userId);
      if (!isSubordinate) {
        throw Exception('User is not your subordinate');
      }

      final currentUser = await ref.read(currentUserProvider.future);
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);

      await repository.bulkAssignTargets(
        periodId: periodId,
        assignedBy: currentUser?.id ?? '',
        userIds: [userId],
        measureTargets: measureTargets,
      );

      state = const AsyncValue.data(null);

      // Invalidate affected providers after state is set
      ref.invalidate(targetsForPeriodProvider(periodId));
      ref.invalidate(adminUserTargetsProvider(userId, periodId));
      ref.invalidate(managerOwnTargetsProvider(periodId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }

    return !state.hasError;
  }
}
