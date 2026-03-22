import 'package:flutter/material.dart';
import 'package:mobile/app_state.dart';
import 'package:mobile/bootstrap/firebase_bootstrap.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/connection_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebaseFromBackend();
  await syncAuthFromSession();
  runApp(const VirtumApp());
}

class VirtumApp extends StatelessWidget {
  const VirtumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();
    return MaterialApp.router(
      title: 'Virtum',
      theme: buildVirtumTheme(),
      routerConfig: router,
      builder: (context, child) {
        return ConnectionBannerHost(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
