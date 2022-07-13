import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_scene_meta_data_player_is_owner.dart';
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
      buildWatchSceneMetaDataPlayerIsOwner(),
      buildWatchDebugVisible(),
    ],
  );
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
