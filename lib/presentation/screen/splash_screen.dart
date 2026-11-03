import 'dart:async';

import 'package:dart_gemini_example/domain/config/enums.dart';
import 'package:dart_gemini_example/domain/controller/splash_controller.dart';
import 'package:dart_gemini_example/domain/model/async_state.dart';
import 'package:dart_gemini_example/domain/model/device.dart';
import 'package:dart_gemini_example/presentation/screen/api_key_screen.dart';
import 'package:dart_gemini_example/presentation/screen/chat_screen.dart';
import 'package:dart_gemini_example/presentation/widget/image/done.dart';
import 'package:dart_gemini_example/presentation/widget/image/logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key, required this.controller});

  final SplashController controller;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.loadDeviceStatus());
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = _SplashSpacing.forScreen(size);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: spacing.top),
            const Logo(),
            SizedBox(height: spacing.middle),
            SignalBuilder(
              builder: (context) {
                final state = widget.controller.state.value;
                return switch (state.status) {
                  AsyncStateStatus.initial ||
                  AsyncStateStatus.loading =>
                    _buildLoadingWidget(context),
                  AsyncStateStatus.completed when state.data != null =>
                    _buildDataWidget(context, state.data!),
                  AsyncStateStatus.completed => _buildErrorWidget(
                      context,
                      StateError('Device initialization returned no device.'),
                    ),
                  AsyncStateStatus.error =>
                    _buildErrorWidget(context, state.error),
                };
              },
            ),
            SizedBox(height: spacing.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object? error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.error,
          color: colorScheme.error,
          size: 100,
        ),
        const SizedBox(height: 24),
        Text(
          'Could not start the app.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
          textAlign: TextAlign.center,
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            _navigationTimer?.cancel();
            _navigationScheduled = false;
            unawaited(widget.controller.loadDeviceStatus());
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
      ],
    );
  }

  Widget _buildDataWidget(BuildContext context, Device device) {
    if (!_navigationScheduled) {
      _navigationScheduled = true;
      _navigationTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        context.go(
          device.status == DeviceStatus.chat
              ? ChatScreen.routeName
              : ApiKeyScreen.routeName,
        );
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SmallDoneImage(),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Successful',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

final class _SplashSpacing {
  const _SplashSpacing({
    required this.top,
    required this.middle,
    required this.bottom,
  });

  final double top;
  final double middle;
  final double bottom;

  factory _SplashSpacing.forScreen(Size size) {
    final isPortrait = size.height >= size.width;
    final isMobile = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };

    if (isPortrait && isMobile) {
      final isIos = defaultTargetPlatform == TargetPlatform.iOS;
      return _SplashSpacing(
        top: size.height * 0.30,
        middle: size.height * (isIos ? 0.20 : 0.17),
        bottom: size.height * (isIos ? 0.15 : 0.17),
      );
    }
    if (isPortrait) {
      return _SplashSpacing(
        top: size.height * 0.44,
        middle: size.height * 0.42,
        bottom: size.height * 0.15,
      );
    }
    if (isMobile) {
      return _SplashSpacing(
        top: size.height * 0.42,
        middle: size.height * 0.42,
        bottom: size.height * 0.15,
      );
    }
    return _SplashSpacing(
      top: size.height * 0.25,
      middle: size.height * 0.25,
      bottom: size.height * 0.08,
    );
  }
}
