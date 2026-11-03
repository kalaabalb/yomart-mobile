import 'package:flutter/material.dart';

class LTRTextDirection extends StatelessWidget {
  final Widget child;

  const LTRTextDirection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: child);
  }
}
