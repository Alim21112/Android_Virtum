import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/models/firebase_config_response.dart';
import 'package:mobile/services/api_service.dart';

/// Loads `/api/auth/firebase-config` and initializes Firebase for the client app.
Future<FirebaseConfigResponse?> initFirebaseFromBackend() async {
  try {
    final cfg = await ApiService.getFirebaseConfig();
    if (!cfg.canInitializeFirebase) {
      return cfg;
    }
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: cfg.apiKey,
        appId: cfg.appId,
        messagingSenderId: cfg.messagingSenderId,
        projectId: cfg.projectId,
        storageBucket: cfg.storageBucket.isEmpty ? null : cfg.storageBucket,
      ),
    );
    return cfg;
  } catch (_) {
    return null;
  }
}
