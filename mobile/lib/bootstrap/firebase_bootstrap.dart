import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/models/firebase_config_response.dart';
import 'package:mobile/services/api_config.dart';
import 'package:mobile/services/api_service.dart';

/// Last failure from [initFirebaseFromBackend] (network, bad JSON, incomplete config, init error).
String? firebaseBootstrapLastError;

/// Loads `/api/auth/firebase-config` and initializes Firebase for the client app.
Future<FirebaseConfigResponse?> initFirebaseFromBackend() async {
  Object? lastError;
  StackTrace? lastStack;
  firebaseBootstrapLastError = null;

  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 800 + attempt * 400));
      }

      final cfg = await ApiService.getFirebaseConfig();
      if (!cfg.canInitializeFirebase) {
        firebaseBootstrapLastError =
            'Backend /api/auth/firebase-config is not usable: enabled=${cfg.enabled}, '
            'apiKeyEmpty=${cfg.apiKey.isEmpty}, appIdEmpty=${cfg.appId.isEmpty}, '
            'projectIdEmpty=${cfg.projectId.isEmpty}, senderEmpty=${cfg.messagingSenderId.isEmpty}. '
            'On Replit set all FIREBASE_* secrets and redeploy.';
        if (kDebugMode) {
          debugPrint('Firebase config incomplete: $firebaseBootstrapLastError');
        }
        return cfg;
      }

      if (Firebase.apps.isEmpty) {
        final authDomain = cfg.authDomain.isNotEmpty
            ? cfg.authDomain
            : '${cfg.projectId}.firebaseapp.com';

        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: cfg.apiKey,
            appId: cfg.appId,
            messagingSenderId: cfg.messagingSenderId,
            projectId: cfg.projectId,
            authDomain: authDomain,
            storageBucket: cfg.storageBucket.isEmpty ? null : cfg.storageBucket,
          ),
        );
      }
      firebaseBootstrapLastError = null;
      return cfg;
    } catch (e, st) {
      lastError = e;
      lastStack = st;
      firebaseBootstrapLastError =
          '${ApiConfig.defaultBaseUrl}/api/auth/firebase-config — $e';
      if (kDebugMode) {
        debugPrint('initFirebaseFromBackend attempt ${attempt + 1}/3 failed: $e');
        debugPrint('$st');
      }
    }
  }

  if (kDebugMode && lastError != null) {
    debugPrint('Firebase init gave up after retries: $lastError');
    debugPrint('$lastStack');
  }
  return null;
}

/// Call before any [FirebaseAuth] usage so cold start / sleeping backend still works.
Future<void> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) return;

  await initFirebaseFromBackend();

  if (Firebase.apps.isEmpty) {
    final detail = firebaseBootstrapLastError?.trim();
    throw Exception(
      detail != null && detail.isNotEmpty
          ? detail
          : 'Firebase did not start. Check URL ${ApiConfig.defaultBaseUrl}/api/auth/firebase-config '
              'in a browser on the phone, Repl must be awake, and Secrets must expose full Firebase web + admin env.',
    );
  }
}
