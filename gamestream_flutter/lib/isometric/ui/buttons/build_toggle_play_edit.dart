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
          container(
              child: "Play",
              width: 100,
              alignment: Alignment.center,
              color: mode == PlayMode.Play ? greyDark : grey,
              action: setPlayModePlay,
          ),
          container(
              child: "Edit",
              width: 100,
              alignment: Alignment.center,
              color: mode == PlayMode.Edit ? greyDark : grey,
              action: setPlayModeEdit,
          ),
        ],
      ),
    );
  });

}
