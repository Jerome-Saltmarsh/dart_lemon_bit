
import 'package:bleed_client/assets.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';


class UIWidgets {
  final title = Row(
    children: [
      text("GAME",
          size: 60,
          color: Colors.white,
          family: assets.fonts.libreBarcode39Text
      ),
      text("STREAM",
        size: 60,
        color: colours.red,
        family: assets.fonts.libreBarcode39Text,
      ),
    ],
  );

  final exit = button("Exit", core.actions.disconnect);

  final time = Row(
    children: [
      text("Time "),
      WatchBuilder(modules.isometric.state.hours, (int hours){
        return text(padZero(hours));
      }),
      text(":"),
      WatchBuilder(modules.isometric.state.minutes, (int minutes){
        return text(padZero(minutes));
      }),
    ],
  );

}