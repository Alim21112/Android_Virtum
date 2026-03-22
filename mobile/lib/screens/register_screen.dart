import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/auth_flow.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/brand_assets.dart';
import 'package:mobile/widgets/virtum_footer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _agreeTerms = false;
  bool _newsletter = false;
  String? _error;

  static final _usernameRe = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  bool _hasLower(String s) => RegExp(r'[a-z]').hasMatch(s);
  bool _hasUpper(String s) => RegExp(r'[A-Z]').hasMatch(s);
  bool _hasDigit(String s) => RegExp(r'[0-9]').hasMatch(s);
  bool _hasSpecial(String s) => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/]').hasMatch(s);

  String _friendly(Object error) {
    if (error is TimeoutException) return 'Server timeout.';
    if (error is SocketException) return 'Cannot reach backend.';
    var message = error.toString();
    if (message.startsWith('Exception: ')) message = message.substring(11);
    return message;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreeTerms) {
      setState(() => _error = 'Please agree to Terms and Privacy Policy.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthFlow.registerAccount(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.go('/verify', extra: _emailController.text.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendly(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pwd = _passwordController.text;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Center(child: VirtumLogoRow(height: 36)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: VirtumColors.surface2,
                        foregroundColor: VirtumColors.textPrimary,
                      ),
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            'Create your Virtum account',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: VirtumColors.textMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VirtumColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VirtumColors.lineSoft),
                  ),
                  child: Text(
                    'Privacy: Your sign-in credentials are stored on this device. Health metrics you '
                    'save are stored on the Virtum server and linked to your account. See Privacy Policy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          hintText: 'alex_m',
                          helperText: '3–20 characters: letters, numbers, underscore only.',
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (!_usernameRe.hasMatch(t)) return 'Invalid username';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          hintText: 'you@company.com',
                          helperText: 'Use an email you access regularly.',
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (!t.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        onChanged: (_) => setState(() {}),
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (v) {
                          final t = v ?? '';
                          if (t.length < 8 || t.length > 128) return 'Password length 8–128';
                          if (!_hasLower(t) ||
                              !_hasUpper(t) ||
                              !_hasDigit(t) ||
                              !_hasSpecial(t)) {
                            return 'Password does not meet complexity rules';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      _RuleLine(ok: pwd.length >= 8, text: 'At least 8 characters'),
                      _RuleLine(ok: _hasLower(pwd), text: 'One lowercase letter (a–z)'),
                      _RuleLine(ok: _hasUpper(pwd), text: 'One uppercase letter (A–Z)'),
                      _RuleLine(ok: _hasDigit(pwd), text: 'One number (0–9)'),
                      _RuleLine(ok: _hasSpecial(pwd), text: 'One special character (!@#\$ …)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm password *'),
                        validator: (v) {
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _agreeTerms,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('I agree to the Terms of Service and Privacy Policy.'),
                      ),
                      CheckboxListTile(
                        value: _newsletter,
                        onChanged: (v) => setState(() => _newsletter = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Email me product tips and early access news (optional).'),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: VirtumColors.danger)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Login'),
                ),
                const VirtumFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: ok ? VirtumColors.success : VirtumColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ok ? VirtumColors.textPrimary : VirtumColors.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
