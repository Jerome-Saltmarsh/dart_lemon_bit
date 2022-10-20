import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildTime(){
  return Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(GameState.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(GameState.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );
}
