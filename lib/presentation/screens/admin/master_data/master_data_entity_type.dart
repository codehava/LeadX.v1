import 'package:flutter/material.dart';

/// Configuration for master data entity types and their display properties.

enum MasterDataEntityType {
  companyType,
  ownershipType,
  industry,
  cob,
  lob,
  pipelineStage,
  pipelineStatus,
  activityType,
  leadSource,
  declineReason,
  hvcType,
  province,
  city,
  regionalOffice,
  branch,
}

extension MasterDataEntityTypeX on MasterDataEntityType {
  String get tableName {
    switch (this) {
      case MasterDataEntityType.companyType:
        return 'company_types';
      case MasterDataEntityType.ownershipType:
        return 'ownership_types';
      case MasterDataEntityType.industry:
        return 'industries';
      case MasterDataEntityType.cob:
        return 'cobs';
      case MasterDataEntityType.lob:
        return 'lobs';
      case MasterDataEntityType.pipelineStage:
        return 'pipeline_stages';
      case MasterDataEntityType.pipelineStatus:
        return 'pipeline_statuses';
      case MasterDataEntityType.activityType:
        return 'activity_types';
      case MasterDataEntityType.leadSource:
        return 'lead_sources';
      case MasterDataEntityType.declineReason:
        return 'decline_reasons';
      case MasterDataEntityType.hvcType:
        return 'hvc_types';
      case MasterDataEntityType.province:
        return 'provinces';
      case MasterDataEntityType.city:
        return 'cities';
      case MasterDataEntityType.regionalOffice:
        return 'regional_offices';
      case MasterDataEntityType.branch:
        return 'branches';
    }
  }

  String get displayName {
    switch (this) {
      case MasterDataEntityType.companyType:
        return 'Tipe Perusahaan';
      case MasterDataEntityType.ownershipType:
        return 'Tipe Kepemilikan';
      case MasterDataEntityType.industry:
        return 'Industri';
      case MasterDataEntityType.cob:
        return 'Class of Business';
      case MasterDataEntityType.lob:
        return 'Line of Business';
      case MasterDataEntityType.pipelineStage:
        return 'Tahap Pipeline';
      case MasterDataEntityType.pipelineStatus:
        return 'Status Pipeline';
      case MasterDataEntityType.activityType:
        return 'Tipe Aktivitas';
      case MasterDataEntityType.leadSource:
        return 'Sumber Lead';
      case MasterDataEntityType.declineReason:
        return 'Alasan Penolakan';
      case MasterDataEntityType.hvcType:
        return 'Tipe HVC';
      case MasterDataEntityType.province:
        return 'Provinsi';
      case MasterDataEntityType.city:
        return 'Kota';
      case MasterDataEntityType.regionalOffice:
        return 'Kantor Wilayah';
      case MasterDataEntityType.branch:
        return 'Kantor Cabang';
    }
  }

  String get category {
    switch (this) {
      case MasterDataEntityType.companyType:
      case MasterDataEntityType.ownershipType:
      case MasterDataEntityType.industry:
        return 'Perusahaan';
      case MasterDataEntityType.cob:
      case MasterDataEntityType.lob:
        return 'Produk';
      case MasterDataEntityType.pipelineStage:
      case MasterDataEntityType.pipelineStatus:
        return 'Pipeline';
      case MasterDataEntityType.activityType:
      case MasterDataEntityType.leadSource:
      case MasterDataEntityType.declineReason:
        return 'Aktivitas';
      case MasterDataEntityType.hvcType:
        return 'HVC';
      case MasterDataEntityType.province:
      case MasterDataEntityType.city:
        return 'Geografi';
      case MasterDataEntityType.regionalOffice:
      case MasterDataEntityType.branch:
        return 'Organisasi';
    }
  }

  IconData get icon {
    switch (this) {
      case MasterDataEntityType.companyType:
        return Icons.business;
      case MasterDataEntityType.ownershipType:
        return Icons.people;
      case MasterDataEntityType.industry:
        return Icons.factory;
      case MasterDataEntityType.cob:
        return Icons.category;
      case MasterDataEntityType.lob:
        return Icons.list;
      case MasterDataEntityType.pipelineStage:
        return Icons.timeline;
      case MasterDataEntityType.pipelineStatus:
        return Icons.check_circle;
      case MasterDataEntityType.activityType:
        return Icons.assignment;
      case MasterDataEntityType.leadSource:
        return Icons.source;
      case MasterDataEntityType.declineReason:
        return Icons.block;
      case MasterDataEntityType.hvcType:
        return Icons.star;
      case MasterDataEntityType.province:
        return Icons.map;
      case MasterDataEntityType.city:
        return Icons.location_city;
      case MasterDataEntityType.regionalOffice:
        return Icons.domain;
      case MasterDataEntityType.branch:
        return Icons.store;
    }
  }
}

/// Master data categories for grouped display
enum MasterDataCategory {
  perusahaan,
  produk,
  pipeline,
  aktivitas,
  hvc,
  geografi,
  organisasi,
}

extension MasterDataCategoryX on MasterDataCategory {
  String get displayName {
    switch (this) {
      case MasterDataCategory.perusahaan:
        return 'Perusahaan';
      case MasterDataCategory.produk:
        return 'Produk';
      case MasterDataCategory.pipeline:
        return 'Pipeline';
      case MasterDataCategory.aktivitas:
        return 'Aktivitas';
      case MasterDataCategory.hvc:
        return 'HVC';
      case MasterDataCategory.geografi:
        return 'Geografi';
      case MasterDataCategory.organisasi:
        return 'Organisasi';
    }
  }

  List<MasterDataEntityType> get entityTypes {
    switch (this) {
      case MasterDataCategory.perusahaan:
        return [
          MasterDataEntityType.companyType,
          MasterDataEntityType.ownershipType,
          MasterDataEntityType.industry,
        ];
      case MasterDataCategory.produk:
        return [
          MasterDataEntityType.cob,
          MasterDataEntityType.lob,
        ];
      case MasterDataCategory.pipeline:
        return [
          MasterDataEntityType.pipelineStage,
          MasterDataEntityType.pipelineStatus,
        ];
      case MasterDataCategory.aktivitas:
        return [
          MasterDataEntityType.activityType,
          MasterDataEntityType.leadSource,
          MasterDataEntityType.declineReason,
        ];
      case MasterDataCategory.hvc:
        return [
          MasterDataEntityType.hvcType,
        ];
      case MasterDataCategory.geografi:
        return [
          MasterDataEntityType.province,
          MasterDataEntityType.city,
        ];
      case MasterDataCategory.organisasi:
        return [
          MasterDataEntityType.regionalOffice,
          MasterDataEntityType.branch,
        ];
    }
  }
}
