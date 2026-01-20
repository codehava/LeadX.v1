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

/// Pipeline referrals - RM-to-RM referral handshake with BM approval.
class PipelineReferrals extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // REF-YYYYMMDD-XXX
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get cobId => text()();
  TextColumn get lobId => text()();
  RealColumn get potentialPremium => real()();
  TextColumn get referrerRmId => text().references(Users, #id)();
  TextColumn get receiverRmId => text().references(Users, #id)();
  TextColumn get referrerBranchId => text()();
  TextColumn get receiverBranchId => text()();
  TextColumn get reason => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()(); // See status flow
  DateTimeColumn get referrerApprovedAt => dateTime().nullable()();
  DateTimeColumn get receiverAcceptedAt => dateTime().nullable()();
  DateTimeColumn get receiverRejectedAt => dateTime().nullable()();
  TextColumn get receiverRejectReason => text().nullable()();
  DateTimeColumn get bmApprovedAt => dateTime().nullable()();
  TextColumn get bmApprovedBy => text().nullable().references(Users, #id)();
  DateTimeColumn get bmRejectedAt => dateTime().nullable()();
  TextColumn get bmRejectReason => text().nullable()();
  TextColumn get pipelineId => text().nullable()(); // Created after approval
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
