

import 'package:flutter/material.dart';

class OnDisposed extends StatefulWidget {

  final Function onDisposed;
  final Widget child;

  const OnDisposed({super.key, required this.child, required this.onDisposed});

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
    widget.onDisposed();
    super.dispose();
  }


}