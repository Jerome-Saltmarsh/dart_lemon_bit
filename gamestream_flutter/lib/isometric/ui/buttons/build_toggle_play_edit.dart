import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

Widget buildTogglePlayEdit(){
  return watch(playMode, (mode) {
    return container(
      child: mode == PlayMode.Play ? "Edit" : "Play",
      width: 100,
      alignment: Alignment.center,
      color: grey,
      action: actionPlayModeToggle,
    );
  });

}
