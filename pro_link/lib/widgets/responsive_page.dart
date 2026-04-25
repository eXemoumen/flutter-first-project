import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 980,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = switch (constraints.maxWidth) {
          < 600 => 12.0,
          < 900 => 16.0,
          < 1200 => 20.0,
          _ => 28.0,
        };
        final vertical = constraints.maxWidth < 600 ? 12.0 : 16.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

