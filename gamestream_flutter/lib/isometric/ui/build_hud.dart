import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/build_watch_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_toggle_play_edit.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/screen.dart';

import '../../flutterkit.dart';


Widget buildHud() {
  return Stack(
    children: [
      buildWatchPlayMode(),
      Positioned(top: 0, right: 0, child: buildPanelMenu()),
      visibleBuilder(
        sceneMetaDataPlayerIsOwner,
        Positioned(
            left: 0,
            top: 0,
            child: buildColumnEditTile(),
        ),
      ),
      visibleBuilder(
          sceneMetaDataPlayerIsOwner,
          Positioned(
              top: 6,
              left: 0,
              child: buildTogglePlayEdit()
          ),
      ),
      visibleBuilder(
        sceneMetaDataPlayerIsOwner,
        Positioned(
            bottom: 6,
            left: 0,
            child: buildControlsEnvironment()
        ),
      ),
    ],
  );
}

Widget buildControlsEnvironment(){
   return Container(
       width: screen.width,
       alignment: Alignment.center,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           buildControlsWeather(),
         ],
       ),
   );
}