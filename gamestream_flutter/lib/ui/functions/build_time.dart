import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildTime(){
  return Row(
    children: [
      WatchBuilder(modules.isometric.hours, (int hours){
        return text(padZero(hours));
      }),
      text(":"),
      WatchBuilder(modules.isometric.minutes, (int minutes){
        return text(padZero(minutes));
      }),
    ],
  );
}
