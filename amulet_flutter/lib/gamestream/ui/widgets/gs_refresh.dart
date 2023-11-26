import 'dart:async';

import 'package:flutter/material.dart';

typedef RefreshBuilder = Widget Function();
typedef WidgetFunction = Widget Function();

class GSRefresh extends StatefulWidget {
  final RefreshBuilder builder;
  late final Duration duration;

  GSRefresh(this.builder, {int seconds = 0, int milliseconds = 100}) {
    this.duration = Duration(seconds: seconds, milliseconds: milliseconds);
  }

  @override
  _GSRefreshState createState() => _GSRefreshState();
}

class _GSRefreshState extends State<GSRefresh> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(widget.duration, (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder();

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
}
