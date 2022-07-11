import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_edit_z.dart';
import 'package:gamestream_flutter/isometric/ui/tabs/build_tab_edit_tool.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';

import '../widgets/build_container.dart';

Widget buildWatchSceneMetaDataPlayerIsOwner() {
  return watch(sceneMetaDataPlayerIsOwner, (bool playerIsOwner) {
    if (!playerIsOwner) return const SizedBox();

    return Stack(
      children: [
        Positioned(
          left: 0,
          bottom: 6,
          child: buildWatchEditorTab(),
        ),
        Positioned(
          right: 0,
          top: 50,
          child: buildControlEditZ(),
        ),
        Positioned(
          right: 50,
          top: 50,
          child: buildTabEditTool(),
        ),
        Positioned(
            bottom: 6,
            left: 0,
            child: buildControlsEnvironment()
        ),
        Positioned(
          left: 0,
          top: 0,
          child: buildTopLeftMenu(),
        )
      ],
    );
  });
}

Row buildTopLeftMenu() {
  return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            onMouseOver(
                builder: (context, over) {
                  if (over){
                    return Column(
                      children: [
                        container(child: "File", color: brownLight),
                        container(child: "New", color: brownLight),
                        container(child: "Save", color: brownLight, action: actionGameDialogShowSceneSave),
                        container(child: "Load", color: brownLight, action: actionGameDialogShowSceneLoad),
                      ],
                    );
                  }
                  return container(child: "File", color: brownLight);
                }
            ),
            container(child: "Canvas", color: brownLight),
          ],
        );
}
