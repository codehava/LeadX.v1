import '../../data/database/app_database.dart';
import '../../data/dtos/master_data_dtos.dart';

/// Mappers for converting Drift data classes to DTOs
class MasterDataMappers {
  // ============================================
  // GEOGRAPHY MAPPERS
  // ============================================

  static ProvinceDto provinceToDto(Province province) => ProvinceDto(
        id: province.id,
        code: province.code,
        name: province.name,
        isActive: province.isActive,
      );

  static List<ProvinceDto> provinceListToDto(List<Province> provinces) =>
      provinces.map(provinceToDto).toList();

  static CityDto cityToDto(City city) => CityDto(
        id: city.id,
        code: city.code,
        name: city.name,
        provinceId: city.provinceId,
        isActive: city.isActive,
      );

  static List<CityDto> cityListToDto(List<City> cities) =>
      cities.map(cityToDto).toList();

  // ============================================
  // COMPANY CLASSIFICATION MAPPERS
  // ============================================

  static CompanyTypeDto companyTypeToDto(CompanyType companyType) =>
      CompanyTypeDto(
        id: companyType.id,
        code: companyType.code,
        name: companyType.name,
        sortOrder: companyType.sortOrder,
        isActive: companyType.isActive,
      );

  static List<CompanyTypeDto> companyTypeListToDto(
          List<CompanyType> companyTypes) =>
      companyTypes.map(companyTypeToDto).toList();

  static OwnershipTypeDto ownershipTypeToDto(OwnershipType ownershipType) =>
      OwnershipTypeDto(
        id: ownershipType.id,
        code: ownershipType.code,
        name: ownershipType.name,
        sortOrder: ownershipType.sortOrder,
        isActive: ownershipType.isActive,
      );

  static List<OwnershipTypeDto> ownershipTypeListToDto(
          List<OwnershipType> ownershipTypes) =>
      ownershipTypes.map(ownershipTypeToDto).toList();

  static IndustryDto industryToDto(Industry industry) => IndustryDto(
        id: industry.id,
        code: industry.code,
        name: industry.name,
        sortOrder: industry.sortOrder,
        isActive: industry.isActive,
      );

  static List<IndustryDto> industryListToDto(List<Industry> industries) =>
      industries.map(industryToDto).toList();

  // ============================================
  // PRODUCT CLASSIFICATION MAPPERS
  // ============================================

  static CobDto cobToDto(Cob cob) => CobDto(
        id: cob.id,
        code: cob.code,
        name: cob.name,
        description: cob.description,
        sortOrder: cob.sortOrder,
        isActive: cob.isActive,
      );

  static List<CobDto> cobListToDto(List<Cob> cobs) =>
      cobs.map(cobToDto).toList();

  static LobDto lobToDto(Lob lob) => LobDto(
        id: lob.id,
        cobId: lob.cobId,
        code: lob.code,
        name: lob.name,
        description: lob.description,
        sortOrder: lob.sortOrder,
        isActive: lob.isActive,
      );

  static List<LobDto> lobListToDto(List<Lob> lobs) =>
      lobs.map(lobToDto).toList();

  // ============================================
  // PIPELINE CLASSIFICATION MAPPERS
  // ============================================

  static PipelineStageDto pipelineStageToDto(PipelineStage stage) =>
      PipelineStageDto(
        id: stage.id,
        code: stage.code,
        name: stage.name,
        probability: stage.probability,
        sequence: stage.sequence,
        color: stage.color,
        isFinal: stage.isFinal,
        isWon: stage.isWon,
        isActive: stage.isActive,
        createdAt: stage.createdAt,
        updatedAt: stage.updatedAt,
      );

  static List<PipelineStageDto> pipelineStageListToDto(
          List<PipelineStage> stages) =>
      stages.map(pipelineStageToDto).toList();

  static PipelineStatusDto pipelineStatusToDto(PipelineStatuse status) =>
      PipelineStatusDto(
        id: status.id,
        stageId: status.stageId,
        code: status.code,
        name: status.name,
        description: status.description,
        sequence: status.sequence,
        isDefault: status.isDefault,
        isActive: status.isActive,
        createdAt: status.createdAt,
        updatedAt: status.updatedAt,
      );

  static List<PipelineStatusDto> pipelineStatusListToDto(
          List<PipelineStatuse> statuses) =>
      statuses.map(pipelineStatusToDto).toList();

  // ============================================
  // ACTIVITY CLASSIFICATION MAPPERS
  // ============================================

  static ActivityTypeDto activityTypeToDto(ActivityType activityType) =>
      ActivityTypeDto(
        id: activityType.id,
        code: activityType.code,
        name: activityType.name,
        icon: activityType.icon,
        color: activityType.color,
        requireLocation: activityType.requireLocation,
        requirePhoto: activityType.requirePhoto,
        requireNotes: activityType.requireNotes,
        sortOrder: activityType.sortOrder,
        isActive: activityType.isActive,
      );

  static List<ActivityTypeDto> activityTypeListToDto(
          List<ActivityType> activityTypes) =>
      activityTypes.map(activityTypeToDto).toList();

  static LeadSourceDto leadSourceToDto(LeadSource leadSource) =>
      LeadSourceDto(
        id: leadSource.id,
        code: leadSource.code,
        name: leadSource.name,
        requiresReferrer: leadSource.requiresReferrer,
        requiresBroker: leadSource.requiresBroker,
        isActive: leadSource.isActive,
      );

  static List<LeadSourceDto> leadSourceListToDto(List<LeadSource> leadSources) =>
      leadSources.map(leadSourceToDto).toList();

  static DeclineReasonDto declineReasonToDto(DeclineReason declineReason) =>
      DeclineReasonDto(
        id: declineReason.id,
        code: declineReason.code,
        name: declineReason.name,
        description: declineReason.description,
        sortOrder: declineReason.sortOrder,
        isActive: declineReason.isActive,
      );

  static List<DeclineReasonDto> declineReasonListToDto(
          List<DeclineReason> declineReasons) =>
      declineReasons.map(declineReasonToDto).toList();

  // ============================================
  // HVC MAPPERS
  // ============================================

  static HvcTypeDto hvcTypeToDto(HvcType hvcType) => HvcTypeDto(
        id: hvcType.id,
        code: hvcType.code,
        name: hvcType.name,
        description: hvcType.description,
        sortOrder: hvcType.sortOrder,
        isActive: hvcType.isActive,
      );

  static List<HvcTypeDto> hvcTypeListToDto(List<HvcType> hvcTypes) =>
      hvcTypes.map(hvcTypeToDto).toList();

  // ============================================
  // ORGANIZATION MAPPERS
  // ============================================

  static RegionalOfficeDto regionalOfficeToDto(RegionalOffice regionalOffice) =>
      RegionalOfficeDto(
        id: regionalOffice.id,
        code: regionalOffice.code,
        name: regionalOffice.name,
        description: regionalOffice.description,
        address: regionalOffice.address,
        latitude: regionalOffice.latitude,
        longitude: regionalOffice.longitude,
        phone: regionalOffice.phone,
        isActive: regionalOffice.isActive,
        createdAt: regionalOffice.createdAt,
        updatedAt: regionalOffice.updatedAt,
      );

  static List<RegionalOfficeDto> regionalOfficeListToDto(
          List<RegionalOffice> regionalOffices) =>
      regionalOffices.map(regionalOfficeToDto).toList();

  static BranchDto branchToDto(Branche branch) => BranchDto(
        id: branch.id,
        code: branch.code,
        name: branch.name,
        regionalOfficeId: branch.regionalOfficeId,
        address: branch.address,
        latitude: branch.latitude,
        longitude: branch.longitude,
        phone: branch.phone,
        isActive: branch.isActive,
        createdAt: branch.createdAt,
        updatedAt: branch.updatedAt,
      );

  static List<BranchDto> branchListToDto(List<Branche> branches) =>
      branches.map(branchToDto).toList();
}
