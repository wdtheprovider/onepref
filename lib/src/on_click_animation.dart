import 'package:flutter/material.dart';

/// A widget that wraps a [child] with a subtle press-scale animation.
///
/// When tapped, the [child] scales down to 95 % and back before invoking
/// [onTap], giving a tactile feel without relying on third-party packages.
///
/// ```dart
/// OnClickAnimation(
///   onTap: () => debugPrint('tapped'),
///   child: ElevatedButton(
///     onPressed: null,
///     child: Text('Buy Now'),
///   ),
/// )
/// ```
class OnClickAnimation extends StatefulWidget {
  /// The widget to animate on press.
  final Widget child;

  /// Called after the press animation completes.
  final VoidCallback onTap;

  /// Creates an [OnClickAnimation].
  const OnClickAnimation({super.key, required this.child, required this.onTap});

  @override
  State<OnClickAnimation> createState() => _OnClickAnimationState();
}

class _OnClickAnimationState extends State<OnClickAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> easeInAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1.0,
    );
    easeInAnimation = Tween(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.forward().then((_) {
          controller.reverse().then((_) {
            widget.onTap();
          });
        });
      },
      child: ScaleTransition(scale: easeInAnimation, child: widget.child),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
