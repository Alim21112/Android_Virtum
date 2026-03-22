import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/biomarker_data.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/session_service.dart';
import 'package:mobile/theme/virtum_theme.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  List<BiomarkerHistoryRow> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await SessionService.getUser();
      final token = await SessionService.getToken();
      if (user == null) throw Exception('Not signed in');
      final rows = await ApiService.getHistory(userId: user.id, token: token);
      if (!mounted) return;
      setState(() {
        _rows = rows.reversed.toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is SocketException ? 'Network error' : e.toString();
      });
    }
  }

  List<FlSpot> _series(double Function(BiomarkerData) pick) {
    return List.generate(_rows.length, (i) {
      final v = pick(_rows[i].data);
      return FlSpot(i.toDouble(), v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: VirtumColors.surface2,
                      foregroundColor: VirtumColors.textPrimary,
                    ),
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Health Charts',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Expanded trends and historical overview',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: VirtumColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Text(_error!, style: const TextStyle(color: VirtumColors.danger))
              else ...[
                _bigChart(context, title: 'Heart Rate Trend', spots: _series((d) => d.heartRate.toDouble())),
                _bigChart(context, title: 'Steps Trend', spots: _series((d) => d.steps.toDouble())),
                _bigChart(context, title: 'Water Intake Trend', spots: _series((d) => d.waterIntake)),
                _bigChart(context, title: 'Calories Trend', spots: _series((d) => d.calorieIntake.toDouble())),
                _bigChart(context, title: 'Sleep Trend', spots: _series((d) => d.sleepHours)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigChart(BuildContext context, {required String title, required List<FlSpot> spots}) {
    if (spots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _card(
          context,
          title: title,
          child: const Text('No data yet.'),
        ),
      );
    }
    final ys = spots.map((s) => s.y).toList();
    final minY = ys.reduce((a, b) => a < b ? a : b) - 1;
    final maxY = ys.reduce((a, b) => a > b ? a : b) + 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        context,
        title: title,
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: spots.first.x,
              maxX: spots.last.x,
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: VirtumColors.lineSoft, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: VirtumColors.accent,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: VirtumColors.accent.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VirtumColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VirtumColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
