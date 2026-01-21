import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_person.freezed.dart';
part 'key_person.g.dart';

/// Represents the owner type of a key person.
enum KeyPersonOwnerType { customer, hvc, broker }

/// Extension for converting string to KeyPersonOwnerType.
extension KeyPersonOwnerTypeExtension on KeyPersonOwnerType {
  String get name {
    switch (this) {
      case KeyPersonOwnerType.customer:
        return 'CUSTOMER';
      case KeyPersonOwnerType.hvc:
        return 'HVC';
      case KeyPersonOwnerType.broker:
        return 'BROKER';
    }
  }

  static KeyPersonOwnerType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CUSTOMER':
        return KeyPersonOwnerType.customer;
      case 'HVC':
        return KeyPersonOwnerType.hvc;
      case 'BROKER':
        return KeyPersonOwnerType.broker;
      default:
        throw ArgumentError('Unknown KeyPersonOwnerType: $value');
    }
  }
}

/// Key person domain entity - unified for Customer, HVC, and Broker.
@freezed
class KeyPerson with _$KeyPerson {
  const factory KeyPerson({
    required String id,
    required KeyPersonOwnerType ownerType,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? customerId,
    String? brokerId,
    String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    String? notes,
    @Default(false) bool isPrimary,
    @Default(true) bool isActive,
    @Default(false) bool isPendingSync,
    DateTime? deletedAt,
  }) = _KeyPerson;

  const KeyPerson._();

  factory KeyPerson.fromJson(Map<String, dynamic> json) =>
      _$KeyPersonFromJson(json);

  /// Get owner ID based on owner type.
  String? get ownerId {
    switch (ownerType) {
      case KeyPersonOwnerType.customer:
        return customerId;
      case KeyPersonOwnerType.hvc:
        return hvcId;
      case KeyPersonOwnerType.broker:
        return brokerId;
    }
  }

  /// Check if key person is soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Get display name with position.
  String get displayNameWithPosition {
    if (position != null && position!.isNotEmpty) {
      return '$name ($position)';
    }
    return name;
  }

  /// Check if key person has contact info.
  bool get hasContactInfo =>
      (phone != null && phone!.isNotEmpty) ||
      (email != null && email!.isNotEmpty);

  /// Check if key person needs to be synced.
  bool get needsSync => isPendingSync;
}
