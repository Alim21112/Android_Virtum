import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app_state.dart';
import 'package:mobile/models/biomarker_catalog.dart';
import 'package:mobile/models/biomarker_data.dart';
import 'package:mobile/models/metrics_snapshot.dart';
import 'package:mobile/models/user_goals.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_flow.dart';
import 'package:mobile/services/session_service.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/brand_assets.dart';
import 'package:mobile/widgets/dashboard_sections.dart';
import 'package:mobile/widgets/metric_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfile? _user;
  String? _token;
  MetricsSnapshot? _snapshot;
  List<BiomarkerHistoryRow> _history = [];
  Map<String, dynamic>? _recommend;
  String _insightText = '';
  bool _loading = true;
  String? _error;
  /// Signed-in user has no biomarker rows yet (not an error — show onboarding actions).
  bool _noDataYet = false;
  bool _seeding = false;
  /// One-shot auto sample per session so first login after registration gets a dashboard without hunting for a button.
  bool _autoSeedThisSession = false;

  UserGoals _goals = UserGoals.defaults;

  int _reminderMinutes = 120;
  bool _reminderPanel = false;
  Timer? _reminderTimer;
  bool _timerRunning = false;

  late final TextEditingController _goalWaterCtrl;
  late final TextEditingController _goalStepsCtrl;
  late final TextEditingController _goalCaloriesCtrl;
  late final TextEditingController _goalSleepCtrl;
  late final TextEditingController _manualStepsCtrl;
  late final TextEditingController _manualCaloriesCtrl;
  late final TextEditingController _manualSleepCtrl;

  @override
  void initState() {
    super.initState();
    _goalWaterCtrl = TextEditingController();
    _goalStepsCtrl = TextEditingController();
    _goalCaloriesCtrl = TextEditingController();
    _goalSleepCtrl = TextEditingController();
    _manualStepsCtrl = TextEditingController();
    _manualCaloriesCtrl = TextEditingController();
    _manualSleepCtrl = TextEditingController();
    _bootstrap();
  }

  void _syncGoalControllers() {
    _goalWaterCtrl.text = _goals.water.toStringAsFixed(1);
    _goalStepsCtrl.text = _goals.steps.round().toString();
    _goalCaloriesCtrl.text = _goals.calories.round().toString();
    _goalSleepCtrl.text = _goals.sleep.toStringAsFixed(1);
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _goals = UserGoals.load(prefs);
    _syncGoalControllers();
    _reminderMinutes = prefs.getInt('reminder_minutes') ?? 120;
    await _reloadSessionAndData();
  }

  Future<void> _reloadSessionAndData() async {
    final token = await SessionService.getToken();
    final user = await SessionService.getUser();
    if (!mounted) return;
    setState(() {
      _token = token;
      _user = user;
    });
    await _loadMetrics();
  }

  String _buildInsightText(Map<String, dynamic>? r) {
    if (r == null) return 'Analyzing your health data...';
    final buf = StringBuffer();
    buf.write(r['recommendation'] ?? 'Analyzing your health data...');
    final alert = r['alert'];
    if (alert != null && '$alert'.trim().isNotEmpty) {
      buf.writeln('\n\n⚠ $alert');
    }
    final insights = r['insights'];
    if (insights is List && insights.isNotEmpty) {
      buf.writeln('\n\nObservations:');
      for (final i in insights) {
        buf.writeln('• $i');
      }
    }
    final trends = r['trends'];
    if (trends is Map && trends['steps'] != null) {
      buf.writeln('\nTrend: ${trends['steps']}');
    }
    final pv = r['providerView'];
    if (pv is Map) {
      buf.writeln('\n\nOxygen: ${pv['o2']}%, Calories: ${pv['calories']} kcal');
    }
    return buf.toString();
  }

  /// [silent]: refresh data without full-screen loading (keeps scroll position; use after saves / pull-to-refresh).
  Future<void> _loadMetrics({bool silent = false}) async {
    final token = _token;
    final user = _user;
    if (token == null || user == null) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
        _noDataYet = false;
      });
      return;
    }
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
        _noDataYet = false;
      });
    }
    try {
      final history = await ApiService.getHistory(userId: user.id, token: token);
      final rec = await ApiService.getRecommend(userId: user.id, token: token);
      if (history.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = null;
          _noDataYet = true;
          _snapshot = null;
          _history = [];
          _recommend = rec;
          _insightText = _buildInsightText(rec);
        });
        _scheduleAutoSeedIfNeeded();
        return;
      }
      final snap = MetricsSnapshot.fromLatest(
        latest: history.first.data,
        recommend: rec,
      );
      if (!mounted) return;
      setState(() {
        _history = history;
        _snapshot = snap;
        _recommend = rec;
        _insightText = _buildInsightText(rec);
        _loading = false;
        _error = null;
        _noDataYet = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        _toast(e is SocketException ? 'Network error' : e.toString(), error: true);
        return;
      }
      setState(() {
        _loading = false;
        _error = e is SocketException ? 'Network error' : e.toString();
        _noDataYet = false;
      });
    }
  }

  void _scheduleAutoSeedIfNeeded() {
    if (_autoSeedThisSession) return;
    final token = _token;
    final user = _user;
    if (token == null || user == null) return;
    _autoSeedThisSession = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _seeding = true);
      try {
        await ApiService.postDataStore(userId: user.id, token: token);
        if (!mounted) return;
        await _loadMetrics(silent: false);
      } catch (_) {
        // Keep empty state + manual "Generate" if backend is unreachable.
      } finally {
        if (mounted) setState(() => _seeding = false);
      }
    });
  }

  Future<void> _generateAndStore() async {
    final token = _token;
    final user = _user;
    if (token == null || user == null) return;
    setState(() => _seeding = true);
    try {
      await ApiService.postDataStore(userId: user.id, token: token);
      if (!mounted) return;
      await _loadMetrics(silent: false);
    } catch (e) {
      _toast('$e', error: true);
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? VirtumColors.danger : null),
    );
  }

  BiomarkerData _withWater(BiomarkerData b, double water) {
    return BiomarkerData(
      steps: b.steps,
      heartRate: b.heartRate,
      bloodPressure: b.bloodPressure,
      weight: b.weight,
      calorieIntake: b.calorieIntake,
      waterIntake: water,
      sleepHours: b.sleepHours,
    );
  }

  /// Apply server save without full history/recommend refetch (avoids whole-dashboard refresh after goals actions).
  void _mergeLatestBiomarker(BiomarkerData latest) {
    if (!mounted) return;
    setState(() {
      _snapshot = MetricsSnapshot.fromLatest(latest: latest, recommend: _recommend);
      if (_history.isEmpty) {
        _history = [BiomarkerHistoryRow(data: latest, flagged: false)];
      } else {
        _history = [
          BiomarkerHistoryRow(data: latest, flagged: false),
          ..._history.skip(1),
        ];
      }
    });
  }

  Future<void> _saveGoalsFromFields() async {
    final w = double.tryParse(_goalWaterCtrl.text.replaceAll(',', '.'));
    final st = double.tryParse(_goalStepsCtrl.text.replaceAll(',', '.'));
    final cal = double.tryParse(_goalCaloriesCtrl.text.replaceAll(',', '.'));
    final sl = double.tryParse(_goalSleepCtrl.text.replaceAll(',', '.'));
    if (w == null || st == null || cal == null || sl == null) {
      _toast('Enter valid numbers for all goals', error: true);
      return;
    }
    if (w < 0.5 || w > 8 || st < 1000 || st > 40000 || cal < 1000 || cal > 5000 || sl < 4 || sl > 12) {
      _toast('Goals out of allowed range', error: true);
      return;
    }
    setState(() {
      _goals = UserGoals(water: w, steps: st, calories: cal, sleep: sl);
    });
    final prefs = await SharedPreferences.getInstance();
    await UserGoals.save(prefs, _goals);
    if (mounted) _toast('Goals saved');
  }

  Future<void> _resetGoals() async {
    setState(() => _goals = UserGoals.defaults);
    _syncGoalControllers();
    final prefs = await SharedPreferences.getInstance();
    await UserGoals.save(prefs, _goals);
    if (mounted) _toast('Goals reset to default');
  }

  Future<void> _quickAdd(String apiKey, num delta) async {
    final token = _token;
    final user = _user;
    final snap = _snapshot;
    if (token == null || user == null || snap == null) {
      _toast('No metrics loaded', error: true);
      return;
    }
    try {
      final Map<String, dynamic> fields = {};
      if (apiKey == 'steps') {
        fields['steps'] = math.max(0, snap.steps + delta.toInt());
      } else if (apiKey == 'calorieIntake') {
        fields['calorieIntake'] = math.max(0, snap.calorieIntake + delta.toInt());
      } else if (apiKey == 'sleepHours') {
        fields['sleepHours'] = math.max(0.0, snap.sleepHours + delta.toDouble());
      } else {
        return;
      }
      final latest = await ApiService.postCustomMetrics(userId: user.id, token: token, fields: fields);
      if (mounted) {
        _toast('Updated $apiKey');
        _mergeLatestBiomarker(latest);
      }
    } catch (e) {
      _toast('$e', error: true);
    }
  }

  Future<void> _saveManualMetric(String key) async {
    final token = _token;
    final user = _user;
    if (token == null || user == null) return;
    try {
      BiomarkerData latest;
      if (key == 'steps') {
        final v = int.tryParse(_manualStepsCtrl.text.trim());
        if (v == null || v < 0) {
          _toast('Enter valid steps', error: true);
          return;
        }
        latest = await ApiService.postCustomMetrics(userId: user.id, token: token, fields: {'steps': v});
        _manualStepsCtrl.clear();
      } else if (key == 'calorieIntake') {
        final v = int.tryParse(_manualCaloriesCtrl.text.trim());
        if (v == null || v < 0) {
          _toast('Enter valid calories', error: true);
          return;
        }
        latest = await ApiService.postCustomMetrics(userId: user.id, token: token, fields: {'calorieIntake': v});
        _manualCaloriesCtrl.clear();
      } else if (key == 'sleepHours') {
        final v = double.tryParse(_manualSleepCtrl.text.trim().replaceAll(',', '.'));
        if (v == null || v < 0 || v > 24) {
          _toast('Enter valid sleep hours', error: true);
          return;
        }
        latest = await ApiService.postCustomMetrics(userId: user.id, token: token, fields: {'sleepHours': v});
        _manualSleepCtrl.clear();
      } else {
        return;
      }
      if (mounted) {
        _toast('Saved');
        _mergeLatestBiomarker(latest);
      }
    } catch (e) {
      _toast('$e', error: true);
    }
  }

  Future<void> _addWater250ml() async {
    final token = _token;
    final user = _user;
    if (token == null || user == null || _history.isEmpty) {
      _toast('No data to update', error: true);
      return;
    }
    final prev = _history.first.data;
    try {
      final w = await ApiService.postWater(
        userId: user.id,
        waterIntake: prev.waterIntake + 0.25,
        token: token,
      );
      if (mounted) _mergeLatestBiomarker(_withWater(prev, w));
    } catch (e) {
      _toast('$e', error: true);
    }
  }

  Future<void> _resetWaterLocal() async {
    final token = _token;
    final user = _user;
    if (token == null || user == null || _history.isEmpty) return;
    final prev = _history.first.data;
    try {
      final w = await ApiService.postWater(
        userId: user.id,
        waterIntake: 0,
        token: token,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_water_extra_l');
      if (mounted) _mergeLatestBiomarker(_withWater(prev, w));
    } catch (e) {
      _toast('$e', error: true);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );
    if (ok != true) return;
    await AuthFlow.signOutVirtum();
    setLoggedIn(false);
    if (!mounted) return;
    context.go('/landing');
  }

  Future<void> _export() async {
    final user = _user;
    final snap = _snapshot;
    final payload = {
      'user': user?.toJson(),
      'metrics': snap == null
          ? null
          : {
              'heartRate': snap.heartRate,
              'steps': snap.steps,
              'bloodPressure': snap.bloodPressure,
              'waterIntake': snap.waterIntake,
              'weight': snap.weight,
              'calorieIntake': snap.calorieIntake,
              'oxygenSaturation': snap.oxygenSaturation,
              'activityScore': snap.activityScore,
              'sleepHours': snap.sleepHours,
            },
      'exportedAt': DateTime.now().toIso8601String(),
    };
    await Share.share(jsonEncode(payload));
  }

  void _toggleReminderTimer() {
    _reminderTimer?.cancel();
    if (_timerRunning) {
      setState(() => _timerRunning = false);
      return;
    }
    setState(() => _timerRunning = true);
    _reminderTimer = Timer.periodic(Duration(minutes: _reminderMinutes), (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hydration reminder — drink water.')),
      );
    });
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'heartRate':
        return Icons.favorite;
      case 'steps':
        return Icons.directions_walk;
      case 'bloodPressure':
        return Icons.monitor_heart;
      case 'waterIntake':
        return Icons.water_drop;
      case 'weight':
        return Icons.monitor_weight_outlined;
      case 'calorieIntake':
        return Icons.local_fire_department_outlined;
      case 'oxygenSaturation':
        return Icons.air;
      case 'activityScore':
        return Icons.bolt;
      default:
        return Icons.analytics_outlined;
    }
  }

  Widget _metricsGrid(MetricsSnapshot snap) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.92,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: kDashboardMetricCards.map((def) {
        final raw = snap.valueForKey(def.key);
        final valueStr = BiomarkerCatalog.formatValue(def.key, raw);
        final trend = BiomarkerCatalog.trendArrow(def.key, _history);
        final status = BiomarkerCatalog.statusLabel(def.key, raw);
        return GestureDetector(
          onTap: () => context.push('/biomarker/${def.key}'),
          child: MetricCard(
            title: def.label,
            value: valueStr,
            unit: def.unit,
            icon: _iconForKey(def.key),
            trend: trend,
            statusLabel: status,
            footer: BiomarkerCatalog.rangeText(def.key),
          ),
        );
      }).toList(),
    );
  }

  Widget _quickActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _smallAction(
          'Generate & store',
          () async {
            final t = _token;
            final u = _user;
            if (t == null || u == null) return;
            await ApiService.postDataStore(userId: u.id, token: t);
            if (!mounted) return;
            await _loadMetrics(silent: true);
          },
        ),
        _smallAction('Refresh', () => _loadMetrics(silent: true)),
        _smallAction('Chat', () => context.go('/jeffrey')),
        _smallAction('Reminder', () => setState(() => _reminderPanel = !_reminderPanel)),
        _smallAction('Export', _export),
        _smallAction('Logout', _logout),
      ],
    );
  }

  Widget _waterCard(MetricsSnapshot snap) {
    final totalWater = snap.waterIntake;
    final progress = (totalWater / _goals.water).clamp(0.0, 1.0);
    return _sectionCard(
      context,
      title: "💧 Today's Water Goal",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 8),
          Text('${totalWater.toStringAsFixed(2)} / ${_goals.water.toStringAsFixed(1)} L'),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(onPressed: _resetWaterLocal, child: const Text('Reset')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _addWater250ml, child: const Text('+ 250ml')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reminderCard() {
    return _sectionCard(
      context,
      title: 'Reminder timer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set an interval in minutes to receive hydration reminders.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextFormField(
            key: ValueKey(_reminderMinutes),
            initialValue: _reminderMinutes.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutes (1–1440)'),
            onChanged: (v) => _reminderMinutes = int.tryParse(v) ?? 120,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _toggleReminderTimer,
              child: Text(_timerRunning ? 'Stop' : 'Start timer'),
            ),
          ),
          Text(
            _timerRunning ? 'Timer running ($_reminderMinutes min).' : 'Timer is off.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _goalsCard(MetricsSnapshot snap) {
    return _sectionCard(
      context,
      title: '🎯 Personal Goals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 360;
              Widget field({required String label, required TextEditingController ctrl}) {
                return TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: label, isDense: true),
                );
              }
              if (narrow) {
                return Column(
                  children: [
                    field(label: 'Water (L)', ctrl: _goalWaterCtrl),
                    field(label: 'Steps', ctrl: _goalStepsCtrl),
                    field(label: 'Calories', ctrl: _goalCaloriesCtrl),
                    field(label: 'Sleep (h)', ctrl: _goalSleepCtrl),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: field(label: 'Water (L)', ctrl: _goalWaterCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: field(label: 'Steps', ctrl: _goalStepsCtrl)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: field(label: 'Calories', ctrl: _goalCaloriesCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: field(label: 'Sleep (h)', ctrl: _goalSleepCtrl)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(onPressed: _saveGoalsFromFields, child: const Text('Save Goals')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(onPressed: _resetGoals, child: const Text('Reset')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Quick add', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _quickAdd('steps', 500),
                child: const Text('+500 Steps'),
              ),
              OutlinedButton(
                onPressed: () => _quickAdd('calorieIntake', 200),
                child: const Text('+200 Cal'),
              ),
              OutlinedButton(
                onPressed: () => _quickAdd('sleepHours', 1),
                child: const Text('+1h Sleep'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Exact values', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _manualStepsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Steps', hintText: 'e.g. 7200'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => _saveManualMetric('steps'), child: const Text('Save Steps')),
          ),
          TextField(
            controller: _manualCaloriesCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories', hintText: 'e.g. 1850'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => _saveManualMetric('calorieIntake'), child: const Text('Save Calories')),
          ),
          TextField(
            controller: _manualSleepCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Sleep (h)', hintText: 'e.g. 7.5'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => _saveManualMetric('sleepHours'), child: const Text('Save Sleep')),
          ),
          const SizedBox(height: 8),
          GoalsProgressList(snapshot: snap, goals: _goals),
        ],
      ),
    );
  }

  Widget _jeffreyCard() {
    return _sectionCard(
      context,
      title: 'Jeffrey — Health Insight',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: JeffreyBotAvatar(size: 44),
          ),
          Expanded(
            child: Text(
              _insightText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChartsRow(MetricsSnapshot snap) {
    final hrSpots = spotsFromHistory(_history, (d) => d.heartRate.toDouble());
    final stepSpots = spotsFromHistory(_history, (d) => d.steps.toDouble());
    return Row(
      children: [
        Expanded(
          child: miniTrendChart(
            title: 'Heart Rate',
            spots: hrSpots,
            valueLabel: '${snap.heartRate} bpm (latest)',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: miniTrendChart(
            title: 'Steps',
            spots: stepSpots,
            valueLabel: '${snap.steps} steps (latest)',
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _goalWaterCtrl.dispose();
    _goalStepsCtrl.dispose();
    _goalCaloriesCtrl.dispose();
    _goalSleepCtrl.dispose();
    _manualStepsCtrl.dispose();
    _manualCaloriesCtrl.dispose();
    _manualSleepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final snap = _snapshot;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadMetrics(silent: true),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DashboardHeader(
                  username: user?.username,
                  onLogout: _logout,
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!, style: const TextStyle(color: VirtumColors.danger)),
                )
              else if (_noDataYet)
                _buildEmptyDataOnboarding(context)
              else if (snap != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final mainBlocks = <Widget>[
                      _metricsGrid(snap),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ProviderSummaryCard(snapshot: snap, recommend: _recommend),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _miniChartsRow(snap),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _quickActions(),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DailyFocusCard(
                          snapshot: snap,
                          goals: _goals,
                          recommend: _recommend,
                        ),
                      ),
                    ];
                    final sideBlocks = <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _waterCard(snap),
                      ),
                      if (_reminderPanel) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _reminderCard(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _goalsCard(snap),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _jeffreyCard(),
                      ),
                    ];
                    if (wide) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: _metricsGrid(snap),
                                  ),
                                  ...mainBlocks.skip(1),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: sideBlocks,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _metricsGrid(snap),
                        ),
                        ...mainBlocks.skip(1),
                        ...sideBlocks,
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDataOnboarding(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tip = _recommend != null ? (_recommend!['recommendation'] as String?)?.trim() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_seeding) ...[
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: VirtumColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: VirtumColors.lineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome — your metrics will appear here',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _seeding
                      ? 'Adding sample data from the server…'
                      : 'There are no biomarker rows for your account yet. Generate sample data to load the dashboard.',
                  style: t.bodyMedium?.copyWith(color: VirtumColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _seeding ? null : _generateAndStore,
                    child: Text(_seeding ? 'Adding sample data…' : 'Generate & store'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _seeding ? null : () => _loadMetrics(silent: false),
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),
          if (tip != null && tip.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: VirtumColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VirtumColors.lineSoft),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JeffreyBotAvatar(size: 40),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: t.bodyMedium?.copyWith(height: 1.35))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VirtumColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VirtumColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _smallAction(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
