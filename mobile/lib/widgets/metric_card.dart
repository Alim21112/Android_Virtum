import 'package:flutter/material.dart';
import 'package:mobile/theme/virtum_theme.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.trend,
    this.statusLabel,
    this.footer,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final String? trend;
  final String? statusLabel;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      tween: Tween(begin: 0.92, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VirtumColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: VirtumColors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: VirtumColors.accent),
                  if (trend != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Text(
                        trend!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(letterSpacing: 0.4),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: VirtumColors.accent),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (statusLabel != null) ...[
              const SizedBox(height: 6),
              Text(
                statusLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: VirtumColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 4),
              Text(
                footer!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: VirtumColors.textMuted,
                      fontSize: 10,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
