import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/brand_assets.dart';
import 'package:mobile/widgets/virtum_footer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: VirtumLogoRow(height: 44),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your AI Health Companion',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: VirtumColors.textMuted,
                      ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VirtumColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VirtumColors.lineSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track, predict and improve your health in one place.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Personal metrics, smart insights, and daily actions in one clean experience.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: VirtumColors.textMuted,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Get Started'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(text: 'Real-time health tracking'),
                    _Pill(text: 'AI recommendations'),
                    _Pill(text: 'Privacy-first design'),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: VirtumColors.lineSoft.withValues(alpha: 0.9)),
                const SizedBox(height: 12),
                Text(
                  'Your data is secure · AI-based recommendations · Built for daily habits',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: VirtumColors.textMuted,
                      ),
                ),
                Divider(color: VirtumColors.lineSoft.withValues(alpha: 0.9)),
                const VirtumFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: VirtumColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: VirtumColors.lineSoft),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
