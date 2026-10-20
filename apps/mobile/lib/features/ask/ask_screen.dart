import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
import 'package:murmory/core/providers/core_providers.dart';
import 'package:murmory/core/retrieval/retrieval_models.dart';

class AskMessage {
  final String text;
  final bool isUser;
  final List<RetrievedCitation> citations;
  final bool hasEvidence;

  const AskMessage({
    required this.text,
    required this.isUser,
    this.citations = const [],
    this.hasEvidence = true,
  });
}

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AskMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _suggestedPrompts = [
    'What did I record today?',
    'Summarize my recent thoughts',
    'What were my action items?',
    'Any ideas on local sync?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion(String question) async {
    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(AskMessage(text: cleanQuestion, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    final retrievalService = ref.read(memoryRetrievalServiceProvider);
    final response = await retrievalService.ask(cleanQuestion);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(
          AskMessage(
            text: response.answer,
            isUser: false,
            citations: response.citations,
            hasEvidence: response.hasEvidence,
          ),
        );
      });
      _scrollToBottom();
    }
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top iOS-Style Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Ask Murmory',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: MurmoryColors.accent.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: MurmoryColors.accent.withValues(alpha: 0.45),
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.sparkles, size: 11, color: MurmoryColors.accentLight),
                                SizedBox(width: 4),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: MurmoryColors.accentLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_messages.isNotEmpty)
                        LiquidGlass(
                          blur: 16,
                          borderRadius: 22,
                          padding: EdgeInsets.zero,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _messages.clear());
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            child: const Icon(CupertinoIcons.arrow_clockwise, color: Colors.white70, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),

                // Local Grounding Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.lock_shield_fill, size: 13, color: Colors.greenAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Answers strictly synthesized against your private voice vault',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Chat Messages Area
                Expanded(
                  child: _messages.isEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Center(
                                child: LiquidGlass(
                                  blur: 16,
                                  borderRadius: 36,
                                  padding: EdgeInsets.all(24),
                                  child: Icon(
                                    CupertinoIcons.sparkles,
                                    size: 46,
                                    color: MurmoryColors.accentLight,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text(
                                  'What would you like to recall?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  'Query your recorded memories with grounded citations.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Suggested Prompts',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: _suggestedPrompts.map((prompt) {
                                  return LiquidGlass(
                                    blur: 12,
                                    borderRadius: 16,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _askQuestion(prompt);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(CupertinoIcons.chat_bubble_2, size: 14, color: MurmoryColors.accentLight),
                                        const SizedBox(width: 8),
                                        Text(
                                          prompt,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: _messages.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, i) {
                            if (i == _messages.length && _isLoading) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: LiquidGlass(
                                  blur: 14,
                                  borderRadius: 18,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CupertinoActivityIndicator(color: Colors.white70),
                                      SizedBox(width: 10),
                                      Text(
                                        'Searching & verifying sources...',
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final msg = _messages[i];
                            return msg.isUser
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(6),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        msg.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                                      ),
                                      child: LiquidGlass(
                                        blur: 18,
                                        borderRadius: 20,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg.text,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                height: 1.4,
                                              ),
                                            ),
                                            if (msg.citations.isNotEmpty) ...[
                                              const SizedBox(height: 14),
                                              const Text(
                                                'Sources & Citations:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ...msg.citations.map((cite) {
                                                final startSec = (cite.startMs / 1000).round();
                                                final minStr = (startSec ~/ 60).toString().padLeft(2, '0');
                                                final secStr = (startSec % 60).toString().padLeft(2, '0');

                                                return GestureDetector(
                                                  onTap: () {
                                                    HapticFeedback.lightImpact();
                                                    context.push('/memories/${cite.memoryId}');
                                                  },
                                                  child: Container(
                                                    margin: const EdgeInsets.only(bottom: 6),
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.08),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.white.withValues(alpha: 0.12),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(CupertinoIcons.link, size: 12, color: MurmoryColors.accentLight),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            '${cite.memoryTitle} ($minStr:$secStr)',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                              color: MurmoryColors.accentLight,
                                                            ),
                                                          ),
                                                        ),
                                                        const Icon(CupertinoIcons.chevron_right, size: 12, color: Colors.white38),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                ),

                // Question Input Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: LiquidGlass(
                    blur: 20,
                    borderRadius: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _controller,
                            placeholder: 'Ask your voice memories...',
                            placeholderStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 15,
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: null,
                            onSubmitted: _askQuestion,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _askQuestion(_controller.text),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_up,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
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
