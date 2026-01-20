import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Domain model for authenticated user.
@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String name,
    String? nip,
    String? phone,
    required UserRole role,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
    String? photoUrl,
    required bool isActive,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Whether user has admin privileges
  bool get isAdmin => role == UserRole.admin || role == UserRole.superadmin;

  /// Whether user is a field role (RM, BH, BM, ROH)
  bool get isFieldRole => [
        UserRole.rm,
        UserRole.bh,
        UserRole.bm,
        UserRole.roh,
      ].contains(role);

  /// Whether user can manage subordinates
  bool get canManageSubordinates =>
      role != UserRole.rm && role != UserRole.admin;

  /// Display name for the user
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  /// Initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

/// User roles matching database enum.
@JsonEnum(alwaysCreate: true)
enum UserRole {
  @JsonValue('SUPERADMIN')
  superadmin,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('ROH')
  roh,
  @JsonValue('BM')
  bm,
  @JsonValue('BH')
  bh,
  @JsonValue('RM')
  rm,
}

/// Extension for role display names
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.roh:
        return 'Regional Office Head';
      case UserRole.bm:
        return 'Branch Manager';
      case UserRole.bh:
        return 'Branch Head';
      case UserRole.rm:
        return 'Relationship Manager';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.superadmin:
        return 'Superadmin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.roh:
        return 'ROH';
      case UserRole.bm:
        return 'BM';
      case UserRole.bh:
        return 'BH';
      case UserRole.rm:
        return 'RM';
    }
  }
}
