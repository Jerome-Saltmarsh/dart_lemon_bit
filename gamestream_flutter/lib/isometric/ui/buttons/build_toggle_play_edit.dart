import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/colors.dart';
import 'package:lemon_engine/screen.dart';

Widget buildTogglePlayEdit(){
  return watch(playMode, (mode) {
    return Container(
      width: screen.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (mode == PlayMode.Edit)
          container(
              child: "Play",
              width: 100,
              alignment: Alignment.center,
              color: grey,
              action: setPlayModePlay,
          ),
          if (mode == PlayMode.Play)
          container(
              child: "Edit",
              width: 100,
              alignment: Alignment.center,
              color: grey,
              action: setPlayModeEdit,
          ),
        ],
      ),
    );
  });

}
