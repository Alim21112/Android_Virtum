import 'package:mobile/models/biomarker_data.dart';

/// Mirrors `BIOMARKER_INFO` and helpers from Web_Virtum `assets/js/virtum.js`.
class BiomarkerMeta {
  const BiomarkerMeta({
    required this.key,
    required this.title,
    required this.unit,
    required this.description,
    required this.tips,
  });

  final String key;
  final String title;
  final String unit;
  final String description;
  final List<String> tips;
}

class BiomarkerCatalog {
  BiomarkerCatalog._();

  static const Map<String, BiomarkerMeta> byKey = {
    'heartRate': BiomarkerMeta(
      key: 'heartRate',
      title: 'Heart Rate',
      unit: 'bpm',
      description:
          'Heart rate shows how hard your cardiovascular system is working at this moment.',
      tips: [
        'Normal resting range for many adults is roughly 60-100 bpm.',
        'Very high or very low values should be rechecked with a proper measurement.',
      ],
    ),
    'steps': BiomarkerMeta(
      key: 'steps',
      title: 'Steps',
      unit: 'steps',
      description: 'Daily steps reflect your overall physical activity and movement volume.',
      tips: [
        'Build up gradually to avoid overtraining.',
        'Consistency across the week matters more than one perfect day.',
      ],
    ),
    'bloodPressure': BiomarkerMeta(
      key: 'bloodPressure',
      title: 'Blood Pressure',
      unit: 'mmHg',
      description: 'Blood pressure estimates the force your blood applies to vessel walls.',
      tips: [
        'Record measurements at similar times for better comparison.',
        'Stress, caffeine, and activity can temporarily change values.',
      ],
    ),
    'waterIntake': BiomarkerMeta(
      key: 'waterIntake',
      title: 'Water Intake',
      unit: 'L',
      description: 'Hydration supports focus, temperature regulation, and normal metabolic function.',
      tips: [
        'Spread intake through the day instead of drinking all at once.',
        'Higher activity and heat usually increase hydration needs.',
      ],
    ),
    'weight': BiomarkerMeta(
      key: 'weight',
      title: 'Weight',
      unit: 'kg',
      description: 'Weight trend gives context about energy balance and fluid shifts over time.',
      tips: [
        'Track trends weekly, not just single-day fluctuations.',
        'Use the same scale/time conditions for cleaner comparisons.',
      ],
    ),
    'calorieIntake': BiomarkerMeta(
      key: 'calorieIntake',
      title: 'Calorie Intake',
      unit: 'kcal',
      description: 'Calorie intake indicates daily energy consumption from nutrition.',
      tips: [
        'A stable routine helps interpret intake vs activity.',
        'Quality of calories is as important as total amount.',
      ],
    ),
    'oxygenSaturation': BiomarkerMeta(
      key: 'oxygenSaturation',
      title: 'Oxygen Saturation',
      unit: '%',
      description: 'SpO2 shows how much oxygen is carried by your blood.',
      tips: [
        'Values are usually highest when breathing is calm and regular.',
        'If values are repeatedly low, consider a medical-grade check.',
      ],
    ),
    'activityScore': BiomarkerMeta(
      key: 'activityScore',
      title: 'Activity Score',
      unit: '/100',
      description:
          'A simplified index combining steps and heart rate context for daily activity quality.',
      tips: [
        'Use this score as a trend signal, not a diagnosis.',
        'Aim for consistency and gradual improvement across the week.',
      ],
    ),
  };

  static BiomarkerMeta? metaFor(String key) => byKey[key];

  static String formatValue(String key, Object? value) {
    if (key == 'bloodPressure') return '${value ?? '120/80'}';
    final n = _toNum(value, 0);
    if (key == 'waterIntake' || key == 'weight') return n.toStringAsFixed(1);
    if (key == 'activityScore' || key == 'oxygenSaturation') return n.round().toString();
    return n.round().toString();
  }

  static double _toNum(Object? v, double fallback) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static String rangeText(String key) {
    const ranges = {
      'heartRate': 'Range: 60-100 bpm (resting)',
      'steps': 'Goal: 7k-10k daily',
      'bloodPressure': 'Target: around 120/80 mmHg',
      'waterIntake': 'Goal: around 2.5L daily',
      'weight': 'Focus on weekly trend',
      'calorieIntake': 'Personalized by profile',
      'oxygenSaturation': 'Range: 95-100%',
      'activityScore': 'Target: 70+',
    };
    return ranges[key] ?? 'Track trend over time';
  }

  static String statusLabel(String key, Object? value) {
    final n = _toNum(value, 0);
    switch (key) {
      case 'heartRate':
        return n < 55 || n > 105 ? 'Watch' : 'Good';
      case 'steps':
        return n >= 8000 ? 'Great' : n >= 5000 ? 'Good' : 'Low';
      case 'waterIntake':
        return n >= 2.5 ? 'Goal hit' : n >= 1.5 ? 'In progress' : 'Low';
      case 'oxygenSaturation':
        return n >= 95 ? 'Good' : 'Watch';
      case 'activityScore':
        return n >= 75 ? 'Great' : n >= 55 ? 'Good' : 'Low';
      default:
        return 'Track';
    }
  }

  /// Web `getMetricTrend` → arrow for dashboard cards.
  static String trendArrow(String key, List<BiomarkerHistoryRow> history) {
    if (history.length < 2) return '→';
    double? extract(BiomarkerHistoryRow row) {
      final d = row.data;
      switch (key) {
        case 'heartRate':
          return d.heartRate.toDouble();
        case 'steps':
          return d.steps.toDouble();
        case 'waterIntake':
          return d.waterIntake;
        case 'weight':
          return d.weight;
        case 'calorieIntake':
          return d.calorieIntake.toDouble();
        case 'activityScore':
          return calculateActivityScore(d.steps, d.heartRate).toDouble();
        case 'oxygenSaturation':
          return null;
        case 'bloodPressure':
          final parts = d.bloodPressure.split('/');
          return double.tryParse(parts.first.trim());
        default:
          return null;
      }
    }

    final curr = extract(history[0]);
    final prev = extract(history[1]);
    if (curr == null || prev == null) return '→';
    final diff = curr - prev;
    if (diff.abs() < 0.1) return '→';
    return diff > 0 ? '↑' : '↓';
  }

  static int calculateActivityScore(int steps, int heartRate) {
    final s = (steps / 10000 * 70).clamp(0, 100);
    final hrScore = (heartRate >= 55 && heartRate <= 110) ? 30.0 : 18.0;
    return (s + hrScore).round().clamp(0, 100);
  }

  /// Web `getBiomarkerTrend` simplified for numeric series.
  static String trendFromBiomarkerHistory(String metricKey, List<BiomarkerHistoryRow> history) {
    final maps = history.map((h) => {'data': h.data.toJson()}).toList();
    return trendFromHistory(metricKey, maps);
  }

  static String trendFromHistory(String metricKey, List<Map<String, dynamic>> historyRows) {
    if (historyRows.length < 2) {
      return 'Not enough history yet. Save more records to see trend insights.';
    }
    final sample = historyRows
        .take(7)
        .map((row) => _extractNumeric(metricKey, row))
        .whereType<double>()
        .toList();
    if (sample.length < 2) {
      return 'Trend is available after more numeric records are collected.';
    }
    final first = sample.last;
    final last = sample.first;
    final delta = ((last - first) * 10).round() / 10;
    if (delta == 0) return 'Stable over recent records.';
    return delta > 0
        ? 'Increasing by $delta over recent records.'
        : 'Decreasing by ${delta.abs()} over recent records.';
  }

  static double? _extractNumeric(String key, Map<String, dynamic> row) {
    final data = row['data'];
    if (data is! Map<String, dynamic>) return null;
    if (key == 'activityScore') {
      final steps = (data['steps'] as num?)?.toInt() ?? 0;
      final hr = (data['heartRate'] as num?)?.toInt() ?? 70;
      return calculateActivityScore(steps, hr).toDouble();
    }
    if (key == 'oxygenSaturation') {
      final v = data['oxygenSaturation'] ?? data['o2'] ?? data['oxygen'];
      if (v is num) return v.toDouble();
      return null;
    }
    final v = data[key];
    if (key == 'bloodPressure' && v is String) {
      final parts = v.split('/');
      final s = double.tryParse(parts.first.trim());
      return s;
    }
    if (v is num) return v.toDouble();
    return null;
  }
}

/// Dashboard metric card definition (same order as web `metricCards`).
const List<MetricCardDef> kDashboardMetricCards = [
  MetricCardDef('heartRate', 'Heart Rate', 'bpm'),
  MetricCardDef('steps', 'Steps Today', 'steps'),
  MetricCardDef('bloodPressure', 'Blood Pressure', 'mmHg'),
  MetricCardDef('waterIntake', 'Water Intake', 'L'),
  MetricCardDef('weight', 'Weight', 'kg'),
  MetricCardDef('calorieIntake', 'Calories', 'kcal'),
  MetricCardDef('oxygenSaturation', 'Oxygen (SpO2)', '%'),
  MetricCardDef('activityScore', 'Activity Score', '/100'),
];

class MetricCardDef {
  const MetricCardDef(this.key, this.label, this.unit);
  final String key;
  final String label;
  final String unit;
}
