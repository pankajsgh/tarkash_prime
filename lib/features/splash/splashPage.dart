import 'package:calculation_panel/features/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'dart:async';

import '../../core/routes/routes.dart';
import '../../core/theme/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final controller = SplashController();

  late AnimationController logoController;
  late AnimationController textController;
  late AnimationController pulseController;

  late Animation<double> logoScale;
  late Animation<double> textOpacity;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();

    /// LOGO ANIMATION
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// TEXT ANIMATION
    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    /// PULSE ANIMATION
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    logoScale = CurvedAnimation(
      parent: logoController,
      curve: Curves.elasticOut,
    );

    textOpacity = CurvedAnimation(parent: textController, curve: Curves.easeIn);

    pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    startAnimation();
  }

  Future<void> startAnimation() async {
    await logoController.forward();

    textController.forward();

    await controller.checkLogin();

    if (!mounted) return;

    if (controller.isLogin) {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  void dispose() {
    logoController.dispose();
    textController.dispose();
    pulseController.dispose();
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryAppColor,
        ),

        child: Stack(
          children: [
            /// TOP RIGHT CIRCLE
            Positioned(
              top: -80,
              right: -50,
              child: Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            /// BOTTOM LEFT CIRCLE
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            /// CONTENT
            Center(
              child: ListenableBuilder(
                listenable: controller,

                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      /// ANIMATED LOGO
                      ScaleTransition(
                        scale: logoScale,

                        child: AnimatedBuilder(
                          animation: pulseAnimation,

                          builder: (context, child) {
                            return Transform.scale(
                              scale: pulseAnimation.value,

                              child: Container(
                                height: 110,
                                width: 110,

                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .15),

                                  borderRadius: BorderRadius.circular(32),

                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .2),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .12),

                                      blurRadius: 25,

                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),

                                child: const Icon(
                                  Icons.business,

                                  color: Colors.white,

                                  size: 58,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// APP NAME
                      FadeTransition(
                        opacity: textOpacity,
                        child: const Text(
                          appName,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// SUBTITLE
                      FadeTransition(
                        opacity: textOpacity,
                        child: Text(
                          "Smart Business Management",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(.85),
                            letterSpacing: .5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

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
