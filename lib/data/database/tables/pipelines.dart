import 'package:drift/drift.dart';

import 'customers.dart';
import 'users.dart';

/// Pipelines table - sales opportunities.
class Pipelines extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // Auto-generated
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get stageId => text()();
  TextColumn get statusId => text()();
  TextColumn get cobId => text()(); // Class of Business
  TextColumn get lobId => text()(); // Line of Business
  TextColumn get leadSourceId => text()();
  TextColumn get brokerId => text().nullable()(); // If source=BROKER
  TextColumn get brokerPicId => text().nullable()(); // Broker PIC (key_person)
  TextColumn get customerContactId => text().nullable()(); // Customer contact (key_person)
  RealColumn get tsi => real().nullable()(); // Total Sum Insured
  RealColumn get potentialPremium => real()();
  RealColumn get finalPremium => real().nullable()(); // When won
  RealColumn get weightedValue => real().nullable()(); // potential × probability
  DateTimeColumn get expectedCloseDate => dateTime().nullable()();
  TextColumn get policyNumber => text().nullable()(); // When won
  TextColumn get declineReason => text().nullable()(); // When lost
  TextColumn get notes => text().nullable()();
  BoolColumn get isTender => boolean().withDefault(const Constant(false))();
  TextColumn get referredByUserId => text().nullable().references(Users, #id)(); // Referrer for scoring
  TextColumn get referralId => text().nullable()(); // FK → pipeline_referrals
  TextColumn get assignedRmId => text().references(Users, #id)();
  TextColumn get createdBy => text().references(Users, #id)();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pipeline referrals - RM-to-RM referral handshake with manager approval.
/// Supports both BM and ROH approval based on receiver's organizational position.
/// Note: This is an online-only operation - customer transfers require network.
class PipelineReferrals extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // REF-YYYYMMDD-XXX

  // Customer Info
  TextColumn get customerId => text().references(Customers, #id)();

  // Parties Involved
  TextColumn get referrerRmId => text().references(Users, #id)();
  TextColumn get receiverRmId => text().references(Users, #id)();

  // Branch IDs (nullable for kanwil-level RMs)
  TextColumn get referrerBranchId => text().nullable()();
  TextColumn get receiverBranchId => text().nullable()();

  // Regional Office IDs (for ROH fallback approval)
  TextColumn get referrerRegionalOfficeId => text().nullable()();
  TextColumn get receiverRegionalOfficeId => text().nullable()();

  // Approver type: BM or ROH (determined at creation based on receiver's hierarchy)
  TextColumn get approverType => text().withDefault(const Constant('BM'))();

  // Referral Details
  TextColumn get reason => text()();
  TextColumn get notes => text().nullable()();

  // Status Tracking
  TextColumn get status => text().withDefault(const Constant('PENDING_RECEIVER'))();

  // Receiver Response
  DateTimeColumn get receiverAcceptedAt => dateTime().nullable()();
  DateTimeColumn get receiverRejectedAt => dateTime().nullable()();
  TextColumn get receiverRejectReason => text().nullable()();
  TextColumn get receiverNotes => text().nullable()();

  // Manager Approval (BM or ROH based on approverType)
  DateTimeColumn get bmApprovedAt => dateTime().nullable()();
  TextColumn get bmApprovedBy => text().nullable().references(Users, #id)();
  DateTimeColumn get bmRejectedAt => dateTime().nullable()();
  TextColumn get bmRejectReason => text().nullable()();
  TextColumn get bmNotes => text().nullable()();

  // Result
  BoolColumn get bonusCalculated => boolean().withDefault(const Constant(false))();
  RealColumn get bonusAmount => real().nullable()();

  // Timestamps & Sync
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelReason => text().nullable()();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
