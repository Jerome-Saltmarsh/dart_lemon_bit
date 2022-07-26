import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_map.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_scene_meta_data_player_is_owner.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/game_map.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/screen.dart';

import 'watches/build_watch_debug_visible.dart';
import 'watches/build_watch_player_alive.dart';

Widget buildHud() {
  return Stack(
    children: [
      buildWatchEditorDialog(),
      watch(player.gameDialog, buildGameDialog),
      Container(
        width: screen.width,
        height: screen.height,
        alignment: Alignment.center,
        child: buildWatchPlayerAlive(),
      ),
      buildWatchPlayMode(),
      buildTopRightMenu(),
      Positioned(left: 0, top: 0, child: GameMapWidget(100, 100)),
      buildWatchSceneMetaDataPlayerIsOwner(),
      buildWatchDebugVisible(),
      buildControlQuestUpdated()
    ],
  );
}

Widget buildControlQuestUpdated() {
  return visibleBuilder(
        player.questAdded,
        Container(
          width: screen.width,
          alignment: Alignment.topCenter,
          child: container(
              child: "QUEST UPDATED",
              alignment: Alignment.center,
              color: green,
              width: 200,
              margin: EdgeInsets.only(top: 16),
              action: actionGameDialogShowQuests),
        ));
}

Positioned buildTopRightMenu() =>
    Positioned(top: 0, right: 0, child: buildPanelMenu());

Widget buildControlsEnvironment() {
  return visibleBuilder(
      edit.controlsVisibleWeather,
      Container(
        width: screen.width,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlsWeather(),
          ],
        ),
      ),
  );
}
