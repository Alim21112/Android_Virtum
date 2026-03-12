import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/health_metrics.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/screens/chat_screen.dart';
import 'package:mobile/screens/database_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/stats_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.user, required this.token});

  final UserProfile user;
  final String token;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  HealthMetrics? _metrics;
  bool _loading = true;
  String? _error;
  Timer? _loadingTimeout;

  String _friendlyError(Object error) {
    if (error is TimeoutException) {
      return 'Server timeout. Check backend and try again.';
    }
    if (error is SocketException) {
      return 'Cannot reach backend. Is it running?';
    }
    return error.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 12), () {
      if (!mounted || !_loading) return;
      setState(() {
        _loading = false;
        _error =
            'Loading is taking too long. Check backend connection and retry.';
      });
    });

    try {
      final metrics = await ApiService.fetchMetrics(token: widget.token);
      if (!mounted) return;
      _loadingTimeout?.cancel();
      setState(() => _metrics = metrics);
    } catch (error) {
      final cached = await DatabaseService.getLatestMetrics();
      if (!mounted) return;
      _loadingTimeout?.cancel();
      setState(() {
        _metrics = cached;
        _error = cached == null ? _friendlyError(error) : null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadMetrics,
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: widget.user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _loadMetrics,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (metrics != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        MetricCard(
                          title: 'Heart Rate',
                          value: metrics.heartRate.toString(),
                          unit: 'bpm',
                          icon: Icons.favorite,
                        ),
                        MetricCard(
                          title: 'Steps Today',
                          value: metrics.steps.toString(),
                          unit: 'steps',
                          icon: Icons.directions_walk,
                        ),
                        MetricCard(
                          title: 'Blood Pressure',
                          value: metrics.bloodPressure,
                          unit: 'mmHg',
                          icon: Icons.monitor_heart,
                        ),
                        MetricCard(
                          title: 'Water Intake',
                          value: metrics.waterIntakeLiters.toStringAsFixed(1),
                          unit: 'L',
                          icon: Icons.water_drop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            if (metrics != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Water Goal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (metrics.waterIntakeLiters / 2.5).clamp(0, 1),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text('${metrics.waterIntakeLiters} / 2.5 L'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (metrics != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Text('🤖'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'AI Health Insight',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          metrics.insight,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (metrics != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Health Trends',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: _HealthChart(metrics: metrics),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _ActionButton(
                  label: 'Generate & Store New Data',
                  icon: Icons.auto_graph,
                  onTap: () {
                    _loadMetrics();
                  },
                ),
                _ActionButton(
                  label: 'Refresh Data from DB',
                  icon: Icons.sync,
                  onTap: () {
                    _loadMetrics();
                  },
                ),
                _ActionButton(
                  label: 'Chat with AI',
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(token: widget.token),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  label: 'View statistics',
                  icon: Icons.bar_chart,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StatsScreen(metrics: metrics),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  label: 'Set Reminder',
                  icon: Icons.alarm,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder set for 18:00')),
                    );
                  },
                ),
                _ActionButton(
                  label: 'Profile settings',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: widget.user),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  label: 'Database',
                  icon: Icons.storage,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DatabaseScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: (MediaQuery.of(context).size.width - 52) / 2,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthChart extends StatelessWidget {
  const _HealthChart({required this.metrics});

  final HealthMetrics metrics;

  List<FlSpot> _buildSeries(double base, double variance) {
    return List.generate(7, (index) {
      // Make smoother, more even progression
      final normalizedIndex = (index - 3) / 3.0; // -1 to 1
      final seed = normalizedIndex * variance;
      return FlSpot(index.toDouble(), base + seed);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create two separate series - use actual values for better readability
    final heartBase = metrics.heartRate.toDouble();
    final stepsBase = (metrics.steps / 100).toDouble(); // Scale to similar range
    
    // Generate series with actual values
    final heartSeries = _buildSeries(heartBase, 6);
    final stepsSeries = _buildSeries(stepsBase, 8);

    // Calculate range to fit all data
    final allValues = [...heartSeries.map((s) => s.y), ...stepsSeries.map((s) => s.y)];
    final rawMinY = allValues.reduce((a, b) => a < b ? a : b);
    final rawMaxY = allValues.reduce((a, b) => a > b ? a : b);
    final minY = (rawMinY - 10).floorToDouble();
    final maxY = (rawMaxY + 10).ceilToDouble();
    final interval = ((maxY - minY) / 4).ceilToDouble();
    
    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Heart Rate (bpm)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF764BA2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Steps (×100)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'D${value.toInt() + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.white,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isHeartRate = spot.barIndex == 0;
                      final value = spot.y.toInt();
                      final actualValue = isHeartRate ? value : value * 100;
                      final label = isHeartRate ? 'HR' : 'Steps';
                      final unit = isHeartRate ? 'bpm' : '';
                      
                      return LineTooltipItem(
                        '$label: $actualValue $unit',
                        TextStyle(
                          color: spot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: heartSeries,
                  isCurved: true,
                  color: const Color(0xFF667EEA),
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF667EEA).withOpacity(0.15),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF667EEA),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
                LineChartBarData(
                  spots: stepsSeries,
                  isCurved: true,
                  color: const Color(0xFF764BA2),
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF764BA2).withOpacity(0.12),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF764BA2),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
