import 'package:e_commerce_flutter/utility/first_frame_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _AnimatedOnEntry extends StatefulWidget {
  const _AnimatedOnEntry();

  @override
  State<_AnimatedOnEntry> createState() => _AnimatedOnEntryState();
}

class _AnimatedOnEntryState extends State<_AnimatedOnEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    startAnimationAfterFirstFrame(controller, isMounted: () => mounted);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Text(
          controller.value.toStringAsFixed(2),
          key: const ValueKey('entry-animation-progress'),
        ),
      );
}

void main() {
  testWidgets('entry animation starts on its first frame without navigation',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _AnimatedOnEntry()));
    // The post-frame callback starts the ticker at the end of the first frame;
    // pump a zero-duration frame to establish its start timestamp first.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final progress = double.parse(
      tester
          .widget<Text>(find.byKey(const ValueKey('entry-animation-progress')))
          .data!,
    );
    expect(progress, greaterThan(0));
  });
}
