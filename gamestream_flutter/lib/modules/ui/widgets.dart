
import 'package:gamestream_flutter/assets.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
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

  final saveCharacter = button("Save", sendRequestCharacterSave);
  final loadCharacter = button("Load", sendRequestCharacterLoad);

  final time = Row(
    children: [
      // text("Time"),
      // width8,
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