import '../models/crop_rotation.dart';
import '../models/nasa_observation.dart';

/// Repository providing deterministic agricultural crop rotation strategies
/// and climate-contextualized decision support evaluations.
class CropRotationRepository {
  const CropRotationRepository();

  /// Retrieve the 3 comparative crop rotation strategies for the farm
  List<CropRotationStrategy> getRotationStrategies({
    NasaDailyClimate? nasaClimate,
  }) {
    // Dynamic climate context from real NASA observations
    final hasHighHeat = (nasaClimate?.latestTempMax ?? 0) > 32.0 ||
        (nasaClimate?.meanTemperature ?? 0) > 28.0;
    final hasLowPrecipitation = (nasaClimate?.cumulativePrecipitationMm ?? 10.0) < 5.0;

    return [
      const CropRotationStrategy(
        id: 'strategy_current',
        nameKey: 'rotationCurrentTitle',
        descriptionKey: 'rotationCurrentDesc',
        sequenceCropsKeys: ['cropWheat', 'cropFallow', 'cropMaize'],
        seasonDurationMonths: 12,
        waterRequirementFactor: 1.0,
        estimatedWaterSavingsPercent: 0,
        estimatedNitrogenImpactKgPerHa: -45, // Continuous cereal depletion
        heatToleranceIndex: 0.60,
        pestInterruptionKey: 'pestInterruptionLow',
        soilCoverErosionKey: 'soilCoverErosionHigh',
        potentialBenefitKeys: [
          'benefitFamiliarPractice',
          'benefitEstablishedMarket',
        ],
        potentialRiskKeys: [
          'riskNitrogenDepletion',
          'riskCerealRootRot',
          'riskWaterDeficit',
        ],
        supportingEvidenceKey: 'evidenceCurrentBaseline',
        missingInfoKey: 'missingInfoCurrent',
        confidenceLevelKey: 'confidenceHigh',
        assumptionsKey: 'assumptionsCurrent',
        isCurrentPractice: true,
      ),
      const CropRotationStrategy(
        id: 'strategy_legume',
        nameKey: 'rotationLegumeTitle',
        descriptionKey: 'rotationLegumeDesc',
        sequenceCropsKeys: ['cropWheat', 'cropFabaBean', 'cropCloverCover'],
        seasonDurationMonths: 12,
        waterRequirementFactor: 0.78,
        estimatedWaterSavingsPercent: 22,
        estimatedNitrogenImpactKgPerHa: 80, // Symbiotic Rhizobium N-fixation
        heatToleranceIndex: 0.75,
        pestInterruptionKey: 'pestInterruptionHigh',
        soilCoverErosionKey: 'soilCoverErosionLow',
        potentialBenefitKeys: [
          'benefitNitrogenFixation',
          'benefitPestCycleBreak',
          'benefitSoilStructure',
        ],
        potentialRiskKeys: [
          'riskLegumeAphidVulnerability',
          'riskMarketPriceFluctuation',
        ],
        supportingEvidenceKey: 'evidenceLegumeRotation',
        missingInfoKey: 'missingInfoLegume',
        confidenceLevelKey: 'confidenceHigh',
        assumptionsKey: 'assumptionsLegume',
      ),
      CropRotationStrategy(
        id: 'strategy_climate_resilient',
        nameKey: 'rotationResilientTitle',
        descriptionKey: hasHighHeat || hasLowPrecipitation
            ? 'rotationResilientClimateAlertDesc'
            : 'rotationResilientDesc',
        sequenceCropsKeys: const ['cropWheat', 'cropSorghumMillet', 'cropLentils'],
        seasonDurationMonths: 12,
        waterRequirementFactor: 0.65,
        estimatedWaterSavingsPercent: 35,
        estimatedNitrogenImpactKgPerHa: 35,
        heatToleranceIndex: 0.92,
        pestInterruptionKey: 'pestInterruptionMediumHigh',
        soilCoverErosionKey: 'soilCoverErosionLow',
        potentialBenefitKeys: const [
          'benefitDroughtResilience',
          'benefitDeepRootMoisture',
          'benefitWaterConservation',
        ],
        potentialRiskKeys: const [
          'riskAlternativeGrainDemand',
          'riskHarvestEquipmentSetup',
        ],
        supportingEvidenceKey: 'evidenceClimateResilient',
        missingInfoKey: 'missingInfoResilient',
        confidenceLevelKey: 'confidenceMediumHigh',
        assumptionsKey: 'assumptionsResilient',
      ),
    ];
  }
}

