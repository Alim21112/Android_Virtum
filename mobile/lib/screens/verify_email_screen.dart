import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app_state.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/session_service.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/brand_assets.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _continueAfterVerification() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception(
          'Сессия Firebase сброшена. Вернитесь на экран входа, войдите с тем же email и паролем — '
          'после подтверждения почты вход должен пройти.',
        );
      }

      // После клика по ссылке в письме Firebase обновляет аккаунт не мгновенно — несколько reload + пауза.
      for (var attempt = 0; attempt < 5; attempt++) {
        final u = FirebaseAuth.instance.currentUser;
        if (u == null) break;
        await u.reload();
        final afterReload = FirebaseAuth.instance.currentUser;
        if (afterReload == null) break;
        if (afterReload.emailVerified) break;
        await Future<void>.delayed(Duration(milliseconds: 400 + attempt * 200));
      }

      final fresh = FirebaseAuth.instance.currentUser;
      if (fresh == null) {
        throw Exception('No Firebase session. Please log in again.');
      }
      if (!fresh.emailVerified) {
        throw Exception(
          'Почта ещё не подтверждена в Firebase. Откройте ссылку из письма ещё раз, подождите 10–20 секунд '
          'и нажмите снова. Либо войдите через «Login» с тем же email и паролем.',
        );
      }

      // Важно: в JWT должен попасть обновлённый claim email_verified — иначе бэкенд вернёт 401.
      final idToken = await fresh.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Missing Firebase ID token');
      }
      final pair = await ApiService.loginWithFirebaseIdToken(idToken);
      await SessionService.saveSession(token: pair.$1, user: pair.$2);
      setLoggedIn(true);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: VirtumColors.surface2,
                  foregroundColor: VirtumColors.textPrimary,
                ),
                onPressed: () => context.go('/register'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 12),
              const Center(child: VirtumLogoRow(height: 36)),
              const SizedBox(height: 16),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Complete verification in inbox first',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: VirtumColors.textMuted),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VirtumColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VirtumColors.lineSoft),
                ),
                child: Text('Email: ${widget.email}'),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a Firebase verification email. Open the link in your inbox, then continue.\n\n'
                'If you do not see the email, check your Spam/Junk folder.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: VirtumColors.danger)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _continueAfterVerification,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('I verified my email'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy ? null : _resend,
                  child: const Text('Send verification email again'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _busy ? null : () => context.go('/login'),
                  child: const Text('Уже подтвердил почту — войти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
