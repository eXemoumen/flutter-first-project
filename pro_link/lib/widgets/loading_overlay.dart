import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: Shimmer.fromColors(
                baseColor: Colors.white38,
                highlightColor: Colors.white70,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
