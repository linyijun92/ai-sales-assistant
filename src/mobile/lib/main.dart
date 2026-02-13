import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screen
import 'screens/home_screen.dart';
import 'screens/voice_input_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/reports_screen.dart';

// Services
import 'services/api_service.dart';
import 'services/speech_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 助销助手',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/voice': (context) => const VoiceInputScreen(),
        '/customers': (context) => const CustomerListScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
