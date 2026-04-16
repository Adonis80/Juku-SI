import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_card.dart';
import '../../theme/holo_text.dart';
import '../../theme/si_colors.dart';
import 'cc_status_provider.dart';

class CcStatusPanel extends ConsumerWidget {
  const CcStatusPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(ccStatusProvider);
    final isActive = statusAsync.valueOrNull?.isActive ?? false;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderColor: isActive
          ? SiColors.primary.withAlpha(120)
          : SiColors.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _StatusDot(isActive: isActive),
              const SizedBox(width: 8),
              const HoloText('CLAUDE CODE', fontSize: 11),
            ],
          ),
          const SizedBox(height: 6),
          statusAsync.when(
            data: (status) => _StatusBody(status: status),
            loading: () => Text(
              'Connecting...',
              style:
                  GoogleFonts.inter(fontSize: 11, color: SiColors.textMuted),
            ),
            error: (error, stack) => Text(
              'Unavailable',
              style: GoogleFonts.inter(fontSize: 11, color: SiColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;
  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? SiColors.success : SiColors.textMuted;
    Widget dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [BoxShadow(color: color.withAlpha(120), blurRadius: 6)]
            : null,
      ),
    );
    if (isActive) {
      dot = dot
          .animate(onPlay: (c) => c.repeat())
          .fadeOut(duration: 800.ms, curve: Curves.easeInOut)
          .then()
          .fadeIn(duration: 800.ms);
    }
    return dot;
  }
}

class _StatusBody extends StatelessWidget {
  final CcStatus status;
  const _StatusBody({required this.status});

  @override
  Widget build(BuildContext context) {
    if (!status.isActive) {
      return Text(
        'Idle',
        style: GoogleFonts.inter(fontSize: 11, color: SiColors.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (status.currentTask != null)
          Text(
            status.currentTask!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 11, color: SiColors.textSecondary),
          ),
        if (status.lastUpdated != null) ...[
          const SizedBox(height: 2),
          Text(
            _rel(status.lastUpdated!),
            style:
                GoogleFonts.inter(fontSize: 10, color: SiColors.textMuted),
          ),
        ],
      ],
    );
  }

  String _rel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
