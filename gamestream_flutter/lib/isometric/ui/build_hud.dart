


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_watch_play_mode.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';

final menu = buildPanelMenu();


Widget buildHud() {
  return buildWatchPlayMode();
  // return Stack(children: [
  //   Positioned(right: 0, top: 0, child: buildPanelMenu()),
  //   ,
  //   Positioned(
  //     top: 0,
  //     left: 0,
  //     child: ,
  //   ),
  // ]);
}