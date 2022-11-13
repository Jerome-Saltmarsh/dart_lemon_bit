import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';

Widget buildTime(){
  return Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(ServerState.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(ServerState.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );
}
