import 'package:bleed_common/GameType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_map.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_game_type_waves.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_player_alive.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_scene_meta_data_player_is_owner.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/game_map.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/screen.dart';

import 'build_hud_debug.dart';
import 'stacks/build_stack_game_type_world.dart';

Widget buildGameUI()  =>
  Stack(
    children: [
      watch(gameType, buildGameTypeUI),
      watch(editorDialog, buildWatchEditorDialog),
      watch(player.gameDialog, buildGameDialog),
      buildWatchBool(player.alive, buildContainerRespawn, false),
      buildTopRightMenu(),
      buildWatchBool(modules.game.state.mapVisible, buildMiniMap),
      watch(playMode, buildPlayMode),
      buildWatchBool(debugVisible, buildHudDebug),
      buildWatchBool(player.questAdded, buildContainerQuestUpdated),
    ],
  );

Widget buildGameTypeUI(int? gameType) {
   switch (gameType) {
     case GameType.Waves:
       return buildStackGameTypeWavesUI();
     case GameType.Dark_Age:
       return buildStackGameTypeWorld();
     default:
       return const SizedBox();
   }
}

Positioned buildMiniMap() =>
  Positioned(
    left: 6,
    top: 6,
    child: onPressed(
      action: actionGameDialogShowMap,
      child: Container(
          padding: const EdgeInsets.all(4),
          color: brownDark,
          child: GameMapWidget(width: 133, height: 133)),
    ),
  );

Widget buildContainerQuestUpdated() =>
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
  );

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
