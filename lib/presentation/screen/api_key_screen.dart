import 'package:dart_gemini_example/domain/controller/api_key_controller.dart';
import 'package:dart_gemini_example/presentation/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/link.dart';

class ApiKeyScreen extends StatefulWidget {
  static const routeName = "/api_key";

  const ApiKeyScreen({super.key, required this.controller});

  final ApiKeyController controller;

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;
  bool _obscureApiKey = true;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _textController.text.trim();
    if (_isSaving) return;
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Enter an API key to continue.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.controller.assignApiKey(apiKey);
      if (!mounted) return;
      context.go(ChatScreen.routeName);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Gemini'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: colorScheme.surfaceContainerLow,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: colorScheme.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Add your Gemini API key',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The key is saved on this device and used to connect '
                        'to the Gemini API.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        child: Link(
                          uri: Uri.https(
                            'aistudio.google.com',
                            '/app/apikey',
                          ),
                          target: LinkTarget.blank,
                          builder: (context, followLink) => TextButton.icon(
                            onPressed: followLink,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Get an API key'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _textController,
                        obscureText: _obscureApiKey,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'API key',
                          hintText: 'Paste your API key',
                          prefixIcon: const Icon(Icons.key_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscureApiKey
                                ? 'Show API key'
                                : 'Hide API key',
                            onPressed: () {
                              setState(() {
                                _obscureApiKey = !_obscureApiKey;
                              });
                            },
                            icon: Icon(
                              _obscureApiKey
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _saveApiKey(),
                      ),
                      if (_errorMessage case final error?) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Could not save the API key: $error',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveApiKey,
                        icon: _isSaving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded),
                        label: Text(_isSaving ? 'Saving...' : 'Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
