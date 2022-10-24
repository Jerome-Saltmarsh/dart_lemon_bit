import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_debug.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_game_type_skirmish.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_player_alive.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_scene_meta_data_player_is_owner.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/game_map.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'isometric/ui/dialogs/build_game_dialog.dart';
import 'ui/builders/build_panel_menu.dart';

class GameUI {
  static final messageBoxVisible = Watch(false, clamp: (bool value){
    if (GameState.gameType.value == GameType.Skirmish) return false;
    return value;
  }, onChanged: onVisibilityChangedMessageBox);
  static final canOpenMapAndQuestMenu = Watch(false);
  static final textEditingControllerMessage = TextEditingController();
  static final textFieldMessage = FocusNode();
  static final debug = Watch(false);
  static final panelTypeKey = <int, GlobalKey> {};
  static final playerTextStyle = TextStyle(color: Colors.white);
  static final mapVisible = Watch(false);
  static final timeVisible = Watch(true);

  static Widget build()  =>
      Container(
        width: Engine.screen.width,
        height: Engine.screen.height,
        child: Stack(
          children: [
            watch(GameState.player.message, (String message) =>
                Positioned(
                  bottom: 64,
                  left: 0,
                  child: message.isEmpty
                      ? const SizedBox()
                      : Container(
                      width: Engine.screen.width,
                      alignment: Alignment.center,
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white10,
                          child: text(message)
                      )
                  ),
                )
            ),
            buildWatchBool(GameState.triggerAlarmNoMessageReceivedFromServer, buildDialogFramesSinceUpdate),
            watch(GameState.gameType, buildGameTypeUI),
            watch(GameState.player.gameDialog, buildGameDialog),
            buildWatchBool(GameState.player.alive, buildContainerRespawn, false),
            buildTopRightMenu(),
            buildWatchBool(GameUI.mapVisible, buildMiniMap),
            watch(GameState.edit, buildPlayMode),
            buildWatchBool(debugVisible, buildHudDebug),
            // https://stackoverflow.com/questions/67147229/how-can-i-detect-multiple-touches-in-flutter
            // Positioned(
            //     bottom: 0,
            //     left: 0,
            //     child: Builder(
            //         builder: (context) {
            //           const size = 150.0;
            //           const sizeThird = size / 3;
            //           return Container(
            //             width: size,
            //             height: size,
            //             color: Colors.orange,
            //             child: Stack(
            //               children: [
            //                 Positioned(
            //                     top: 0,
            //                     left: sizeThird,
            //                     child: onPressed(
            //                         action: () => Touchscreen.direction = Direction.North_East,
            //                         child: Container(width: sizeThird, height: sizeThird, color: Colors.blue,))
            //                 ),
            //                 Positioned(
            //                     top: sizeThird,
            //                     left: 0,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.blue, action: (){
            //                       Touchscreen.direction = Direction.North_West;
            //                     })
            //                 ),
            //                 Positioned(
            //                     top: sizeThird,
            //                     right: 0,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.blue, action: (){
            //                       Touchscreen.direction = Direction.South_East;
            //                     })
            //                 ),
            //                 Positioned(
            //                     bottom: 0,
            //                     left: sizeThird,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.blue, action: (){
            //                       Touchscreen.direction = Direction.South_West;
            //                     })
            //                 ),
            //                 Positioned(
            //                     bottom: sizeThird,
            //                     left: sizeThird,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.green, action: (){
            //                       Touchscreen.direction = Direction.None;
            //                     })
            //                 ),
            //                 Positioned(
            //                     top: 0,
            //                     left: 0,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.orange, action: (){
            //                       Touchscreen.direction = Direction.North;
            //                     })
            //                 ),
            //                 Positioned(
            //                     top: 0,
            //                     right: 0,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.orange, action: (){
            //                       Touchscreen.direction = Direction.East;
            //                     })
            //                 ),
            //                 Positioned(
            //                     bottom: 0,
            //                     right: 0,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.orange, action: (){
            //                       Touchscreen.direction = Direction.South;
            //                     })
            //                 ),
            //                 Positioned(
            //                     bottom: 0,
            //                     left: 0,
            //                     child: container(width: sizeThird, height: sizeThird, color: Colors.orange, action: (){
            //                       Touchscreen.direction = Direction.West;
            //                     })
            //                 ),
            //               ],
            //             ),
            //           );
            //         }
            //     )
            // ),
          ],
        ),
      );



  static Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: watch(GameState.rendersSinceUpdate,  (int frames) =>
          text("Warning: No message received from server $frames")
      )
  );

  static Positioned buildWatchInterpolation() =>
      Positioned(
        bottom: 0,
        left: 0,
        child: watch(GameState.player.interpolating, (bool value) {
          if (!value) return text("Interpolation Off", onPressed: () => GameState.player.interpolating.value = true);
          return watch(GameState.rendersSinceUpdate, (int frames){
            return text("Frames: $frames", onPressed: () => GameState.player.interpolating.value = false);
          });
        }),
      );

  static Widget buildGameTypeUI(int? gameType) {
    switch (gameType) {
      case GameType.Dark_Age:
        return buildStackGameTypeDarkAge();
      case GameType.Skirmish:
        return buildStackGameTypeSkirmish();
      default:
        return const SizedBox();
    }
  }

  static Positioned buildMiniMap() =>
      Positioned(
        left: 6,
        top: 6,
        child: onPressed(
          action: GameState.actionGameDialogShowMap,
          child: Container(
              padding: const EdgeInsets.all(4),
              color: brownDark,
              child: GameMapWidget(width: 133, height: 133)),
        ),
      );

  static Widget buildContainerQuestUpdated() =>
      Container(
        width: Engine.screen.width,
        alignment: Alignment.topCenter,
        child: container(
            child: "QUEST UPDATED",
            alignment: Alignment.center,
            color: Colors.green,
            width: 200,
            margin: EdgeInsets.only(top: 16),
            action: GameState.actionGameDialogShowQuests),
      );

  static Positioned buildTopRightMenu() =>
      Positioned(top: 0, right: 0, child: buildPanelMenu());

  static Widget buildControlsEnvironment() =>
    visibleBuilder(
      GameEditor.controlsVisibleWeather,
      Container(
        width: Engine.screen.width,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlsWeather(),
          ],
        ),
      ),
    );

  static Widget buildStackGameTypeDarkAge() =>
      Stack(
        children: [
          Positioned(left: 8, bottom: 50, child: buildColumnTeleport()),
          buildBottomPlayerExperienceAndHealthBar(),
          buildWatchBool(GameState.player.questAdded, buildContainerQuestUpdated),
        ],
      );
}