import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/models/firebase_config_response.dart';
import 'package:mobile/services/api_service.dart';

/// Loads `/api/auth/firebase-config` and initializes Firebase for the client app.
Future<FirebaseConfigResponse?> initFirebaseFromBackend() async {
  Object? lastError;
  StackTrace? lastStack;

  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 800 + attempt * 400));
      }

      final cfg = await ApiService.getFirebaseConfig();
      if (!cfg.canInitializeFirebase) {
        if (kDebugMode) {
          debugPrint(
            'Firebase config incomplete: enabled=${cfg.enabled} '
            'apiKeyEmpty=${cfg.apiKey.isEmpty} appIdEmpty=${cfg.appId.isEmpty}',
          );
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
      return cfg;
    } catch (e, st) {
      lastError = e;
      lastStack = st;
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
    throw Exception(
      'Firebase did not start. Open the app again with internet, or confirm '
      'your backend /api/auth/firebase-config returns enabled and full web client fields.',
    );
  }
}
