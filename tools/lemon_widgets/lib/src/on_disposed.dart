

import 'package:flutter/material.dart';

class OnDisposed extends StatefulWidget {

  final Function? action;
  final Widget child;

  const OnDisposed({super.key, required this.child, this.action});

  @override
  State<OnDisposed> createState() => _OnDisposedState();
}

class _OnDisposedState extends State<OnDisposed> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.action?.call();
    super.dispose();
  }


}