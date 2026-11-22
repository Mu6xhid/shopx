import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_theme.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _xController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _xScaleAnimation;
  late Animation<Color?> _xColorAnimation;
  late Animation<double> _xWeightAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _xController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
    );

    _xScaleAnimation = Tween<double>(
      begin: 1,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _xController, curve: Curves.easeOutBack));

    _xColorAnimation = ColorTween(
      begin: Colors.white,
      end: AppColors.primary,
    ).animate(CurvedAnimation(parent: _xController, curve: Curves.easeInOut));

    _xWeightAnimation = Tween<double>(
      begin: 300,
      end: 900,
    ).animate(CurvedAnimation(parent: _xController, curve: Curves.easeInOut));

    _startAnimation();

    _navigationTimer = Timer(
      const Duration(milliseconds: 3500),
      _navigateBasedOnAuth,
    );
  }

  Future<void> _navigateBasedOnAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  Future<void> _startAnimation() async {
    await _animationController.forward();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    await _xController.forward();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    _xController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _xController,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'SHOP',
                          style: TextStyle(
                            color: Color(0xFFF4F1E9),
                            fontSize: 38,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 11,
                          ),
                        ),
                        Transform.scale(
                          scale: _xScaleAnimation.value,
                          child: Text(
                            'X',
                            style: TextStyle(
                              color: _xColorAnimation.value,
                              fontSize: 38,
                              fontWeight:
                                  FontWeight.values[(_xWeightAnimation.value /
                                              100)
                                          .round()
                                          .clamp(3, 9) -
                                      1],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 100 * _lineAnimation.value,
                      height: 1,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    );
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'THE ART OF EVERYDAY STYLE',
                  style: TextStyle(
                    color: Color(0xFF85858A),
                    fontSize: 9,
                    letterSpacing: 3.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
