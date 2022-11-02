import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
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
  /// true == right
  /// false == left
  static final touchButtonSide = Watch(TouchButtonSideRight);
  static const TouchButtonSideLeft = false;
  static const TouchButtonSideRight = true;

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

  static Widget buildStackInputModeTouch(bool side) =>
      Stack(children: [
        Positioned(
          bottom: GameUIConfig.runButtonPadding,
          right: side ? GameUIConfig.runButtonPadding : null,
          left: side ? null : GameUIConfig.runButtonPadding,
          child: onPressed(
            action: GameUIConfig.runButtonPressed,
            child: Container(
              width: GameUIConfig.runButtonSize,
              height: GameUIConfig.runButtonSize,
              alignment: Alignment.center,
              // child: text(
              //   GameUIConfig.runButtonTextValue,
              //   color: GameUIConfig.runButtonTextColor,
              //   size: GameUIConfig.runButtonTextFontSize,
              // ),
              child: watch(GamePlayer.weapon.type, buildIconAttackType),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: GameUIConfig.runButtonColor,
              ),
            ),
          ),
        ),
        // Positioned(
        //   bottom: 145,
        //   right: side ? 5 : null,
        //   left: side ? null : 5,
        //   child: onPressed(
        //     action: GameActions.playerStop,
        //     child: Container(
        //       width: 75,
        //       height: 75,
        //       alignment: Alignment.center,
        //       child: text(
        //         "Stop",
        //         color: Colors.white,
        //         size: GameUIConfig.runButtonTextFontSize,
        //       ),
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: Colors.red.withOpacity(Engine.GoldenRatio_0_381),
        //       ),
        //     ),
        //   ),
        // )
      ]);

  static Widget buildStackInputMode(int inputMode) =>
      inputMode == InputMode.Keyboard
          ? const SizedBox()
          : watch(touchButtonSide, buildStackInputModeTouch);

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

  static Widget buildPanelPlayerEquippedAttackType(int bodyType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: buildIconAttackType(bodyType),
      );

  static Widget buildPanelPlayerEquippedBodyType(int bodyType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: buildIconBodyType(bodyType),
      );

  static Widget buildPanelPlayerEquippedHeadType(int headType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: buildIconHeadType(headType),
      );

  static Widget buildColumnInventory() =>
    Column(
      children: [
        Row(
          children: [
            watch(GamePlayer.weapon.type, buildPanelPlayerEquippedAttackType),
            watch(GamePlayer.bodyType, buildPanelPlayerEquippedBodyType),
            watch(GamePlayer.headType, buildPanelPlayerEquippedHeadType),
          ],
        ),
        buildInventory(),
      ],
    );

  static Widget buildInventory() {
    // return Container(
    //   color: brownLight,
    //   width: 300,
    //   height: 400,
    //   padding: const EdgeInsets.all(6),
    //   child: buildCanvas(
    //       paint: (Canvas canvas, Size size){
    //           for (var i = 0; i < GameInventory.total; i++){
    //             final subType = GameInventory.itemSubType[i];
    //             final x = GameInventory.x[i];
    //             final y = GameInventory.y[i];
    //               switch (GameInventory.itemType[i]){
    //                 case ItemType.Body:
    //                    Engine.renderExternalCanvas(
    //                        canvas: canvas,
    //                        image: GameImages.atlasIcons,
    //                        srcX: AtlasIconsX.getBodyType(subType),
    //                        srcY: AtlasIconsY.getBodyType(subType),
    //                        srcWidth: AtlasIconSize.getBodyType(subType),
    //                        srcHeight: AtlasIconSize.getBodyType(subType),
    //                        dstX: x * 32,
    //                        dstY: y * 32,
    //                    );
    //                    break;
    //                 default:
    //                   break;
    //               }
    //           }
    //       },
    //       frame: GameInventory.canvasDrawNotifier),
    // );

    return Container(
      color: brownLight,
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          buildInventorySlotGrid(),
          watch(GameInventory.reads, buildInventoryItemGrid),
        ],
      ),
    );

  }

  static Widget buildInventoryItemGrid(int reads){
    final children = <Widget>[];
    for (var i = 0; i < GameInventory.total; i++){
       children.add(buildInventoryItem(i));
    }
    return Stack(
      children: children,
    );
  }

  static Widget buildInventoryItem(int index){
     return Positioned(
         child: Draggable<int>(
           hitTestBehavior: HitTestBehavior.opaque,
           data: index,
           feedback: buildAtlasImage(
             image: GameImages.atlasIcons,
             srcX: getInventoryItemSrcX(index),
             srcY: getInventoryItemSrcY(index),
             srcWidth: getInventoryItemSrcSize(index),
             srcHeight: getInventoryItemSrcSize(index),
           ),
           child: buildAtlasImage(
               image: GameImages.atlasIcons,
               srcX: getInventoryItemSrcX(index),
               srcY: getInventoryItemSrcY(index),
               srcWidth: getInventoryItemSrcSize(index),
               srcHeight: getInventoryItemSrcSize(index),
           ),
           childWhenDragging: buildAtlasImage(
             image: GameImages.atlasIcons,
             srcX: getInventoryItemSrcX(index),
             srcY: getInventoryItemSrcY(index),
             srcWidth: getInventoryItemSrcSize(index),
             srcHeight: getInventoryItemSrcSize(index),
           ),
         ),
        left: GameInventory.x[index] * 32.0,
        top: GameInventory.y[index] * 32.0,
     );
  }

  static double getInventoryItemSrcX(int index){
      switch (GameInventory.itemType[index]) {
        case ItemType.Body:
          return AtlasIconsX.getBodyType(GameInventory.itemSubType[index]);
        case ItemType.Weapon:
          return AtlasIconsX.getWeaponType(GameInventory.itemSubType[index]);
        case ItemType.Head:
          return AtlasIconsX.getHeadType(GameInventory.itemSubType[index]);
        default:
          throw Exception('GameUI.getInventoryItemSrcX($index)');
      }
  }

  static double getInventoryItemSrcY(int index){
    switch (GameInventory.itemType[index]) {
      case ItemType.Body:
        return AtlasIconsY.getBodyType(GameInventory.itemSubType[index]);
      case ItemType.Weapon:
        return AtlasIconsY.getWeaponType(GameInventory.itemSubType[index]);
      case ItemType.Head:
        return AtlasIconsY.getHeadType(GameInventory.itemSubType[index]);
      default:
        throw Exception('GameUI.getInventoryItemSrcY($index)');
    }
  }

  static double getInventoryItemSrcSize(int index){
    switch (GameInventory.itemType[index]) {
      case ItemType.Body:
        return AtlasIconSize.getBodyType(GameInventory.itemSubType[index]);
      case ItemType.Weapon:
        return AtlasIconSize.getWeaponType(GameInventory.itemSubType[index]);
      case ItemType.Head:
        return AtlasIconSize.getHeadType(GameInventory.itemSubType[index]);
      default:
        throw Exception('GameUI.getInventoryItemSrcSize($index)');
    }
  }

  static Widget buildInventorySlotGrid(){
    final rows = <Widget>[];

    for (var row = 0; row < 5; row++){
      final columns = <Widget>[];
      for (var column = 0; column < 10; column++){
        columns.add(
            DragTarget<int>(
              builder: (context, candidate, index){
                return buildAtlasImage(
                  image: GameImages.atlasIcons,
                  srcX: AtlasIconsX.Slot,
                  srcY: AtlasIconsY.Slot,
                  srcWidth: AtlasIconSize.Slot,
                  srcHeight: AtlasIconSize.Slot,
                );
              },
            )
        );
      }
      rows.add(
          Row(
            children: columns,
          )
      );
    }
    return Column(
      children: rows,
    );
  }

  static Widget buildColumnPlayerWeapons(List<Weapon> weapons) =>
      Container(
        color: brownLight,
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(6),
        child: text("weapons"),
      );

  static Widget buildIconAttackType(int type) =>
      buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: AtlasIconsX.getWeaponType(type),
        srcY: AtlasIconsY.getWeaponType(type),
        srcWidth: AtlasIconSize.getWeaponType(type),
        srcHeight: AtlasIconSize.getWeaponType(type),
        scale: 3.0,
      );

  static Widget buildIconBodyType(int bodyType) =>
      buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: AtlasIconsX.getBodyType(bodyType),
        srcY: AtlasIconsY.getBodyType(bodyType),
        srcWidth: AtlasIconSize.getBodyType(bodyType),
        srcHeight: AtlasIconSize.getBodyType(bodyType),
        scale: 3.0,
      );

  static Widget buildIconHeadType(int headType) =>
      buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: AtlasIconsX.getHeadType(headType),
        srcY: AtlasIconsY.getHeadType(headType),
        srcWidth: AtlasIconSize.getHeadType(headType),
        srcHeight: AtlasIconSize.getHeadType(headType),
        scale: 3.0,
      );

}