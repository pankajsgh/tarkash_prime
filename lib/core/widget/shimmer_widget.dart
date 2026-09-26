import 'package:flutter/material.dart';

class ShimmerWidget extends StatefulWidget {
  final Widget child;

  const ShimmerWidget({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerWidget> createState() =>
      _ShimmerWidgetState();
}

class _ShimmerWidgetState
    extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(
                -1.0 + controller.value * 2,
                0,
              ),
              end: Alignment(
                1.0 + controller.value * 2,
                0,
              ),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: const [
                0.1,
                0.3,
                0.4,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}