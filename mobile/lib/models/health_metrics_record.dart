import 'package:mobile/models/health_metrics.dart';

class HealthMetricsRecord {
  const HealthMetricsRecord({
    required this.metrics,
    required this.savedAt,
  });

  final HealthMetrics metrics;
  final DateTime savedAt;
}
