import 'package:flutter/material.dart';

/// A reusable widget that displays a single benefit/feature row.
///
/// Typically used inside a paywall or subscription screen to list the
/// advantages of upgrading.
///
/// ```dart
/// Benefit(
///   icon: Icons.star,
///   title: 'Unlimited access',
///   iconColor: Colors.white,
///   iconBackgroundColor: Colors.orange,
/// )
/// ```
class Benefit extends StatelessWidget {
  /// The label displayed to the right of the icon.
  final String title;

  /// The icon shown inside the coloured container on the left.
  final IconData icon;

  /// Horizontal gap between the icon container and [title]. Defaults to `20`.
  final double? spaceBetween;

  /// Size of the [icon] in logical pixels. Defaults to `20`.
  final double? iconSize;

  /// Colour of the [icon]. Defaults to [Colors.white].
  final Color? iconColor;

  /// Background colour of the icon container. Defaults to [Colors.orange].
  final Color? iconBackgroundColor;

  /// Text style applied to [title]. Uses the ambient theme style when `null`.
  final TextStyle? titleStyle;

  /// Creates a [Benefit] row widget.
  const Benefit({
    super.key,
    required this.title,
    required this.icon,
    this.iconSize,
    this.iconColor,
    this.iconBackgroundColor,
    this.spaceBetween,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: iconBackgroundColor ?? Colors.orange,
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: iconSize ?? 20,
          ),
        ),
        SizedBox(width: spaceBetween ?? 20),
        Text(title, style: titleStyle),
      ],
    ),
  );
}
