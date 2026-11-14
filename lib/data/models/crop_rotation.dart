/// Agricultural crop rotation strategy comparison model for decision-support.
class CropRotationStrategy {
  const CropRotationStrategy({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.sequenceCropsKeys,
    required this.seasonDurationMonths,
    required this.waterRequirementFactor,
    required this.estimatedWaterSavingsPercent,
    required this.estimatedNitrogenImpactKgPerHa,
    required this.heatToleranceIndex,
    required this.pestInterruptionKey,
    required this.soilCoverErosionKey,
    required this.potentialBenefitKeys,
    required this.potentialRiskKeys,
    required this.supportingEvidenceKey,
    required this.missingInfoKey,
    required this.confidenceLevelKey,
    required this.assumptionsKey,
    this.isCurrentPractice = false,
  });

  /// Unique strategy identifier
  final String id;

  /// Localization key for strategy name
  final String nameKey;

  /// Localization key for strategy description
  final String descriptionKey;

  /// List of crop localization keys in rotation sequence (e.g. ['cropWheat', 'cropFabaBean'])
  final List<String> sequenceCropsKeys;

  /// Total duration in months for one cycle
  final int seasonDurationMonths;

  /// Water demand factor relative to baseline (1.0 = baseline, < 1.0 = water savings)
  final double waterRequirementFactor;

  /// Deterministically estimated water savings %
  final int estimatedWaterSavingsPercent;

  /// Net biological nitrogen contribution or depletion (kg N / hectare)
  final int estimatedNitrogenImpactKgPerHa;

  /// Heat and climate resilience score (0.0 to 1.0)
  final double heatToleranceIndex;

  /// Key describing pathogen / pest cycle breaking effect
  final String pestInterruptionKey;

  /// Key describing continuous soil vegetative cover & wind/water erosion protection
  final String soilCoverErosionKey;

  /// Keys listing potential agronomic and economic benefits
  final List<String> potentialBenefitKeys;

  /// Keys listing potential agronomic risks or market bottlenecks
  final List<String> potentialRiskKeys;

  /// Key describing scientific evidence (e.g. peer-reviewed agronomy / FAO)
  final String supportingEvidenceKey;

  /// Key describing critical missing farm-level information needed for validation
  final String missingInfoKey;

  /// Key describing confidence tier (e.g. High, Medium-High)
  final String confidenceLevelKey;

  /// Key describing underlying assumptions
  final String assumptionsKey;

  /// Whether this strategy represents the farmer's current baseline
  final bool isCurrentPractice;
}

