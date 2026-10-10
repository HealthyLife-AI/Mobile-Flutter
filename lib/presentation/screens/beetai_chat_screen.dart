import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';

/// ⚠️ NOT PART OF THE CONFIRMED BASELINE (Master Build Prompt EN, section 0):
/// "AI Chat: left as an open question... search + manual estimate is the
/// confirmed baseline for this build." This screen is kept in the repo as
/// a working prototype but is intentionally NOT linked from any nav path —
/// wire it back in only once product confirms the AI-chat flow.

class _ChatMessage {
  final String text;
  final bool fromUser;
  const _ChatMessage(this.text, this.fromUser);
}

/// 4.3 BeetAI Chat — welcome/quick-reply modes, ctaVoiceGradient send button
/// (only reserved context for this gradient besides voice/share), typing indicator.
class BeetAiChatScreen extends StatefulWidget {
  const BeetAiChatScreen({super.key});

  @override
  State<BeetAiChatScreen> createState() => _BeetAiChatScreenState();
}

class _BeetAiChatScreenState extends State<BeetAiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage('أهلاً سارة! أنا BeetAI، اسأليني عن أي شيء يخص خطتك الغذائية أو سجّلي وجبة بسرعة 🌿', false),
  ];
  bool _typing = false;

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _controller.clear();
      _typing = true;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(const _ChatMessage('تم تسجيل ذلك في سجلك، هل تودين إضافة أي تفاصيل أخرى؟', false));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(
        title: 'BeetAI',
        subtitle: 'مساعدك الذكي',
        backIcon: Icons.close_rounded,
        actions: [
          HeaderActionIcon(icon: Icons.mic_none_rounded, tooltip: 'إدخال صوتي', onTap: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final m in _messages) _Bubble(message: m),
                if (_typing) const _TypingIndicator(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _send,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'اسألي BeetAI أو سجّلي وجبة…'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(hasText ? _controller.text : 'رسالة صوتية'),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.ctaVoiceGradient),
                    child: Icon(hasText ? Icons.send_rounded : Icons.graphic_eq_rounded, color: Colors.white),
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

class _Bubble extends StatelessWidget {
  final _ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: message.fromUser ? AppColors.primaryGradient : null,
          color: message.fromUser ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        ),
        child: Text(message.text,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: message.fromUser ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final v = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
              final opacity = 0.3 + 0.7 * (v < 0.5 ? v * 2 : (1 - v) * 2);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Opacity(
                  opacity: opacity,
                  child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
