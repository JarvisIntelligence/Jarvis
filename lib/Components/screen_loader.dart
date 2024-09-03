import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key, required this.progressVisible});

  final bool progressVisible;

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: widget.progressVisible,
        child: Container(
          color: Colors.black87,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Lottie.asset('assets/lottie_animations/loading_animation.json', width: 80),
          ),
        )
    );
  }
}
