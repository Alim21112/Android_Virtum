import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/health_metrics_record.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/services/database_service.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  late Future<_DbSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DbSnapshot> _load() async {
    final user = await DatabaseService.getUser();
    final token = await DatabaseService.getToken();
    final history = await DatabaseService.getMetricsHistory();
    return _DbSnapshot(user: user, token: token, history: history);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Local Database',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'SQLite storage viewer',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<_DbSnapshot>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  final data = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _InfoCard(
                          title: 'User profile',
                          content: data.user == null
                              ? 'No user stored'
                              : '${data.user!.name}\n${data.user!.email}',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: 'Auth token',
                          content: data.token ?? 'No token stored',
                          icon: Icons.key,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metrics history',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${data.history.length} entries',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (data.history.isEmpty)
                          const Text(
                            'No metrics stored yet.',
                            style: TextStyle(color: Colors.black54),
                          )
                        else
                          ...data.history.map((record) {
                            return _MetricRecordCard(record: record);
                          }),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await DatabaseService.clearMetrics();
                            await _refresh();
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Clear metrics history'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await DatabaseService.clearAll();
                            await _refresh();
                          },
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Clear all local data'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DbSnapshot {
  const _DbSnapshot({
    required this.user,
    required this.token,
    required this.history,
  });

  final UserProfile? user;
  final String? token;
  final List<HealthMetricsRecord> history;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF667EEA),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRecordCard extends StatelessWidget {
  const _MetricRecordCard({required this.record});

  final HealthMetricsRecord record;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM, HH:mm');
    final metrics = record.metrics;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatter.format(record.savedAt),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetricChip(label: 'HR', value: '${metrics.heartRate} bpm'),
              _MetricChip(label: 'Steps', value: '${metrics.steps}'),
              _MetricChip(
                label: 'BP',
                value: metrics.bloodPressure,
              ),
              _MetricChip(
                label: 'Water',
                value: '${metrics.waterIntakeLiters} L',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
