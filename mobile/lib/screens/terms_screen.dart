import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/theme/virtum_theme.dart';

/// Content from web `terms.html`.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                    Text('Terms of Service', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Effective: March 2026 · Virtum (“we”, “us”, “our”) provides the Virtum application and related services (“Service”).',
                      style: t.bodySmall?.copyWith(color: VirtumColors.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    _sec(context, '1. Agreement', 'By creating an account or using the Service, you agree to these Terms. If you do not agree, do not use Virtum.'),
                    _sec(
                      context,
                      '2. The Service',
                      'Virtum offers tools to view wellness-related metrics, trends, and an AI assistant (“Jeffrey”) for informational support. We may update features, interfaces, or infrastructure as we improve the product.',
                    ),
                    _sec(
                      context,
                      '3. Not medical advice',
                      null,
                      body: _notMedicalBody(context),
                    ),
                    _sec(
                      context,
                      '4. Accounts & eligibility',
                      'You must provide accurate registration information and keep credentials confidential. You are responsible for activity under your account. You must be old enough to enter a binding contract in your jurisdiction (typically 18+, or the age required where you live).',
                    ),
                    _sec(context, '5. Acceptable use', null, body: _bulletBody(context)),
                    _sec(
                      context,
                      '6. Data & privacy',
                      'Our collection and use of personal information is described in the Privacy Policy, which is incorporated into these Terms. Open Privacy Policy from the link below.',
                    ),
                    _sec(
                      context,
                      '7. Third-party services',
                      'The Service may rely on third-party infrastructure (including AI providers). Their terms and privacy practices may also apply when those services process data on our behalf.',
                    ),
                    _sec(
                      context,
                      '8. Intellectual property',
                      'Virtum name, branding, and software are protected by applicable laws. You receive a limited, non-exclusive license to use the Service for personal, non-commercial use unless otherwise agreed in writing.',
                    ),
                    _sec(
                      context,
                      '9. Disclaimer of warranties',
                      'The Service is provided “as is” and “as available” without warranties of any kind, express or implied, to the fullest extent permitted by law.',
                    ),
                    _sec(
                      context,
                      '10. Limitation of liability',
                      'To the fullest extent permitted by law, Virtum and its suppliers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits, data, or goodwill, arising from your use of the Service.',
                    ),
                    _sec(
                      context,
                      '11. Termination',
                      'We may suspend or terminate access if these Terms are violated or if required for legal or security reasons. You may stop using the Service at any time.',
                    ),
                    _sec(
                      context,
                      '12. Changes',
                      'We may modify these Terms. We will indicate the “Effective” date at the top. Continued use after changes constitutes acceptance. Material changes may require additional notice where required by law.',
                    ),
                    _sec(
                      context,
                      '13. Governing law',
                      'These Terms are governed by the laws of the jurisdiction where Virtum’s operating company is established, without regard to conflict-of-law principles, except where mandatory consumer protections in your country apply.',
                    ),
                    _sec(
                      context,
                      '14. Contact',
                      'For legal or privacy inquiries, use the contact channel published on your official Virtum website or support email once available.',
                    ),
                    TextButton(
                      onPressed: () => context.push('/privacy'),
                      child: const Text('Privacy Policy'),
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

  static Widget _notMedicalBody(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65, color: VirtumColors.textPrimary),
        children: const [
          TextSpan(text: 'The Service is '),
          TextSpan(text: 'not', style: TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(
            text:
                ' a medical device and does not replace professional diagnosis or treatment. Always consult qualified healthcare providers for medical decisions. In an emergency, contact local emergency services.',
          ),
        ],
      ),
    );
  }

  static Widget _bulletBody(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• No unlawful, harmful, or abusive use of the Service.', style: style),
        Text('• No attempt to disrupt, reverse engineer, or gain unauthorized access to systems or data.', style: style),
        Text('• No use of the AI to generate illegal content or to impersonate others.', style: style),
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
