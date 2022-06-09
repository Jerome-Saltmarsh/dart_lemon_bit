import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildTime(){
  return Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(game.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(game.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );
}
