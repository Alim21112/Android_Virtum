import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/theme/virtum_theme.dart';

/// Content from web `privacy.html`.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: VirtumColors.surface2,
                    foregroundColor: VirtumColors.textPrimary,
                  ),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/landing'),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy Policy', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Effective: March 2026 · This policy describes how Virtum (“we”, “us”) handles information when you use the Virtum application and related services.',
                      style: t.bodySmall?.copyWith(color: VirtumColors.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    _sec(
                      context,
                      '1. Scope',
                      'This policy applies to the Virtum web application and any integrated AI features. If you use Virtum through an employer or clinic, additional agreements may apply.',
                    ),
                    _sec(context, '2. Information we process', null, body: _infoList(context)),
                    _sec(
                      context,
                      '3. How we use information',
                      'We use information to provide and improve the Service, personalize insights where applicable, maintain security, comply with law, and communicate service-related notices.',
                    ),
                    _sec(
                      context,
                      '4. Storage',
                      'Depending on your deployment, account credentials may be stored on your device (browser storage) while health metrics may be stored on Virtum servers. We apply appropriate technical and organizational measures for the environment in which Virtum is deployed.',
                    ),
                    _sec(
                      context,
                      '5. AI providers',
                      'When you use Jeffrey, your prompts (and relevant context we attach for personalization) may be processed by a third-party AI provider under our instructions. Review that provider’s policy for details. Avoid entering highly sensitive health information you are not comfortable sharing with such providers.',
                    ),
                    _sec(
                      context,
                      '6. Retention',
                      'We retain data as long as your account is active and as needed for security, legal compliance, and dispute resolution. You may request deletion subject to legal exceptions.',
                    ),
                    _sec(
                      context,
                      '7. Your rights',
                      'Depending on your region, you may have rights to access, rectify, delete, restrict, or port your personal data, and to object to certain processing. Contact us to exercise these rights. You may also lodge a complaint with a supervisory authority where applicable.',
                    ),
                    _sec(
                      context,
                      '8. International transfers',
                      'If data is processed across borders, we implement safeguards consistent with applicable law (e.g. standard contractual clauses where required).',
                    ),
                    _sec(
                      context,
                      '9. Children',
                      'Virtum is not directed at children under the age required for lawful consent in their jurisdiction. We do not knowingly collect personal information from children.',
                    ),
                    _sec(
                      context,
                      '10. Changes',
                      'We may update this policy. The “Effective” date will change accordingly. Material updates will be communicated as required by law.',
                    ),
                    _sec(
                      context,
                      '11. Contact',
                      'For privacy requests, use the official Virtum privacy contact published on your website once available.',
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => context.push('/terms'),
                          child: const Text('Terms of Service'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoList(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65);
    Text line(String lead, String rest) => Text.rich(
          TextSpan(
            style: style,
            children: [
              TextSpan(text: lead, style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: rest),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line('Account data: ', 'such as username, email address, and authentication data needed to operate your account.'),
        const SizedBox(height: 8),
        line('Wellness metrics: ', 'data you generate or submit (e.g. steps, heart rate, blood pressure, water intake) and associated timestamps.'),
        const SizedBox(height: 8),
        line('Technical data: ', 'such as IP address, device/browser type, and security logs needed to operate and protect the Service.'),
        const SizedBox(height: 8),
        line('AI interactions: ', 'messages you send to the assistant may be transmitted to our AI provider to generate responses.'),
      ],
    );
  }

  static Widget _sec(BuildContext context, String title, String? plain, {Widget? body}) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (plain != null) SelectableText(plain, style: t.bodyMedium?.copyWith(height: 1.65)),
          if (body != null) body,
        ],
      ),
    );
  }
}
