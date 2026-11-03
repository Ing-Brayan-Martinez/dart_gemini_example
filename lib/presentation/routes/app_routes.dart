import 'package:dart_gemini_example/domain/controller/api_key_controller.dart';
import 'package:dart_gemini_example/domain/controller/splash_controller.dart';
import 'package:dart_gemini_example/presentation/screen/api_key_screen.dart';
import 'package:dart_gemini_example/presentation/screen/chat_screen.dart';
import 'package:dart_gemini_example/presentation/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: SplashScreen.routeName,
    routes: [
      GoRoute(
        path: SplashScreen.routeName,
        pageBuilder: (context, state) => _page(
          state,
          SplashScreen(
            controller: context.read<SplashController>(),
          ),
        ),
      ),
      GoRoute(
        path: ChatScreen.routeName,
        pageBuilder: (context, state) => _page(
          state,
          ChatScreen(
            controller: context.read<ApiKeyController>(),
          ),
        ),
      ),
      GoRoute(
        path: ApiKeyScreen.routeName,
        pageBuilder: (context, state) => _page(
          state,
          ApiKeyScreen(
            controller: context.read<ApiKeyController>(),
          ),
        ),
      ),
    ],
  );

  static CustomTransitionPage<void> _page(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
