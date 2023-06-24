import 'package:flutter/material.dart';
import 'package:lemon_watch/src.dart';

Widget buildWatch<T>(Watch<T> watch, Widget Function(T t) builder) => WatchBuilder(watch, builder);






