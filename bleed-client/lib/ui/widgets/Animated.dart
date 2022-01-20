

import 'dart:async';

import 'package:flutter/cupertino.dart';

class Animated extends StatefulWidget {

  final Duration frameDuration;
  final Widget Function() build;

  Animated({required this.build, required this.frameDuration});

  @override
  State<Animated> createState() => _AnimatedState();
}

class _AnimatedState extends State<Animated> {

  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(widget.frameDuration, (timer) {
        setState(() {

        });
    });
  }


  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.build();
  }
}