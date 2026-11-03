import 'dart:async';

import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/login_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.holdAtSplash = false});

  final bool holdAtSplash;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.holdAtSplash) _startContinueTimer();
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdAtSplash && !widget.holdAtSplash) {
      _startContinueTimer();
    }
  }

  void _startContinueTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1650), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final user = context.read<UserProvider>().getLoginUsr();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            user?.sId != null ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 260),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF000000),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 680;
                  return Column(
                    children: [
                      SizedBox(
                          height:
                              constraints.maxHeight * (compact ? 0.14 : 0.24)),
                      Image.asset(
                        'assets/images/logo_rounded.png',
                        width: 76,
                        height: 76,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'YoMart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 36 : 42,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        context.l10n.brand_tagline,
                        style: TextStyle(
                          color: const Color(0xFFB8C2D0),
                          fontSize: compact ? 18 : 22,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.08),
                      Image.asset(
                        'assets/images/splash_phones_reference.png',
                        width: constraints.maxWidth * 0.55,
                        height: constraints.maxHeight * (compact ? 0.3 : 0.4),
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
