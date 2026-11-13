import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';

/// Starts an entrance/transition animation after the first layout without
/// waiting for a later route or tab change to trigger it.
void startAnimationAfterFirstFrame(
  AnimationController controller, {
  required bool Function() isMounted,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (isMounted()) controller.forward(from: 0);
  });
}
