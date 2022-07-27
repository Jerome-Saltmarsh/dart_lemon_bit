import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_show_game_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/modules/core/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';

import '../widgets/build_container.dart';

Widget buildPlayMode(PlayMode playMode) {
  final edit = playMode == PlayMode.Edit;
    return Stack(
      children: [
        if (edit)
        Positioned(
          left: 0,
          bottom: 6,
          child: buildWatchEditorTab(),
        ),
        if (edit)
        Positioned(
            bottom: 6,
            left: 0,
            child: buildControlsEnvironment()
        ),
        if (edit)
        Positioned(
          left: 0,
          top: 0,
          child: buildTopLeftMenu(),
        )
      ],
    );
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
                        container(child: "New", color: brownLight, action: (){
                          core.actions.exitGame();
                          connectToGameEditor();
                        }, hoverColor: brownDark),
                        container(child: "Save", color: brownLight, action: actionGameDialogShowSceneSave, hoverColor: brownDark),
                        container(child: "Load", color: brownLight, action: actionGameDialogShowSceneLoad, hoverColor: brownDark),
                        container(child: "Exit", color: brownLight, action: core.actions.exitGame, hoverColor: brownDark),
                      ],
                    );
                  }
                  return container(child: "File", color: brownLight);
                }
            ),
            onMouseOver(
              builder: (context, over) {
                if (over){
                  return Column(
                    children: [
                      container(child: "Edit", color: brownLight),
                      container(child: "Canvas Size", color: brownLight, hoverColor: brownDark, action: actionGameDialogEditCanvasSizeShow),
                      container(child: "Floor Bricks", color: brownLight, hoverColor: brownDark, action: edit.paintFloorBricks),
                    ],
                  );
                }

                return container(child: "Edit", color: brownLight);
              }
            ),
            onMouseOver(
              builder: (context, over) {
                if (over){
                  return Column(
                    children: [
                      container(child: "View", color: brownLight),
                      container(child: "Weather", color: brownLight, hoverColor: brownDark, action: edit.actionToggleControlsVisibleWeather),
                      container(child: "Grid", color: brownLight, hoverColor: brownDark),
                    ],
                  );
                }
                return container(child: "View", color: brownLight);
              }
            ),
          ],
        );
}
