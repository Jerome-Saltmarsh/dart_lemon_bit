import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/colors.dart';

Widget buildTogglePlayEdit(){
  return watch(playMode, (mode) {
    return container(
      child: mode == PlayMode.Play ? "Edit" : "Play",
      width: 100,
      alignment: Alignment.center,
      color: grey,
      action: playModeToggle,
    );
  });

}
