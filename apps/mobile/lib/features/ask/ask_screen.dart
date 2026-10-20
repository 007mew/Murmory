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
    'What were my priorities?',
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
      appBar: AppBar(
        title: const Text('Ask Memories', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear conversation',
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline badge indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: MurmoryColors.accent.withValues(alpha: 0.1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: MurmoryColors.accentLight),
                SizedBox(width: 8),
                Text(
                  'Local-first grounded synthesis • Zero cloud upload',
                  style: TextStyle(fontSize: 11, color: MurmoryColors.accentLight, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Conversation Messages
          Expanded(
            child: _messages.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: MurmoryColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 48,
                            color: MurmoryColors.accentLight,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Grounded Memory Retrieval',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ask questions about thoughts, commitments, or ideas. Answers are synthesized directly from your voice transcripts with clickable audio citations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: MurmoryColors.textSecondaryLight, height: 1.4),
                        ),
                        const SizedBox(height: 36),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SUGGESTED QUESTIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: MurmoryColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _suggestedPrompts.map((prompt) {
                            return ActionChip(
                              avatar: const Icon(Icons.help_outline_rounded, size: 16),
                              label: Text(prompt, style: const TextStyle(fontSize: 13)),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _askQuestion(prompt);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = _messages[i];
                      if (msg.isUser) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16, left: 48),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: MurmoryColors.accent,
                              borderRadius: BorderRadius.circular(16).copyWith(bottomRight: Radius.zero),
                            ),
                            child: Text(
                              msg.text,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20, right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: MurmoryColors.accent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.auto_awesome_rounded, size: 16, color: MurmoryColors.accentLight),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Murmory Assistant',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16).copyWith(topLeft: Radius.zero),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                              ),
                              child: Text(
                                msg.text,
                                style: const TextStyle(fontSize: 14, height: 1.45),
                              ),
                            ),
                            if (msg.citations.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'SOURCE CITATIONS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: MurmoryColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...msg.citations.map((c) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: MurmoryColors.accent.withValues(alpha: 0.3)),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/memories/${c.memoryId}');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: MurmoryColors.accent.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.play_arrow_rounded, color: MurmoryColors.accentLight, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.memoryTitle,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Timestamp: ${c.timeFormatted}',
                                                  style: const TextStyle(fontSize: 11, color: MurmoryColors.accentLight),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MurmoryColors.surfaceDark,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask your voice memories...',
                        hintStyle: TextStyle(color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      onSubmitted: _askQuestion,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _askQuestion(_controller.text),
                    icon: const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
