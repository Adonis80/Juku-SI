import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_card.dart';
import '../../theme/holo_text.dart';
import '../../theme/perspective_grid_painter.dart';
import '../../theme/si_colors.dart';
import '../dashboard/cc_status_panel.dart';
import 'chat_bubble.dart';
import 'chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _gridController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    _textController.clear();
    setState(() => _sending = true);
    await ref.read(chatProvider.notifier).sendMessage(text);
    if (mounted) setState(() => _sending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatProvider);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) => CustomPaint(
              painter: PerspectiveGridPainter(
                  animationValue: _gridController.value),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const HoloText(
                        'SI — MISSION CONTROL',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                      const Spacer(),
                      const SizedBox(
                          width: 200, child: CcStatusPanel()),
                    ],
                  ),
                ),
                const Divider(height: 1, color: SiColors.outline),
                Expanded(
                  child: messagesAsync.when(
                    data: (messages) => messages.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            itemCount: messages.length,
                            itemBuilder: (_, i) =>
                                ChatBubble(message: messages[i]),
                          ),
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: SiColors.primary)),
                    error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: GoogleFonts.inter(
                                color: SiColors.danger))),
                  ),
                ),
                if (_sending)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TypingIndicator(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: _textController,
                            style: GoogleFonts.inter(
                                color: SiColors.textPrimary,
                                fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Talk to SI...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            maxLines: null,
                            onSubmitted: (_) => _send(),
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SendButton(onTap: _send, isLoading: _sending),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HoloText('MISSION CONTROL',
              fontSize: 32, fontWeight: FontWeight.w900),
          const SizedBox(height: 8),
          Text('Your AI command centre is online.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: SiColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Talk to SI. SI handles everything.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: SiColors.textMuted)),
        ],
      )
          .animate()
          .fadeIn(duration: 800.ms)
          .slideY(
              begin: 0.05,
              end: 0,
              duration: 800.ms,
              curve: Curves.easeOut),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _SendButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SiColors.primary.withAlpha(isLoading ? 80 : 200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                      color: SiColors.primary.withAlpha(80),
                      blurRadius: 12)
                ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.send, color: Colors.black, size: 20),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.15;
          final phase = (_anim.value - delay).clamp(0.0, 1.0);
          final alpha =
              ((1 - (phase * 2 - 1).abs()).clamp(0.3, 1.0) * 255).toInt();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: SiColors.primary.withAlpha(alpha),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
