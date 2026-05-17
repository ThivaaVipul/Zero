import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive CE and open boxes
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
