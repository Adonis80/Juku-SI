import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../connectors/connector_registry.dart';
import '../../theme/glass_card.dart';
import '../../theme/holo_text.dart';
import '../../theme/si_colors.dart';
import 'chat_message.dart';
import 'chat_provider.dart';

class CiChatScreen extends ConsumerStatefulWidget {
  const CiChatScreen({super.key});

  @override
  ConsumerState<CiChatScreen> createState() => _CiChatScreenState();
}

class _CiChatScreenState extends ConsumerState<CiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showConnectorSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SIColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ConnectorSheet(),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    setState(() => _sending = true);
    await ref.read(chatProvider.notifier).sendMessage(text);
    setState(() => _sending = false);
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
    final messages = ref.watch(chatProvider);
    if (messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _AppBar(
        onClear: () => showDialog(
          context: context,
          builder: (_) => _ClearDialog(
            onConfirm: () => ref.read(chatProvider.notifier).clearHistory(),
          ),
        ),
        onSelectConnector: () => _showConnectorSheet(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, i) =>
                        _MessageBubble(message: messages[i], index: i),
                  ),
          ),
          _InputBar(controller: _controller, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBar({required this.onClear, required this.onSelectConnector});
  final VoidCallback onClear;
  final VoidCallback onSelectConnector;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectors = ref.watch(allConnectorsProvider);
    final activeIndex = ref.watch(activeConnectorIndexProvider);
    final active = connectors[activeIndex];
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const HoloText(
            'CENTRAL INTELLIGENCE',
            fontSize: 11,
            fontWeight: FontWeight.w300,
            letterSpacing: 3,
            textAlign: TextAlign.start,
          ),
          GestureDetector(
            onTap: onSelectConnector,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  active.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: active.isConfigured ? SIColors.cyan : SIColors.red,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.expand_more_rounded,
                  size: 14,
                  color: active.isConfigured ? SIColors.cyan : SIColors.red,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          color: SIColors.textMuted,
          onPressed: onClear,
          tooltip: 'Clear history',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Connector selector bottom sheet ──────────────────────────────────────────

class _ConnectorSheet extends ConsumerWidget {
  const _ConnectorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectors = ref.watch(allConnectorsProvider);
    final activeIndex = ref.watch(activeConnectorIndexProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HoloText('SELECT MODEL', fontSize: 11, letterSpacing: 3),
          const SizedBox(height: 16),
          ...List.generate(connectors.length, (i) {
            final c = connectors[i];
            final isActive = i == activeIndex;
            return GestureDetector(
              onTap: () {
                ref.read(activeConnectorIndexProvider.notifier).state = i;
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? SIColors.cyan.withValues(alpha: 0.08)
                      : SIColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? SIColors.cyan.withValues(alpha: 0.4)
                        : SIColors.outline,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? SIColors.cyan
                                  : SIColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.isConfigured ? 'Configured' : 'API key not set',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: c.isConfigured
                                  ? SIColors.textMuted
                                  : SIColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: SIColors.cyan,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Message bubbles ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.index});
  final ChatMessage message;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _AvatarDot(isLoading: message.isLoading),
              const SizedBox(width: 8),
              Flexible(
                child: isUser
                    ? _UserBubble(message: message)
                    : _AiBubble(message: message),
              ),
              const SizedBox(width: 8),
              if (isUser) const _UserDot(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SIColors.userBubble,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        border: Border.all(
          color: SIColors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SIColors.purple.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        message.text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: SIColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: SIColors.cyan,
      borderOpacity: 0.15,
      borderRadius: 18,
      blurSigma: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: message.isLoading
          ? const _TypingIndicator()
          : Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: SIColors.textPrimary,
                height: 1.6,
              ),
            ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context2, snap) {
              final phase = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
              final opacity = (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(
                0.3,
                1.0,
              );
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SIColors.cyan.withValues(alpha: opacity),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  const _AvatarDot({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SIColors.surface,
        border: Border.all(
          color: SIColors.cyan.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'CI',
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: SIColors.cyan,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SIColors.purple.withValues(alpha: 0.2),
        border: Border.all(
          color: SIColors.purple.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 14, color: SIColors.purple),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SIColors.cyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  color: SIColors.surface,
                ),
                child: const Center(
                  child: Text(
                    'CI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: SIColors.cyan,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 1,
                end: 1.04,
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 24),
          const HoloText(
            'CENTRAL INTELLIGENCE READY',
            fontSize: 13,
            letterSpacing: 3,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask anything. CI routes to the right tool.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: SIColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: SIColors.surface.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: SIColors.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: SIColors.surfaceCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SIColors.outline),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: SIColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask CI anything…',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: SIColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sending
                    ? SIColors.outline
                    : SIColors.cyan.withValues(alpha: 0.15),
                border: Border.all(
                  color: sending
                      ? SIColors.outline
                      : SIColors.cyan.withValues(alpha: 0.5),
                ),
                boxShadow: sending
                    ? []
                    : [
                        BoxShadow(
                          color: SIColors.cyan.withValues(alpha: 0.2),
                          blurRadius: 12,
                        ),
                      ],
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SIColors.cyan,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward_rounded,
                      color: SIColors.cyan,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clear dialog ──────────────────────────────────────────────────────────────

class _ClearDialog extends StatelessWidget {
  const _ClearDialog({required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SIColors.surfaceCard,
      title: const HoloText('Clear History', fontSize: 16, letterSpacing: 1),
      content: Text(
        'This will delete all chat messages. This cannot be undone.',
        style: GoogleFonts.inter(fontSize: 13, color: SIColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: SIColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('Clear', style: GoogleFonts.inter(color: SIColors.red)),
        ),
      ],
    );
  }
}
