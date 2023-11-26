import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildTime(){
  return Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );
}
