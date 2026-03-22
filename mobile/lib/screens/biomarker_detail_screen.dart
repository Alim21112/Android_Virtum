import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/biomarker_catalog.dart';
import 'package:mobile/models/biomarker_data.dart';
import 'package:mobile/models/metrics_snapshot.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/session_service.dart';
import 'package:mobile/theme/virtum_theme.dart';

class BiomarkerDetailScreen extends StatefulWidget {
  const BiomarkerDetailScreen({super.key, required this.metricKey});

  /// e.g. `heartRate`, `steps` — same as web `openBiomarkerDetail(key)`.
  final String metricKey;

  @override
  State<BiomarkerDetailScreen> createState() => _BiomarkerDetailScreenState();
}

class _BiomarkerDetailScreenState extends State<BiomarkerDetailScreen> {
  bool _loading = true;
  String? _error;
  MetricsSnapshot? _snapshot;
  List<BiomarkerHistoryRow> _history = [];

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
      final history = await ApiService.getHistory(userId: user.id, token: token);
      final recommend = await ApiService.getRecommend(userId: user.id, token: token);
      if (history.isEmpty) throw Exception('Load dashboard data first — no biomarker history yet.');
      final latest = history.first.data;
      final snap = MetricsSnapshot.fromLatest(
        latest: latest,
        recommend: recommend,
      );
      if (!mounted) return;
      setState(() {
        _history = history;
        _snapshot = snap;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = BiomarkerCatalog.metaFor(widget.metricKey);
    final snap = _snapshot;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_error!, style: const TextStyle(color: VirtumColors.danger)),
                        const SizedBox(height: 12),
                        TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Back to Dashboard')),
                      ],
                    ),
                  )
                : info == null || snap == null
                    ? const Center(child: Text('Unknown biomarker'))
                    : ListView(
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
                                      info.title,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Tap cards on dashboard to review biomarker context',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VirtumColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: VirtumColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: VirtumColors.lineSoft),
                            ),
                            child: Text(
                              '${BiomarkerCatalog.formatValue(widget.metricKey, snap.valueForKey(widget.metricKey))} ${info.unit}'
                                  .trim(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: VirtumColors.accent,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            context,
                            title: 'About',
                            child: Text(info.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            context,
                            title: 'What this means',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: info.tips
                                  .map(
                                    (t) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '• $t',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            context,
                            title: 'Recent trend',
                            child: Text(
                              BiomarkerCatalog.trendFromBiomarkerHistory(widget.metricKey, _history),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            context,
                            title: 'Reference',
                            child: Text(BiomarkerCatalog.rangeText(widget.metricKey)),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.go('/dashboard'),
                              child: const Text('Back to Dashboard'),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _card(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
