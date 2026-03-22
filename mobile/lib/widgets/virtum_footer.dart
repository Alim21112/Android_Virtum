import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/theme/virtum_theme.dart';

class VirtumFooter extends StatelessWidget {
  const VirtumFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: VirtumColors.textMuted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              TextButton(
                onPressed: () => context.push('/terms'),
                child: const Text('Terms of Service'),
              ),
              Text('·', style: small),
              TextButton(
                onPressed: () => context.push('/privacy'),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Contact: vhcvirtum@gmail.com · +7 705 347 2342\n'
            'Copyright © 2026 Virtum. All rights reserved.',
            textAlign: TextAlign.center,
            style: small,
          ),
        ],
      ),
    );
  }
}
