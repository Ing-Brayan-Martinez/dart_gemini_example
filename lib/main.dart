import 'package:dart_gemini_example/presentation/provider/app_provider.dart';
import 'package:dart_gemini_example/presentation/routes/app_routes.dart';
import 'package:dart_gemini_example/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: providers,
      child: const GenerativeAISample(),
    ),
  );
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gemini Chat',
      theme: AppTheme.light,
      routerConfig: AppRoutes.router,
    );
  }
}
