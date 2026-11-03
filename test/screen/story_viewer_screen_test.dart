import 'dart:async';

import 'package:e_commerce_flutter/models/story.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/story_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Story story(String id, String title) => Story(
      id: id,
      title: title,
      subtitle: '',
      format: 'mp4',
      durationSeconds: 4,
      playbackUrl: 'https://media.example.test/$id.mp4',
      playbackExpiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

void main() {
  testWidgets('shows a graceful empty state with no stories', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: StoryViewerScreen(
          stories: const [], initialIndex: 0, renewStory: (_) async => null),
    ));
    expect(find.text('No stories available.'), findsOneWidget);
  });

  testWidgets('story seek bar sends a new position to the player',
      (tester) async {
    Duration? seekTarget;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StorySeekBar(
          position: Duration.zero,
          duration: const Duration(seconds: 10),
          onSeek: (target) async => seekTarget = target,
        ),
      ),
    ));
    final slider = find.byKey(const ValueKey('story-seek-slider'));
    final bounds = tester.getRect(slider);
    await tester
        .tapAt(Offset(bounds.left + bounds.width * .8, bounds.center.dy));
    await tester.pumpAndSettle();
    expect(seekTarget, isNotNull);
    expect(seekTarget!.inSeconds, greaterThanOrEqualTo(7));
  });

  testWidgets('shows loading then a playback error and retry action',
      (tester) async {
    final gate = Completer<Story?>();
    var renewCalls = 0;
    await tester.pumpWidget(MaterialApp(
      home: StoryViewerScreen(
          stories: [story('a', 'Story A')],
          initialIndex: 0,
          renewStory: (_) {
            renewCalls++;
            return gate.future;
          }),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gate.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('This story could not be played.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(renewCalls, 2);
    expect(find.text('This story could not be played.'), findsOneWidget);
  });

  testWidgets('next and previous controls navigate across available stories',
      (tester) async {
    final stories = [story('a', 'Story A'), story('b', 'Story B')];
    await tester.pumpWidget(MaterialApp(
      home: StoryViewerScreen(
          stories: stories, initialIndex: 0, renewStory: (_) async => null),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Story A'), findsOneWidget);
    await tester.tap(find.byTooltip('Next story'));
    await tester.pumpAndSettle();
    expect(find.text('Story B'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous story'));
    await tester.pumpAndSettle();
    expect(find.text('Story A'), findsOneWidget);
  });
}
