import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/providers/core_providers.dart';
import 'package:murmory/core/retrieval/retrieval_models.dart';

class AskMessage {
  final String text;
  final bool isUser;
  final List<RetrievedCitation> citations;
  final bool hasEvidence;

  AskMessage({
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
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: "Ask Murmory"
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
                          color: MurmoryColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: MurmoryColors.pastelBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.sparkles, size: 11, color: MurmoryColors.primaryBlue),
                            SizedBox(width: 4),
                            Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: MurmoryColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_messages.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _messages.clear());
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: MurmoryColors.cardBorder),
                          boxShadow: MurmoryColors.softShadow,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(CupertinoIcons.arrow_clockwise, color: MurmoryColors.textSecondary, size: 18),
                      ),
                    ),
                ],
              ),
            ),

            // Local Grounding Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: const [
                  Icon(CupertinoIcons.lock_shield_fill, size: 13, color: MurmoryColors.iconGreen),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Answers strictly synthesized against your private voice vault',
                      style: TextStyle(
                        fontSize: 12,
                        color: MurmoryColors.textSecondary,
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
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: MurmoryColors.cardBorder),
                                boxShadow: MurmoryColors.softShadow,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.sparkles,
                                size: 36,
                                color: MurmoryColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'What would you like to recall?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: MurmoryColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Query your recorded memories with grounded citations.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: MurmoryColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Suggested Prompts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: MurmoryColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: _suggestedPrompts.map((prompt) {
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _askQuestion(prompt);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: MurmoryColors.cardBorder),
                                    boxShadow: MurmoryColors.softShadow,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(CupertinoIcons.chat_bubble_2, size: 14, color: MurmoryColors.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(
                                        prompt,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: MurmoryColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
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
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: MurmoryColors.cardBorder),
                                boxShadow: MurmoryColors.softShadow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CupertinoActivityIndicator(),
                                  SizedBox(width: 10),
                                  Text(
                                    'Searching & verifying sources...',
                                    style: TextStyle(color: MurmoryColors.textSecondary, fontSize: 13),
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
                                    color: MurmoryColors.primaryBlue,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    boxShadow: MurmoryColors.blueGlow,
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.4,
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                    border: Border.all(color: MurmoryColors.cardBorder),
                                    boxShadow: MurmoryColors.softShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.text,
                                        style: const TextStyle(
                                          color: MurmoryColors.textPrimary,
                                          fontSize: 15,
                                          height: 1.45,
                                        ),
                                      ),
                                      if (msg.citations.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Sources in your vault:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: MurmoryColors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        ...msg.citations.map((cite) {
                                          final sec = (cite.startMs / 1000).round();
                                          final minStr = (sec ~/ 60).toString().padLeft(2, '0');
                                          final secStr = (sec % 60).toString().padLeft(2, '0');

                                          return GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              context.push('/memories/${cite.memoryId}');
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: MurmoryColors.softGrey,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(CupertinoIcons.link, size: 12, color: MurmoryColors.primaryBlue),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${cite.memoryTitle} ($minStr:$secStr)',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: MurmoryColors.primaryBlue,
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(CupertinoIcons.chevron_right, size: 12, color: MurmoryColors.textMuted),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                      },
                    ),
            ),

            // Question Input Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: MurmoryColors.cardBorder),
                boxShadow: MurmoryColors.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: 'Ask your voice memories...',
                      placeholderStyle: const TextStyle(
                        color: MurmoryColors.textMuted,
                        fontSize: 15,
                      ),
                      style: const TextStyle(color: MurmoryColors.textPrimary, fontSize: 15),
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
                        color: MurmoryColors.primaryBlue,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x333B82F6),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }
}
