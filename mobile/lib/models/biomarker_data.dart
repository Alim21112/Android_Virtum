/// Parsed `data` object inside biomarker history rows.
class BiomarkerData {
  const BiomarkerData({
    required this.steps,
    required this.heartRate,
    required this.bloodPressure,
    required this.weight,
    required this.calorieIntake,
    required this.waterIntake,
    required this.sleepHours,
  });

  final int steps;
  final int heartRate;
  final String bloodPressure;
  final double weight;
  final int calorieIntake;
  final double waterIntake;
  final double sleepHours;

  factory BiomarkerData.fromJson(Map<String, dynamic> json) {
    return BiomarkerData(
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
      bloodPressure: json['bloodPressure'] as String? ?? '120/80',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      calorieIntake: (json['calorieIntake'] as num?)?.toInt() ?? 0,
      waterIntake: (json['waterIntake'] as num?)?.toDouble() ?? 0,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'heartRate': heartRate,
        'bloodPressure': bloodPressure,
        'weight': weight,
        'calorieIntake': calorieIntake,
        'waterIntake': waterIntake,
        'sleepHours': sleepHours,
      };
}

class BiomarkerHistoryRow {
  const BiomarkerHistoryRow({
    required this.data,
    required this.flagged,
  });

  final BiomarkerData data;
  final bool flagged;

  factory BiomarkerHistoryRow.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final map = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return BiomarkerHistoryRow(
      data: BiomarkerData.fromJson(map),
      flagged: json['flagged'] == true,
    );
  }
}
