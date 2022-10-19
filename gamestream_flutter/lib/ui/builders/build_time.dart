import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildTime(){
  return Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(Game.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(Game.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );
}
