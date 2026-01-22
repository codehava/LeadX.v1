import 'package:freezed_annotation/freezed_annotation.dart';

part 'broker.freezed.dart';
part 'broker.g.dart';

/// Broker domain entity for insurance intermediaries.
@freezed
class Broker with _$Broker {
  const factory Broker({
    required String id,
    required String code,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? licenseNumber,
    String? address,
    String? provinceId,
    String? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    double? commissionRate,
    String? imageUrl,
    String? notes,
    @Default(true) bool isActive,
    @Default(false) bool isPendingSync,
    DateTime? deletedAt,
    // Lookup fields (populated from joined data)
    String? provinceName,
    String? cityName,
  }) = _Broker;

  const Broker._();

  factory Broker.fromJson(Map<String, dynamic> json) => _$BrokerFromJson(json);

  /// Check if broker needs to be synced.
  bool get needsSync => isPendingSync;

  /// Get display name.
  String get displayName => name.isNotEmpty ? name : code;

  /// Check if broker has location data.
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if broker is soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Get formatted commission rate.
  String get formattedCommissionRate {
    if (commissionRate == null) return '-';
    return '${commissionRate!.toStringAsFixed(1)}%';
  }
}

/// Broker aggregate with additional details.
@freezed
class BrokerWithDetails with _$BrokerWithDetails {
  const factory BrokerWithDetails({
    required Broker broker,
    @Default(0) int keyPersonsCount,
    @Default(0) int pipelineCount,
  }) = _BrokerWithDetails;

  const BrokerWithDetails._();

  factory BrokerWithDetails.fromJson(Map<String, dynamic> json) =>
      _$BrokerWithDetailsFromJson(json);
}
