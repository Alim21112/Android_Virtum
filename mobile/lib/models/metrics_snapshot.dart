import 'package:mobile/models/biomarker_catalog.dart';
import 'package:mobile/models/biomarker_data.dart';

/// Aggregated snapshot like web `latestMetricsSnapshot`.
class MetricsSnapshot {
  const MetricsSnapshot({
    required this.heartRate,
    required this.steps,
    required this.bloodPressure,
    required this.waterIntake,
    required this.weight,
    required this.calorieIntake,
    required this.oxygenSaturation,
    required this.activityScore,
    required this.sleepHours,
  });

  final int heartRate;
  final int steps;
  final String bloodPressure;
  final double waterIntake;
  final double weight;
  final int calorieIntake;
  final int oxygenSaturation;
  final int activityScore;
  final double sleepHours;

  Object? valueForKey(String key) {
    switch (key) {
      case 'heartRate':
        return heartRate;
      case 'steps':
        return steps;
      case 'bloodPressure':
        return bloodPressure;
      case 'waterIntake':
        return waterIntake;
      case 'weight':
        return weight;
      case 'calorieIntake':
        return calorieIntake;
      case 'oxygenSaturation':
        return oxygenSaturation;
      case 'activityScore':
        return activityScore;
      default:
        return null;
    }
  }

  /// [waterIntake] comes only from the latest stored biomarker row (server truth via `/water` / `/custom`).
  static MetricsSnapshot fromLatest({
    required BiomarkerData latest,
    required Map<String, dynamic>? recommend,
  }) {
    final pv = recommend?['providerView'];
    final o2 = pv is Map<String, dynamic> ? (pv['o2'] as num?)?.toInt() ?? 98 : 98;
    final hr = latest.heartRate;
    final st = latest.steps;
    final score = BiomarkerCatalog.calculateActivityScore(st, hr);
    final water = latest.waterIntake;

    return MetricsSnapshot(
      heartRate: hr,
      steps: st,
      bloodPressure: latest.bloodPressure,
      waterIntake: water,
      weight: latest.weight,
      calorieIntake: latest.calorieIntake,
      oxygenSaturation: o2,
      activityScore: score,
      sleepHours: latest.sleepHours,
    );
  }
}
