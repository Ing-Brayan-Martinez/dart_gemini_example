import 'package:dart_gemini_example/presentation/widget/chat/message.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.apiKey,
    this.httpClient,
    super.key,
  });

  final String apiKey;
  final http.Client? httpClient;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  static const _modelName = 'gemini-3.6-flash';

  late final GenerativeModel _model;
  late final ChatSession _chat;
  late final http.Client _httpClient;
  late final bool _ownsHttpClient;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;
  String? _pendingMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ownsHttpClient = widget.httpClient == null;
    _httpClient = widget.httpClient ?? http.Client();
    _model = GenerativeModel(
      model: _modelName,
      apiKey: widget.apiKey,
      httpClient: _httpClient,
    );
    _chat = _model.startChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    if (_ownsHttpClient) {
      _httpClient.close();
    }
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = _chat.history.toList();
    final hasMessages = history.isNotEmpty || _pendingMessage != null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Expanded(
                child: hasMessages
                    ? ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: history.length +
                            (_pendingMessage == null ? 0 : 1) +
                            (_loading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < history.length) {
                            final content = history[index];
                            final text = content.parts
                                .whereType<TextPart>()
                                .map((part) => part.text)
                                .join();
                            return MessageWidget(
                              text: text,
                              isFromUser: content.role == 'user',
                            );
                          }

                          if (_pendingMessage != null &&
                              index == history.length) {
                            return MessageWidget(
                              text: _pendingMessage!,
                              isFromUser: true,
                            );
                          }

                          return const _ThinkingIndicator();
                        },
                      )
                    : const _EmptyConversation(),
              ),
              if (_errorMessage case final error?)
                _RequestError(message: error),
              _buildComposer(context),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Gemini can make mistakes. Check important information.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFieldFocus,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Ask Gemini anything',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: _sendChatMessage,
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textController,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty && !_loading;
                return IconButton.filled(
                  tooltip: 'Send message',
                  onPressed:
                      canSend ? () => _sendChatMessage(value.text) : null,
                  icon: _loading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_upward_rounded),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    final prompt = message.trim();
    if (_loading || prompt.isEmpty) return;

    setState(() {
      _loading = true;
      _pendingMessage = prompt;
      _errorMessage = null;
    });
    _scrollDown();

    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      if (response.text?.trim().isNotEmpty != true) {
        throw StateError('Gemini returned an empty response. Try again.');
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _pendingMessage = null;
        _textController.clear();
      });
      _scrollDown();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _pendingMessage = null;
        _errorMessage = error.toString();
      });
    }

    if (mounted) {
      _textFieldFocus.requestFocus();
    }
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'How can I help you today?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation by sending a message below.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _RequestError extends StatelessWidget {
  const _RequestError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Could not send the message: $message',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
