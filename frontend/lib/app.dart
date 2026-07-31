import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class SiahApp extends StatelessWidget {
  const SiahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
