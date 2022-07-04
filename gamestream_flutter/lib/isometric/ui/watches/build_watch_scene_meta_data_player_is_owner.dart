import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_show_dialog_load_scene.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_edit_z.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:lemon_engine/screen.dart';

import '../buttons/build_button_show_dialog_save_scene.dart';

Widget buildWatchSceneMetaDataPlayerIsOwner() {
  return watch(sceneMetaDataPlayerIsOwner, (bool playerIsOwner) {
    if (!playerIsOwner) return const SizedBox();

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: buildWatchEditorTab(),
        ),
        // Positioned(
        //     right: 0,
        //     top: 50,
        //     child: buildPanelMaxZRender(),
        // ),
        Positioned(
          right: 0,
          top: 50,
          child: buildControlEditZ(),
        ),
        // Positioned(
        //   right: 0,
        //   top: screen.height / 2,
        //   child: buildWatchEditorSelectedObject(),
        // ),
        Positioned(
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
            )),
        Positioned(
            bottom: 6,
            left: 0,
            child: buildControlsEnvironment()
        ),
      ],
    );
  });
}
