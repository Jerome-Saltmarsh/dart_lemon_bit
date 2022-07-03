import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/build_watch_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_show_dialog_load_scene.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_toggle_play_edit.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/screen.dart';

import '../../flutterkit.dart';
import 'buttons/build_button_show_dialog_save_scene.dart';


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
          watch(storeVisible, (bool inventoryVisible){
              if (inventoryVisible) return const SizedBox();
              return Positioned(
                  top: 6,
                  left: 0,
                  child: Container(
                    width: screen.width,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildButtonShowDialogLoadScene(),
                        width4,
                        buildButtonShowDialogSaveScene(),
                      ],
                    ),
                  )
              );
          }),
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