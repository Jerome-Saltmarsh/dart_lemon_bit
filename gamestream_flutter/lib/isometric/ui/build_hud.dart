


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_watch_play_mode.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';
import 'package:lemon_watch/watch.dart';

final menu = buildPanelMenu();


Widget buildHud() {
  return buildWatchPlayMode();
  // return Stack(children: [
  //   Positioned(right: 0, top: 0, child: buildPanelMenu()),
  //   buildPanelWriteMessage(),
  //   Positioned(
  //     top: 0,
  //     left: 0,
  //     child: ,
  //   ),
  // ]);
}