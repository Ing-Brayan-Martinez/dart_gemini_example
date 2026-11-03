import 'dart:convert';

import 'package:dart_gemini_example/presentation/widget/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('sends a prompt to the configured Gemini model', (tester) async {
    String? requestPath;
    String? apiKeyHeader;
    final requestBodies = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      requestPath = request.url.path;
      apiKeyHeader = request.headers['x-goog-api-key'];
      requestBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {'text': 'A widget is a reusable UI building block.'},
                ],
              },
              'finishReason': 'STOP',
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatWidget(apiKey: 'test-api-key', httpClient: client),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'What is a widget?');
    await tester.pump();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(
      requestPath,
      '/v1beta/models/gemini-3.6-flash:generateContent',
    );
    expect(apiKeyHeader, 'test-api-key');
    expect(requestBodies.first['contents'], [
      {
        'role': 'user',
        'parts': [
          {'text': 'What is a widget?'},
        ],
      },
    ]);
    expect(find.text('What is a widget?'), findsOneWidget);
    expect(
      find.text('A widget is a reusable UI building block.'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);

    await tester.enterText(find.byType(TextField), 'What about app state?');
    await tester.pump();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(requestBodies, hasLength(2));
    expect(requestBodies.last['contents'], [
      {
        'role': 'user',
        'parts': [
          {'text': 'What is a widget?'},
        ],
      },
      {
        'role': 'model',
        'parts': [
          {'text': 'A widget is a reusable UI building block.'},
        ],
      },
      {
        'role': 'user',
        'parts': [
          {'text': 'What about app state?'},
        ],
      },
    ]);
    expect(find.text('What about app state?'), findsOneWidget);
  });

  testWidgets('does not send an empty prompt', (tester) async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return http.Response('{}', 200);
    });
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatWidget(apiKey: 'test-api-key', httpClient: client),
        ),
      ),
    );

    final sendButton = tester.widget<IconButton>(
      find.byType(IconButton),
    );
    expect(sendButton.onPressed, isNull);
    expect(requestCount, 0);
  });

  testWidgets('keeps the prompt and displays an error when sending fails',
      (tester) async {
    final client = MockClient((request) async {
      throw http.ClientException('Network unavailable');
    });
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatWidget(apiKey: 'test-api-key', httpClient: client),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Try again');
    await tester.pump();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Try again',
    );
    expect(find.textContaining('Network unavailable'), findsOneWidget);
  });
}
