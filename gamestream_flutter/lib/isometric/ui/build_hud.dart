import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_tabs_player_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_watch_play_mode.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:lemon_engine/screen.dart';

import '../../flutterkit.dart';


Widget buildHud() {
  return Stack(
    children: [
      buildWatchPlayMode(),
      visibleBuilder(
          sceneMetaDataPlayerIsOwner,
          Positioned(
              bottom: 6,
              left: 0,
              child: Container(
                  width: screen.width,
                  child: buildTabsPlayMode()
              )
          )
      ),
    ],
  );
}
