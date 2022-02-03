
import 'package:lemon_watch/watch.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_watch/watch_builder.dart';
import 'flutterkit.dart';

/// builds a basic watch builder presenting the value as a text
Widget textWatch<T>(Watch<T> watch){
  return WatchBuilder<T>(watch, (T emeralds){
    return text(emeralds);
  });
}