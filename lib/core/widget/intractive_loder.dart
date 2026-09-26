import 'dart:math' as math;
import 'package:flutter/material.dart';

class InteractiveLoadingView extends StatefulWidget {
  const InteractiveLoadingView({super.key});

  @override
  State<InteractiveLoadingView> createState() =>
      _InteractiveLoadingViewState();
}

class _InteractiveLoadingViewState extends State<InteractiveLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  26,
                  22,
                  26,
                  20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xffE9EEF1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -------------------------------------------------------
                    // LOADING ICON
                    // -------------------------------------------------------
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: CustomPaint(
                              size: const Size(56, 56),
                              painter: _LoadingRingPainter(),
                            ),
                          ),

                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xff0D7894),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff0D7894)
                                      .withValues(alpha: 0.20),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 13),


                    Text(
                      'Please wait a moment',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// LOADING RING
// ============================================================================

class _LoadingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 3;

    final trackPaint = Paint()
      ..color = const Color(0xffE8EEF0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final progressPaint = Paint()
      ..color = const Color(0xff0D7894)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    // Progress section
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 0.72,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
