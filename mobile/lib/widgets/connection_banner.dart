import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile/theme/virtum_theme.dart';

class ConnectionBannerHost extends StatefulWidget {
  const ConnectionBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectionBannerHost> createState() => _ConnectionBannerHostState();
}

class _ConnectionBannerHostState extends State<ConnectionBannerHost> {
  final _connectivity = Connectivity();
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final offline =
          result.isEmpty || result.every((r) => r == ConnectivityResult.none);
      if (mounted) setState(() => _offline = offline);
    });
    _refresh();
  }

  Future<void> _refresh() async {
    final result = await _connectivity.checkConnectivity();
    final offline =
        result.isEmpty || result.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _offline = offline);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_offline)
          Material(
            color: VirtumColors.bannerOffline,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No network connection',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
