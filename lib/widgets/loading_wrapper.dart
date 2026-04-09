import 'package:flutter/material.dart';

class LoadingWrapper extends StatelessWidget {
  final bool isLoaded;
  final Widget child;

  const LoadingWrapper({
    super.key,
    required this.isLoaded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}