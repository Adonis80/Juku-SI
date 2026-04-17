import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/cc_status_reader.dart';
import '../../theme/glass_card.dart';
import '../../theme/holo_text.dart';
import '../../theme/si_colors.dart';

class CcStatusPanel extends StatefulWidget {
  const CcStatusPanel({super.key});

  @override
  State<CcStatusPanel> createState() => _CcStatusPanelState();
}

class _CcStatusPanelState extends State<CcStatusPanel> {
  CcStatus _status = CcStatus.empty;
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() => _loading = true);
    final status = await readCcStatus();
    if (mounted) {
      setState(() {
        _status = status;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _AppBar(loading: _loading, onRefresh: _refresh),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(status: _status),
          const SizedBox(height: 16),
          _TaskCard(status: _status),
          const SizedBox(height: 16),
          _OutputCard(status: _status),
          const SizedBox(height: 16),
          _SetupNote(),
        ],
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.loading, required this.onRefresh});
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: const HoloText(
        'CC STATUS',
        fontSize: 13,
        fontWeight: FontWeight.w300,
        letterSpacing: 4,
        textAlign: TextAlign.start,
      ),
      actions: [
        if (loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SIColors.cyan,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: SIColors.textMuted,
            onPressed: onRefresh,
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Cards ─────────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});
  final CcStatus status;

  Color get _stateColor {
    return switch (status.state) {
      'working' => SIColors.green,
      'idle' => SIColors.cyan,
      'error' => SIColors.red,
      _ => SIColors.textMuted,
    };
  }

  IconData get _stateIcon {
    return switch (status.state) {
      'working' => Icons.build_circle_rounded,
      'idle' => Icons.check_circle_outline_rounded,
      'error' => Icons.error_outline_rounded,
      _ => Icons.radio_button_unchecked_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: _stateColor,
      borderOpacity: 0.25,
      child: Row(
        children: [
          Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stateColor.withValues(alpha: 0.1),
                  border: Border.all(color: _stateColor.withValues(alpha: 0.3)),
                ),
                child: Icon(_stateIcon, color: _stateColor, size: 22),
              )
              .animate(
                onPlay: status.state == 'working'
                    ? (c) => c.repeat(reverse: true)
                    : null,
              )
              .scaleXY(
                begin: 1,
                end: status.state == 'working' ? 1.08 : 1,
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HoloText(
                  'CLAUDE CODE',
                  glowColor: _stateColor,
                  fontSize: 11,
                  letterSpacing: 3,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  status.state.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: _stateColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          if (status.updatedAt.millisecondsSinceEpoch > 0)
            Text(
              _timeAgo(status.updatedAt),
              style: GoogleFonts.inter(fontSize: 11, color: SIColors.textMuted),
            ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.status});
  final CcStatus status;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: SIColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HoloHeader('CURRENT TASK'),
          const SizedBox(height: 12),
          Text(
            status.currentTask.isEmpty ? '—' : status.currentTask,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: status.currentTask.isEmpty
                  ? SIColors.textMuted
                  : SIColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({required this.status});
  final CcStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.lastOutput.isEmpty) return const SizedBox.shrink();
    return GlassCard(
      borderColor: SIColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HoloHeader('LAST OUTPUT', glowColor: SIColors.purple),
          const SizedBox(height: 12),
          Text(
            status.lastOutput,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: SIColors.textSecondary,
              height: 1.6,
            ),
            maxLines: 20,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SetupNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: SIColors.amber,
      borderOpacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HoloHeader('CC BRIDGE', glowColor: SIColors.amber),
          const SizedBox(height: 12),
          Text(
            'SI reads CC status from localhost:3333/status.json.\n'
            'Run the companion watcher to enable live CC state.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: SIColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
