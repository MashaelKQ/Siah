import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Firebase initialized successfully');

  // Sets up channels and the local timezone. Does not ask for
  // permission: that happens on a screen where the request has
  // context, because a prompt at launch usually gets declined.
  await NotificationService.initialize();

  runApp(const SiahApp());
}
