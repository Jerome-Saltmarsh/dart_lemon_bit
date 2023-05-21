import 'package:flutter/material.dart';

class Animated extends StatefulWidget {
  final Duration duration;
  final Widget Function(double opacity) builder;

  const Animated({
  required this.duration,
  required this.builder,
  super.key,
});

  @override
  State<Animated> createState() => _AnimatedState();
}

class _AnimatedState extends State<Animated>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) =>
          widget.builder(_controller.value),
    );
  }
}
