import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/chat/chat_screen.dart';
import 'theme/si_theme.dart';

void main() {
  runApp(const ProviderScope(child: SiApp()));
}

class SiApp extends StatelessWidget {
  const SiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI — Mission Control',
      theme: SiTheme.dark(),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
