import 'package:flutter/material.dart';
import 'package:lemon_watch/src.dart';

Widget buildWatchNullable<T>(
    Watch<T?> watch,
    Widget Function(T t) builder,
) =>
    WatchBuilder(watch, (T? value) =>
      value == null
          ? const SizedBox()
          : builder(value));
