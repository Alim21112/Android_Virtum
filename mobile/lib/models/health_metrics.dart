import 'package:mobile/models/biomarker_data.dart';

class HealthMetrics {
  const HealthMetrics({
    required this.heartRate,
    required this.bloodPressure,
    required this.steps,
    required this.waterIntakeLiters,
    required this.oxygen,
    required this.temperature,
    required this.insight,
  });

  final int heartRate;
  final String bloodPressure;
  final int steps;
  final double waterIntakeLiters;
  final int oxygen;
  final double temperature;
  final String insight;

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 74,
      bloodPressure: json['bloodPressure'] as String? ?? '118/76',
      steps: (json['steps'] as num?)?.toInt() ?? 6500,
      waterIntakeLiters: (json['waterIntakeLiters'] as num?)?.toDouble() ??
          (json['waterIntake'] as num?)?.toDouble() ??
          1.8,
      oxygen: (json['oxygen'] as num?)?.toInt() ?? 97,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 36.6,
      insight: json['insight'] as String? ??
          'Hydration is slightly low. Aim for 2.5L today.',
    );
  }

  factory HealthMetrics.fromBiomarker(BiomarkerData d, {String insight = ''}) {
    return HealthMetrics(
      heartRate: d.heartRate,
      bloodPressure: d.bloodPressure,
      steps: d.steps,
      waterIntakeLiters: d.waterIntake,
      oxygen: 0,
      temperature: 0,
      insight: insight,
    );
  }
}
