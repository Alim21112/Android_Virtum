import 'package:flutter/foundation.dart';
import 'package:mobile/services/session_service.dart';

/// Drives [GoRouter] refresh when login/session changes.
final ValueNotifier<bool> authSessionNotifier = ValueNotifier<bool>(false);

Future<void> syncAuthFromSession() async {
  authSessionNotifier.value = await SessionService.hasSession();
}

void setLoggedIn(bool value) {
  authSessionNotifier.value = value;
}
