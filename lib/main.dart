import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/chat/ci_chat_screen.dart';
import 'features/dashboard/cc_status_panel.dart';
import 'theme/perspective_grid_painter.dart';
import 'theme/si_colors.dart';

void main() {
  runApp(const ProviderScope(child: SIApp()));
}

class SIApp extends StatelessWidget {
  const SIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juku SI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: SIColors.background,
          primary: SIColors.cyan,
          secondary: SIColors.purple,
        ),
        scaffoldBackgroundColor: SIColors.background,
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      home: const SIShell(),
    );
  }
}

class SIShell extends StatefulWidget {
  const SIShell({super.key});

  @override
  State<SIShell> createState() => _SIShellState();
}

class _SIShellState extends State<SIShell> {
  int _currentIndex = 0;

  static const _screens = [
    CiChatScreen(),
    CcStatusPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SIColors.background,
      body: Stack(
        children: [
          // Perspective grid background — always visible
          Positioned.fill(
            child: CustomPaint(
              painter: const PerspectiveGridPainter(),
            ),
          ),
          // Active screen
          IndexedStack(index: _currentIndex, children: _screens),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SIColors.surface,
        border: Border(top: BorderSide(color: SIColors.outline, width: 0.5)),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: SIColors.cyan.withValues(alpha: 0.1),
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: currentIndex == 0 ? SIColors.cyan : SIColors.textMuted,
            ),
            selectedIcon: const Icon(Icons.chat_bubble_rounded, color: SIColors.cyan),
            label: 'CI Chat',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.monitor_heart_outlined,
              color: currentIndex == 1 ? SIColors.cyan : SIColors.textMuted,
            ),
            selectedIcon: const Icon(Icons.monitor_heart_rounded, color: SIColors.cyan),
            label: 'CC Status',
          ),
        ],
      ),
    );
  }
}
