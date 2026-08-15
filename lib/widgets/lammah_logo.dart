import 'package:flutter/material.dart';

class LammhLogo extends StatelessWidget {
  final double size;

  const LammhLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_full.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
