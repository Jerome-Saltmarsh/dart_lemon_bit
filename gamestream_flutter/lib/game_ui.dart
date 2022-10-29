import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_game_type_skirmish.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_player_alive.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_scene_meta_data_player_is_owner.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/game_map.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_ui_config.dart';
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
            watch(GameState.player.message, buildPlayerMessage),
            buildWatchBool(GameState.triggerAlarmNoMessageReceivedFromServer, buildDialogFramesSinceUpdate),
            watch(GameState.gameType, buildGameTypeUI),
            watch(GameState.player.gameDialog, buildGameDialog),
            buildWatchBool(GameState.player.alive, buildContainerRespawn, false),
            buildTopRightMenu(),
            buildWatchBool(GameUI.mapVisible, buildMiniMap),
            watch(GameState.edit, buildPlayMode),
            watch(GameIO.inputMode, buildStackInputMode),
            buildWatchBool(GameState.debugVisible, GameDebug.buildStackDebug),
          ],
        ),
      );

  static Widget buildStackInputMode(int inputMode) =>
      inputMode == InputMode.Keyboard
          ? const SizedBox()
          : Stack(children: [
              Positioned(
                bottom: 16,
                right: 16,
                child: onPressed(
                  action: GameUIConfig.runButtonPressed,
                  child: Container(
                    width: GameUIConfig.runButtonSize,
                    height: GameUIConfig.runButtonSize,
                    alignment: Alignment.center,
                    child: text(
                        GameUIConfig.runButtonTextValue,
                        color: GameUIConfig.runButtonTextColor,
                        size: GameUIConfig.runButtonTextFontSize,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GameUIConfig.runButtonColor
                    ),
                  ),
                ),
              ),
              // buildAimButton(Engine.PI_Quarter * 0),
              // buildAimButton(Engine.PI_Quarter * 1),
              // buildAimButton(Engine.PI_Quarter * 2),
              // buildAimButton(Engine.PI_Quarter * 3),
              // buildAimButton(Engine.PI_Quarter * 4),
              // buildAimButton(Engine.PI_Quarter * 5),
              // buildAimButton(Engine.PI_Quarter * 6),
              // buildAimButton(Engine.PI_Quarter * 7),
              // buildWalkButtons(),
            ]);

  static Widget buildPlayerMessage(String message) =>
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
    );

  static Widget buildWalkButtons() =>
    Positioned(
        bottom: 0,
        left: 0,
        child: Row(
          children: [
            Column(
              children: [
                buildWalkBox(0),
                buildWalkBox(0),
                buildWalkBox(0),
              ],
            ),
            Column(
              children: [
                buildWalkBox(0),
                Container(width: 60, height: 60),
                buildWalkBox(0),
              ],
            ),
            Column(
              children: [
                buildWalkBox(0),
                buildWalkBox(0),
                buildWalkBox(0),
              ],
            )
          ],
        ),
    );

  static Widget buildWalkBox(int direction){
    return container(
       width: 60,
       height: 60,
       color: Colors.blue,
       action: (){
          GameIO.touchscreenDirectionMove = direction;
       }
    );
  }

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
            EditorUI.buildControlsWeather(),
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