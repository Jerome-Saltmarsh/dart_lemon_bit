
import 'package:lemon_watch/watch_builder.dart';
import 'package:bleed_client/assets.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:flutter/material.dart';


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

  final time = Tooltip(
    message: "Time",
    child: WatchBuilder(isometric.state.time, (int value) {
      return text("${padZero(modules.game.properties.timeInHours)} : ${padZero(modules.game.properties.timeInMinutes % 60)} ${isometric.properties.phase.name}");
    }),
  );

  final exit = button("Exit", core.actions.disconnect);

}