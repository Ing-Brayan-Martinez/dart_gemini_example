import 'package:dart_gemini_example/domain/controller/api_key_controller.dart';
import 'package:dart_gemini_example/domain/model/async_state.dart';
import 'package:dart_gemini_example/presentation/screen/api_key_screen.dart';
import 'package:dart_gemini_example/presentation/widget/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "/chat";

  const ChatScreen({super.key, required this.controller});

  final ApiKeyController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadApiKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini'),
      ),
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final state = widget.controller.state.value;
            return switch (state.status) {
              AsyncStateStatus.initial ||
              AsyncStateStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              AsyncStateStatus.completed when state.data != null =>
                ChatWidget(apiKey: state.data!),
              AsyncStateStatus.completed ||
              AsyncStateStatus.error =>
                _buildMissingApiKey(context),
            };
          },
        ),
      ),
    );
  }

  Widget _buildMissingApiKey(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.key_off_rounded,
                size: 44,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Gemini API key unavailable',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a valid API key to start a conversation.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.push(ApiKeyScreen.routeName),
                icon: const Icon(Icons.key_rounded),
                label: const Text('Configure API key'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
