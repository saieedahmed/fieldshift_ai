/// Data origin categories as required by the scientific data architecture.
enum DataSourceType {
  /// Real NASA Earth observations retrieved from official NASA APIs (e.g., NASA POWER).
  realNasa,

  /// Demonstration or simulated mock data clearly disclosed to the user.
  demoSimulated,

  /// Deterministically calculated or derived indicators (e.g. GDD, water savings).
  derivedIndicator,

  /// Data that could not be retrieved or is unavailable.
  unavailable,
}

/// Status of the NASA Earth observation retrieval.
enum NasaDataStatus { initial, loading, available, cached, missing, error }

/// Generic container representing an individual scientific observation.
class NasaObservation<T> {
  const NasaObservation({
    required this.parameterName,
    required this.parameterCode,
    required this.unit,
    required this.source,
    required this.temporalResolution,
    required this.status,
    this.value,
    this.date,
    this.retrievedAt,
  });

  final String parameterName;
  final String parameterCode;
  final String unit;
  final String source;
  final String temporalResolution;
  final NasaDataStatus status;
  final T? value;
  final DateTime? date;
  final DateTime? retrievedAt;

  bool get isAvailable => value != null && status == NasaDataStatus.available;
}

/// A single day of real meteorological observations from NASA POWER.
class NasaDailyRecord {
  const NasaDailyRecord({
    required this.date,
    this.temperature,
    this.tempMax,
    this.tempMin,
    this.precipitation,
    this.humidity,
    this.solarRadiation,
  });

  final DateTime date;
  final double? temperature; // T2M (°C)
  final double? tempMax; // T2M_MAX (°C)
  final double? tempMin; // T2M_MIN (°C)
  final double? precipitation; // PRECTOTCORR (mm/day)
  final double? humidity; // RH2M (%)
  final double? solarRadiation; // ALLSKY_SFC_SW_DWN (MJ/m^2/day)

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'temperature': temperature,
    'tempMax': tempMax,
    'tempMin': tempMin,
    'precipitation': precipitation,
    'humidity': humidity,
    'solarRadiation': solarRadiation,
  };

  factory NasaDailyRecord.fromJson(Map<String, dynamic> json) =>
      NasaDailyRecord(
        date: DateTime.parse(json['date'] as String),
        temperature: (json['temperature'] as num?)?.toDouble(),
        tempMax: (json['tempMax'] as num?)?.toDouble(),
        tempMin: (json['tempMin'] as num?)?.toDouble(),
        precipitation: (json['precipitation'] as num?)?.toDouble(),
        humidity: (json['humidity'] as num?)?.toDouble(),
        solarRadiation: (json['solarRadiation'] as num?)?.toDouble(),
      );
}

/// Aggregated multi-day climate observations for a farm's geographical coordinates.
class NasaDailyClimate {
  const NasaDailyClimate({
    required this.status,
    this.dailyRecords = const [],
    this.temperatureHistory = const [],
    this.precipitationHistory = const [],
    this.dates = const [],
    this.latestTemperature,
    this.latestTempMax,
    this.latestTempMin,
    this.latestHumidity,
    this.latestPrecipitation,
    this.latestSolarRadiation,
    this.retrievedAt,
    this.startDate,
    this.endDate,
    this.dataSource = 'NASA POWER (GEOS-IT / MERRA-2)',
    this.temporalResolution = 'Daily',
    this.spatialResolution = '~0.5° × 0.625° (~50 km)',
    this.isFromCache = false,
    this.errorMessage,
    this.uncertaintyNotice =
        'Gridded atmospheric model reanalysis, not an on-farm sensor measurement.',
  });

  final NasaDataStatus status;
  final List<NasaDailyRecord> dailyRecords;
  final List<double> temperatureHistory;
  final List<double> precipitationHistory;
  final List<String> dates;
  final double? latestTemperature;
  final double? latestTempMax;
  final double? latestTempMin;
  final double? latestHumidity;
  final double? latestPrecipitation;
  final double? latestSolarRadiation;
  final DateTime? retrievedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String dataSource;
  final String temporalResolution;
  final String spatialResolution;
  final bool isFromCache;
  final String? errorMessage;
  final String uncertaintyNotice;

  bool get hasValidData =>
      (status == NasaDataStatus.available || status == NasaDataStatus.cached) &&
      latestTemperature != null &&
      temperatureHistory.isNotEmpty;

  /// Calculate 7-day cumulative precipitation in mm
  double get cumulativePrecipitationMm {
    if (precipitationHistory.isEmpty) return 0.0;
    return precipitationHistory.fold(0.0, (sum, val) => sum + val);
  }

  /// Mean temperature across the observed window
  double? get meanTemperature {
    if (temperatureHistory.isEmpty) return null;
    final sum = temperatureHistory.fold(0.0, (s, val) => s + val);
    return sum / temperatureHistory.length;
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'dailyRecords': dailyRecords.map((r) => r.toJson()).toList(),
    'temperatureHistory': temperatureHistory,
    'precipitationHistory': precipitationHistory,
    'dates': dates,
    'latestTemperature': latestTemperature,
    'latestTempMax': latestTempMax,
    'latestTempMin': latestTempMin,
    'latestHumidity': latestHumidity,
    'latestPrecipitation': latestPrecipitation,
    'latestSolarRadiation': latestSolarRadiation,
    'retrievedAt': retrievedAt?.toIso8601String(),
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'dataSource': dataSource,
    'temporalResolution': temporalResolution,
    'spatialResolution': spatialResolution,
    'isFromCache': isFromCache,
    'errorMessage': errorMessage,
    'uncertaintyNotice': uncertaintyNotice,
  };

  factory NasaDailyClimate.fromJson(
    Map<String, dynamic> json,
  ) => NasaDailyClimate(
    status: NasaDataStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => NasaDataStatus.cached,
    ),
    dailyRecords:
        (json['dailyRecords'] as List<dynamic>?)
            ?.map((r) => NasaDailyRecord.fromJson(r as Map<String, dynamic>))
            .toList() ??
        const [],
    temperatureHistory:
        (json['temperatureHistory'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    precipitationHistory:
        (json['precipitationHistory'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    dates:
        (json['dates'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [],
    latestTemperature: (json['latestTemperature'] as num?)?.toDouble(),
    latestTempMax: (json['latestTempMax'] as num?)?.toDouble(),
    latestTempMin: (json['latestTempMin'] as num?)?.toDouble(),
    latestHumidity: (json['latestHumidity'] as num?)?.toDouble(),
    latestPrecipitation: (json['latestPrecipitation'] as num?)?.toDouble(),
    latestSolarRadiation: (json['latestSolarRadiation'] as num?)?.toDouble(),
    retrievedAt: json['retrievedAt'] != null
        ? DateTime.tryParse(json['retrievedAt'] as String)
        : null,
    startDate: json['startDate'] != null
        ? DateTime.tryParse(json['startDate'] as String)
        : null,
    endDate: json['endDate'] != null
        ? DateTime.tryParse(json['endDate'] as String)
        : null,
    dataSource:
        json['dataSource'] as String? ?? 'NASA POWER (GEOS-IT / MERRA-2)',
    temporalResolution: json['temporalResolution'] as String? ?? 'Daily',
    spatialResolution:
        json['spatialResolution'] as String? ?? '~0.5° × 0.625° (~50 km)',
    isFromCache: json['isFromCache'] as bool? ?? true,
    errorMessage: json['errorMessage'] as String?,
    uncertaintyNotice:
        json['uncertaintyNotice'] as String? ??
        'Gridded atmospheric model reanalysis, not an on-farm sensor measurement.',
  );

  static NasaDailyClimate empty([
    NasaDataStatus status = NasaDataStatus.initial,
    String? message,
  ]) => NasaDailyClimate(status: status, errorMessage: message);
}
