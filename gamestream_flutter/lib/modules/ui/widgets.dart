
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/assets.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:lemon_watch/watch_builder.dart';


class UIWidgets {
  final title = Row(
    mainAxisAlignment: MainAxisAlignment.center,
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

  final saveCharacter = button("Save", sendRequestCharacterSave);
  final loadCharacter = button("Load", sendRequestCharacterLoad);

  final time = Row(
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