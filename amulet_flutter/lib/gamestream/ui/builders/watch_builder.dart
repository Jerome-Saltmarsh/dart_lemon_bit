

import 'package:flutter/cupertino.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:lemon_watch/src.dart';

class WatchBuilder<T> extends StatelessWidget {

  final Watch<T> watch;
  final Function(BuildContext context, T value) builder;

  const WatchBuilder({super.key, required this.watch, required this.builder});

  @override
  Widget build(BuildContext context) {
    return buildWatch(watch, (t) => builder(context, t));
  }
}