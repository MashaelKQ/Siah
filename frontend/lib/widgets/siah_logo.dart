import 'package:flutter/material.dart';

class SiahLogo extends StatelessWidget {
  const SiahLogo({
    super.key,
    this.height = 80,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/siah_logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
