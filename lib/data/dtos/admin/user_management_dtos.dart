import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/user.dart';

part 'user_management_dtos.freezed.dart';
part 'user_management_dtos.g.dart';

/// DTO for creating a new user.
///
/// Used by admin to create users with auto-generated temporary passwords.
@freezed
class UserCreateDto with _$UserCreateDto {
  const factory UserCreateDto({
    required String email,
    required String name,
    required String nip,
    required UserRole role,
    String? phone,
    String? parentId, // Supervisor user ID
    String? branchId,
    String? regionalOfficeId,
  }) = _UserCreateDto;

  factory UserCreateDto.fromJson(Map<String, dynamic> json) =>
      _$UserCreateDtoFromJson(json);
}

/// DTO for updating an existing user.
///
/// All fields are optional - only provided fields will be updated.
@freezed
class UserUpdateDto with _$UserUpdateDto {
  const factory UserUpdateDto({
    String? name,
    String? nip,
    String? phone,
    UserRole? role,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
  }) = _UserUpdateDto;

  factory UserUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateDtoFromJson(json);
}

/// Result of user creation including temporary password.
@freezed
class UserCreateResult with _$UserCreateResult {
  const factory UserCreateResult({
    required User user,
    required String temporaryPassword,
  }) = _UserCreateResult;

  factory UserCreateResult.fromJson(Map<String, dynamic> json) =>
      _$UserCreateResultFromJson(json);
}
