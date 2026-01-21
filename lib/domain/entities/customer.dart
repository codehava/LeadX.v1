import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// Represents the status of a customer.
enum CustomerStatus { active, inactive, deleted }

/// Customer domain entity representing a business customer.
@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String code,
    required String name,
    required String address,
    required String provinceId,
    required String cityId,
    required String companyTypeId,
    required String ownershipTypeId,
    required String industryId,
    required String assignedRmId,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    String? imageUrl,
    String? notes,
    @Default(true) bool isActive,
    @Default(false) bool isPendingSync,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    // Lookup fields (populated from joined data)
    String? provinceName,
    String? cityName,
    String? companyTypeName,
    String? ownershipTypeName,
    String? industryName,
    String? assignedRmName,
  }) = _Customer;

  const Customer._();

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  /// Get status based on flags.
  CustomerStatus get status {
    if (deletedAt != null) return CustomerStatus.deleted;
    if (!isActive) return CustomerStatus.inactive;
    return CustomerStatus.active;
  }

  /// Check if customer needs to be synced.
  bool get needsSync => isPendingSync;

  /// Get display name (fallback to code if name is empty).
  String get displayName => name.isNotEmpty ? name : code;

  /// Get full address string.
  String get fullAddress {
    final parts = <String>[];
    parts.add(address);
    if (cityName != null) parts.add(cityName!);
    if (provinceName != null) parts.add(provinceName!);
    if (postalCode != null) parts.add(postalCode!);
    return parts.join(', ');
  }

  /// Check if customer has location data.
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if customer is soft deleted.
  bool get isDeleted => deletedAt != null;
}

/// Lightweight key person summary for display in customer lists.
@freezed
class KeyPersonSummary with _$KeyPersonSummary {
  const factory KeyPersonSummary({
    required String id,
    required String name,
    String? position,
    String? phone,
    String? email,
    @Default(false) bool isPrimary,
  }) = _KeyPersonSummary;

  factory KeyPersonSummary.fromJson(Map<String, dynamic> json) =>
      _$KeyPersonSummaryFromJson(json);
}

/// Customer aggregate that includes key persons.
@freezed
class CustomerWithKeyPersons with _$CustomerWithKeyPersons {
  const factory CustomerWithKeyPersons({
    required Customer customer,
    required List<KeyPersonSummary> keyPersons,
  }) = _CustomerWithKeyPersons;

  const CustomerWithKeyPersons._();

  factory CustomerWithKeyPersons.fromJson(Map<String, dynamic> json) =>
      _$CustomerWithKeyPersonsFromJson(json);

  /// Get the primary key person.
  KeyPersonSummary? get primaryKeyPerson =>
      keyPersons.where((kp) => kp.isPrimary).firstOrNull;
}
