


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_tabs_player_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_watch_play_mode.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/screen.dart';

final menu = buildPanelMenu();


Widget buildHud() {
  return Stack(
    children: [
      buildWatchPlayMode(),
      Positioned(
          bottom: 6,
          left: 0,
          child: Container(
              width: screen.width,
              child: buildTabsPlayMode())),
    ],
  );
}