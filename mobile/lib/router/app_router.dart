import 'package:go_router/go_router.dart';
import 'package:mobile/app_state.dart';
import 'package:mobile/screens/biomarker_detail_screen.dart';
import 'package:mobile/screens/charts_screen.dart';
import 'package:mobile/screens/chat_screen.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/screens/landing_screen.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/privacy_screen.dart';
import 'package:mobile/screens/register_screen.dart';
import 'package:mobile/screens/terms_screen.dart';
import 'package:mobile/screens/reset_password_screen.dart';
import 'package:mobile/screens/verify_email_screen.dart';
import 'package:mobile/widgets/app_shell.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/landing',
    refreshListenable: authSessionNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggedIn = authSessionNotifier.value;
      final needsAuth =
          loc.startsWith('/dashboard') || loc.startsWith('/charts') || loc.startsWith('/jeffrey');
      if (needsAuth && !loggedIn) {
        return '/login';
      }
      if (loggedIn && loc == '/login') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/charts',
                builder: (context, state) => const ChartsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jeffrey',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/biomarker/:metricKey',
        builder: (context, state) {
          final key = state.pathParameters['metricKey'] ?? 'heartRate';
          return BiomarkerDetailScreen(metricKey: key);
        },
      ),
    ],
  );
}
