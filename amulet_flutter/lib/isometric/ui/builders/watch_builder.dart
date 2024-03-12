//
//
// import 'package:flutter/cupertino.dart';
// import 'package:lemon_watch/src.dart';
//
// import 'build_watch.dart';
//
// class WatchBuilder<T> extends StatelessWidget {
//
//   final Watch<T> watch;
//   final Function(BuildContext context, T value) builder;
//
//   const WatchBuilder({super.key, required this.watch, required this.builder});
//
//   @override
//   Widget build(BuildContext context) {
//     return buildWatch(watch, (t) => builder(context, t));
//   }
// }