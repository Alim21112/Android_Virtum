import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/biomarker_data.dart';
import 'package:mobile/models/metrics_snapshot.dart';
import 'package:mobile/models/user_goals.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/brand_assets.dart';

/// Top bar: logout left, logo centered, symmetric spacer right (web-style).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.username,
    required this.onLogout,
  });

  final String? username;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: VirtumColors.surface2,
                  foregroundColor: VirtumColors.textPrimary,
                ),
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Log out',
              ),
              Expanded(
                child: Center(
                  child: VirtumLogoRow(height: MediaQuery.sizeOf(context).width < 400 ? 28 : 36),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome back,',
            style: t.bodyMedium?.copyWith(color: VirtumColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            username ?? '—',
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }
}

List<String> _providerRisks(MetricsSnapshot s) {
  final risks = <String>[];
  final hr = s.heartRate <= 0 ? 70 : s.heartRate;
  if (hr > 110 || hr < 50) {
    risks.add('Heart rate out of typical range');
  }
  if (s.steps < 4000) risks.add('Low activity level');
  if (s.waterIntake < 1.5) risks.add('Hydration below target');
  final parts = s.bloodPressure.split('/');
  final sys = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 120;
  final dia = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 80;
  if (sys > 140 || dia > 90) risks.add('Elevated blood pressure marker');
  return risks;
}

String _riskLevel(List<String> risks) {
  if (risks.length >= 3) return 'High';
  if (risks.isNotEmpty) return 'Medium';
  return 'Low';
}

Color _riskColor(String level) {
  switch (level) {
    case 'High':
      return VirtumColors.danger;
    case 'Medium':
      return const Color(0xFFE8A317);
    default:
      return const Color(0xFF2ECC71);
  }
}

class ProviderSummaryCard extends StatelessWidget {
  const ProviderSummaryCard({super.key, required this.snapshot, required this.recommend});

  final MetricsSnapshot snapshot;
  final Map<String, dynamic>? recommend;

  @override
  Widget build(BuildContext context) {
    final risks = _providerRisks(snapshot);
    final level = _riskLevel(risks);
    final insights = (recommend?['insights'] as List<dynamic>?)?.take(2).map((e) => '$e').toList() ?? <String>[];
    final t = Theme.of(context).textTheme;

    return _sectionShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🩺 Provider Mode v2',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _riskColor(level).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _riskColor(level).withValues(alpha: 0.5)),
                ),
                child: Text(
                  'Risk: $level',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: _riskColor(level),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Simplified clinician summary for quick triage and follow-up.',
            style: t.bodySmall?.copyWith(color: VirtumColors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _kpi('HR:', '${snapshot.heartRate} bpm'),
              _kpi('BP:', snapshot.bloodPressure),
              _kpi('Steps:', '${snapshot.steps}'),
              _kpi('Hydration:', '${snapshot.waterIntake.toStringAsFixed(1)} L'),
            ],
          ),
          const SizedBox(height: 12),
          Text('Flags:', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          if (risks.isEmpty)
            Text('No critical flags from current snapshot.', style: t.bodySmall?.copyWith(color: VirtumColors.textMuted))
          else
            ...risks.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: t.bodyMedium),
                    Expanded(child: Text(r, style: t.bodyMedium?.copyWith(height: 1.3))),
                  ],
                ),
              ),
            ),
          if (insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('AI notes:', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...insights.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: t.bodyMedium),
                    Expanded(child: Text(i, style: t.bodyMedium?.copyWith(height: 1.3))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: VirtumColors.textPrimary, fontSize: 13, height: 1.3),
        children: [
          TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(text: ' $value'),
        ],
      ),
    );
  }
}

class DailyFocusCard extends StatelessWidget {
  const DailyFocusCard({
    super.key,
    required this.snapshot,
    required this.goals,
    required this.recommend,
  });

  final MetricsSnapshot snapshot;
  final UserGoals goals;
  final Map<String, dynamic>? recommend;

  @override
  Widget build(BuildContext context) {
    final checklist = [
      ('Hydration target', snapshot.waterIntake >= goals.water),
      ('Steps target', snapshot.steps >= goals.steps),
      ('Calorie target', snapshot.calorieIntake >= goals.calories * 0.85),
      ('Sleep target', snapshot.sleepHours >= goals.sleep),
    ];
    final pending = checklist.where((e) => !e.$2).length;
    final actions = <String>[];
    if (snapshot.waterIntake < goals.water) actions.add('Drink 250ml water now');
    if (snapshot.steps < goals.steps) actions.add('Take a 10-minute walk');
    final hrFocus = snapshot.heartRate <= 0 ? 70 : snapshot.heartRate;
    if (hrFocus > 105) actions.add('Take a 3-minute breathing break');
    if (actions.isEmpty) actions.add('Great momentum today — keep consistency');
    final tip = recommend?['recommendation'] as String?;
    final t = Theme.of(context).textTheme;

    return _sectionShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '📌 Daily Focus',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: VirtumColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: VirtumColors.lineSoft),
                ),
                child: Text(
                  pending == 0 ? 'All on track' : '$pending pending',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Actionable plan based on your current metrics and personal goals.',
            style: t.bodySmall?.copyWith(color: VirtumColors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          ...checklist.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(c.$2 ? '✅' : '⬜', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.$1,
                      style: t.bodyMedium?.copyWith(
                        color: c.$2 ? VirtumColors.textMuted : VirtumColors.textPrimary,
                        decoration: c.$2 ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Next actions:', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...actions.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(a, style: t.bodyMedium?.copyWith(height: 1.3))),
                ],
              ),
            ),
          ),
          if (tip != null && tip.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: t.bodyMedium?.copyWith(height: 1.35, color: VirtumColors.textPrimary),
                children: [
                  const TextSpan(text: 'AI tip: ', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: tip.trim()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

int _progressPercent(num value, num goal) {
  final g = goal <= 0 ? 0.1 : goal.toDouble();
  return (100 * (value.toDouble() / g)).round().clamp(0, 100);
}

class GoalsProgressList extends StatelessWidget {
  const GoalsProgressList({super.key, required this.snapshot, required this.goals});

  final MetricsSnapshot snapshot;
  final UserGoals goals;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Water', snapshot.waterIntake, goals.water, 'L'),
      ('Steps', snapshot.steps.toDouble(), goals.steps, ''),
      ('Calories', snapshot.calorieIntake.toDouble(), goals.calories, 'kcal'),
      ('Sleep', snapshot.sleepHours, goals.sleep, 'h'),
    ];
    return Column(
      children: items.map((it) {
        final pct = _progressPercent(it.$2, it.$3);
        final v = it.$4.isEmpty ? '${it.$2.round()}' : '${it.$2}${it.$4}';
        final g = it.$4.isEmpty ? '${it.$3.round()}' : '${it.$3}${it.$4}';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('$v / $g', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: VirtumColors.surface2,
                  color: VirtumColors.accent,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Widget _sectionShell(BuildContext context, {required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: VirtumColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: VirtumColors.lineSoft),
    ),
    child: child,
  );
}

/// Last [maxPoints] history rows, oldest → newest for chart X.
List<FlSpot> spotsFromHistory(
  List<BiomarkerHistoryRow> history,
  double Function(BiomarkerData) pick, {
  int maxPoints = 7,
}) {
  if (history.isEmpty) return [];
  final slice = history.take(maxPoints).toList().reversed.toList();
  return List.generate(
    slice.length,
    (i) => FlSpot(i.toDouble(), pick(slice[i].data)),
  );
}

Widget miniTrendChart({
  required String title,
  required List<FlSpot> spots,
  required String valueLabel,
  Color? lineColor,
}) {
  if (spots.isEmpty) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: VirtumColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VirtumColors.lineSoft),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
  final ys = spots.map((s) => s.y);
  final minY = ys.reduce((a, b) => a < b ? a : b) - 2;
  final maxY = ys.reduce((a, b) => a > b ? a : b) + 2;
  final color = lineColor ?? VirtumColors.accent;
  return Container(
    height: 150,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: VirtumColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: VirtumColors.lineSoft),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (spots.length - 1).toDouble().clamp(0, 100),
              minY: minY,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        Text(valueLabel, style: const TextStyle(fontSize: 11, color: VirtumColors.textMuted)),
      ],
    ),
  );
}
