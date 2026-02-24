import 'package:freezed_annotation/freezed_annotation.dart';

part 'hvc.freezed.dart';
part 'hvc.g.dart';

/// Relationship type between customer and HVC.
enum HvcRelationshipType {
  holding,
  subsidiary,
  affiliate,
  jv,
  tenant,
  member,
  supplier,
  contractor,
  distributor,
}

/// Extension for HvcRelationshipType string conversions.
extension HvcRelationshipTypeExtension on HvcRelationshipType {
  String get displayName {
    switch (this) {
      case HvcRelationshipType.holding:
        return 'Holding';
      case HvcRelationshipType.subsidiary:
        return 'Subsidiary';
      case HvcRelationshipType.affiliate:
        return 'Affiliate';
      case HvcRelationshipType.jv:
        return 'Joint Venture';
      case HvcRelationshipType.tenant:
        return 'Tenant';
      case HvcRelationshipType.member:
        return 'Member';
      case HvcRelationshipType.supplier:
        return 'Supplier';
      case HvcRelationshipType.contractor:
        return 'Contractor';
      case HvcRelationshipType.distributor:
        return 'Distributor';
    }
  }

  String get code => name.toUpperCase();

  static HvcRelationshipType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HOLDING':
        return HvcRelationshipType.holding;
      case 'SUBSIDIARY':
        return HvcRelationshipType.subsidiary;
      case 'AFFILIATE':
        return HvcRelationshipType.affiliate;
      case 'JV':
        return HvcRelationshipType.jv;
      case 'TENANT':
        return HvcRelationshipType.tenant;
      case 'MEMBER':
        return HvcRelationshipType.member;
      case 'SUPPLIER':
        return HvcRelationshipType.supplier;
      case 'CONTRACTOR':
        return HvcRelationshipType.contractor;
      case 'DISTRIBUTOR':
        return HvcRelationshipType.distributor;
      default:
        return HvcRelationshipType.affiliate;
    }
  }
}

/// HVC Type master data entity.
@freezed
class HvcType with _$HvcType {
  const factory HvcType({
    required String id,
    required String code,
    required String name,
    String? description,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _HvcType;

  factory HvcType.fromJson(Map<String, dynamic> json) => _$HvcTypeFromJson(json);
}

/// High Value Customer domain entity.
@freezed
class Hvc with _$Hvc {
  const factory Hvc({
    required String id,
    required String code,
    required String name,
    required String typeId,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    @Default(500) int radiusMeters,
    double? potentialValue,
    String? imageUrl,
    @Default(true) bool isActive,
    @Default(false) bool isPendingSync,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    // Lookup fields (populated from joined data)
    String? typeName,
  }) = _Hvc;

  const Hvc._();

  factory Hvc.fromJson(Map<String, dynamic> json) => _$HvcFromJson(json);

  /// Check if HVC needs to be synced.
  bool get needsSync => isPendingSync;

  /// Get display name.
  String get displayName => name.isNotEmpty ? name : code;

  /// Check if HVC has location data.
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if HVC is soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Get formatted potential value.
  String get formattedPotentialValue {
    if (potentialValue == null) return '-';
    return 'Rp ${potentialValue!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }
}

/// Customer-HVC Link entity for many-to-many relationship.
@freezed
class CustomerHvcLink with _$CustomerHvcLink {
  const factory CustomerHvcLink({
    required String id,
    required String customerId,
    required String hvcId,
    required String relationshipType,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
    @Default(false) bool isPendingSync,
    DateTime? deletedAt,
    // Lookup fields
    String? customerName,
    String? customerCode,
    String? hvcName,
    String? hvcCode,
  }) = _CustomerHvcLink;

  const CustomerHvcLink._();

  factory CustomerHvcLink.fromJson(Map<String, dynamic> json) =>
      _$CustomerHvcLinkFromJson(json);

  /// Get relationship type as enum.
  HvcRelationshipType get relationshipTypeEnum =>
      HvcRelationshipTypeExtension.fromString(relationshipType);

  /// Get display relationship type.
  String get relationshipDisplayName => relationshipTypeEnum.displayName;

  /// Check if link is soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Check if link needs sync.
  bool get needsSync => isPendingSync;
}

/// HVC aggregate with additional details.
@freezed
class HvcWithDetails with _$HvcWithDetails {
  const factory HvcWithDetails({
    required Hvc hvc,
    @Default([]) List<CustomerHvcLink> linkedCustomers,
    @Default(0) int keyPersonsCount,
  }) = _HvcWithDetails;

  const HvcWithDetails._();

  factory HvcWithDetails.fromJson(Map<String, dynamic> json) =>
      _$HvcWithDetailsFromJson(json);

  /// Get linked customers count.
  int get linkedCustomersCount => linkedCustomers.length;
}
