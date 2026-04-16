import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_card.dart';
import '../../theme/si_colors.dart';
import 'chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: GlassCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderColor: message.isUser
                ? SiColors.secondary.withAlpha(120)
                : SiColors.primary.withAlpha(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!message.isUser && message.connectorName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.connectorName!.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: SiColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                Text(
                  message.content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SiColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(message.timestamp),
                  style: GoogleFonts.inter(
                      fontSize: 10, color: SiColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(
            begin: 0.1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOut);
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
