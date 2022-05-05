import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/functions/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildTime(){
  return Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(modules.isometric.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(modules.isometric.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );
}
