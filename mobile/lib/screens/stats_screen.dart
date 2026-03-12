import 'package:flutter/material.dart';
import 'package:mobile/models/health_metrics.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.metrics});

  final HealthMetrics? metrics;

  @override
  Widget build(BuildContext context) {
    final data = metrics;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (data == null)
              const Text('No data yet.')
            else
              Column(
                children: [
                  _StatRow(label: 'Average heart rate', value: '${data.heartRate} bpm'),
                  _StatRow(label: 'Average steps', value: '${data.steps} / day'),
                  _StatRow(label: 'Water intake', value: '${data.waterIntakeLiters}L'),
                  _StatRow(label: 'Temperature', value: '${data.temperature}°C'),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              'Tip: compare today with last week to track progress.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
