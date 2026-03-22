import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/session_service.dart';

class AuthFlow {
  AuthFlow._();

  static Future<(String token, UserProfile user)> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();
    final email = trimmed.contains('@')
        ? trimmed.toLowerCase()
        : (await ApiService.resolveIdentifier(trimmed)).toLowerCase();

    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.reload();
    final idToken = await cred.user?.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Missing Firebase ID token');
    }
    final pair = await ApiService.loginWithFirebaseIdToken(idToken);
    await SessionService.saveSession(token: pair.$1, user: pair.$2);
    return pair;
  }

  static Future<void> registerAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final idToken = await cred.user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Missing Firebase ID token');
    }
    await ApiService.firebaseRegisterProfile(
      idToken: idToken,
      username: username.trim(),
    );
    await cred.user?.sendEmailVerification();
  }

  static Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> signOutVirtum() async {
    await SessionService.clear();
    await FirebaseAuth.instance.signOut();
  }
}
