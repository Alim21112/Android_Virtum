import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Virtum brand mark — use everywhere except [JeffreyBotAvatar].
class VirtumLogoRow extends StatelessWidget {
  const VirtumLogoRow({super.key, this.height = 36});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/virtum_logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}

/// Web `assets/img/bot-logo.svg` — Jeffrey avatar.
class JeffreyBotAvatar extends StatelessWidget {
  const JeffreyBotAvatar({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SvgPicture.asset(
        'assets/images/bot_logo.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
