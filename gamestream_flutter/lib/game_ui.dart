import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_minimap.dart';
import 'package:gamestream_flutter/game_ui_interact.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/game_map.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_ui_config.dart';
import 'isometric/ui/dialogs/build_game_dialog.dart';
import 'ui/builders/build_time.dart';

class GameUI {
  static const Icon_Scale = 1.5;
  static final messageBoxVisible = Watch(false, clamp: (bool value) {
    if (ServerState.gameType.value == GameType.Practice) return false;
    return value;
  }, onChanged: onVisibilityChangedMessageBox);
  static final textEditingControllerMessage = TextEditingController();
  static final textFieldMessage = FocusNode();
  static final debug = Watch(false);
  static final panelTypeKey = <int, GlobalKey>{};
  static final playerTextStyle = TextStyle(color: Colors.white);
  static final mapVisible = Watch(false);
  static final timeVisible = Watch(true);

  static Widget buildUI() => StackFullscreen(children: [
        buildWatchBool(ClientState.triggerAlarmNoMessageReceivedFromServer,
            buildDialogFramesSinceUpdate),
        watch(GameState.player.gameDialog, buildGameDialog),
        buildWatchBool(GameState.player.alive, buildPositionedContainerRespawn, false),
        Positioned(
            top: 0,
            right: 0,
            child: buildRowMainMenu()
        ),
        Positioned(child: buildGeneratedMiniMap(), top: 0, left: 0),
        buildWatchBool(GameUI.mapVisible, buildMiniMap),
        WatchBuilder(ClientState.edit, buildPlayMode),
        WatchBuilder(GameIO.inputMode, buildStackInputMode),
        buildWatchBool(ClientState.debugVisible, GameDebug.buildStackDebug),
        buildPositionedAreaType(),
        buildPositionedMessageStatus(),
        buildWatchGameStatus(),
      ]);


  static Widget buildGeneratedMiniMap(){
    return watch(ClientState.sceneChanged, (_){
        return Container(
          color: Colors.red,
          child: Engine.buildCanvas(paint: (Canvas canvas, Size size){
            const scale = 1.0;
            canvas.scale(scale, scale);
            final screenCenterX = size.width * 0.5;
            final screenCenterY = size.height * 0.5;
            const ratio = 2 / 48.0;
            final targetX = GameCamera.chaseTarget.renderX * ratio;
            final targetY = GameCamera.chaseTarget.renderY * ratio;
            const translate = 350;
            final cameraX = targetX - (screenCenterX / scale) - translate;
            final cameraY = targetY - (screenCenterY / scale) - translate;
            canvas.translate(-cameraX, -cameraY);

            GameMinimap.renderCanvas(canvas);

            Engine.renderExternalCanvas(
              canvas: canvas,
              image: GameImages.atlas_gameobjects,
              srcX: 0,
              srcY: 72,
              srcWidth: 8,
              srcHeight: 8,
              dstX: targetX,
              dstY: targetY,
              scale: 1
            );

          }),
        );
    });
  }

  static Widget buildWatchGameStatus() {
    return watch(ServerState.gameStatus, (int gameStatus) {
           if (gameStatus == GameStatus.Playing) return const SizedBox();
           return IgnorePointer(
             child: Positioned(
               top: 60,
               child: Container(
                 alignment: Alignment.center,
                 width: Engine.screen.width,
                 child: text("Waiting for more players to join")),
               ),
           );
      });
  }

  static Positioned buildPositionedAreaType() => Positioned(
          top: 75,
          child: Container(
              width: Engine.screen.width,
              alignment: Alignment.center,
              child: buildWatchAreaType()
          ),
      );

  static Positioned buildPositionedMessageStatus() => Positioned(
          bottom: 100,
          child: IgnorePointer(
            child: Container(
                width: Engine.screen.width,
                alignment: Alignment.center,
                child: watch(ClientState.messageStatus, buildMessageStatus),
            ),
          ),
      );


  static Widget buildMessageStatus(String message){
    if (message.isEmpty) return const SizedBox();
    return MouseRegion(
      onEnter: (_){
         ClientActions.messageClear();
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.black12,
          child: text(message, onPressed: ClientActions.messageClear),),
    );
  }

  static WatchBuilder<int> buildWatchAreaType() =>
      WatchBuilder(ServerState.areaType, (int areaType) {
        return WatchBuilder(ClientState.areaTypeVisible, (bool areaTypeVisible){
          return IgnorePointer(
            child: AnimatedOpacity(
                opacity: areaTypeVisible ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: text(AreaType.getName(areaType), size: 30),
            ),
          );
        });
      });

  static Widget buildStackInputModeTouch(bool side) => Stack(children: [
        Positioned(
          right: side ? GameUIConfig.runButtonPadding : null,
          left: side ? null : GameUIConfig.runButtonPadding,
          child: Container(
            height: Engine.screen.height,
            alignment: Alignment.center,
            child: onPressed(
              action: GameUIConfig.runButtonPressed,
              child: Container(
                width: GameUIConfig.runButtonSize,
                height: GameUIConfig.runButtonSize,
                alignment: Alignment.center,
                child: watch(GamePlayer.weapon, (int itemType) => buildAtlasItemType(itemType, scale: 3)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 5),
                  color: GameUIConfig.runButtonColor,
                ),
              ),
            ),
          ),
        ),
      ]);

  static Widget buildStackInputMode(int inputMode) =>
      inputMode == InputMode.Keyboard
          ? const SizedBox()
          : watch(ClientState.touchButtonSide, buildStackInputModeTouch);

  static Widget buildWalkButtons() => Positioned(
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

  static Widget buildWalkBox(int direction) {
    return container(
        width: 60,
        height: 60,
        color: Colors.blue,
        action: () {
          GameIO.touchscreenDirectionMove = direction;
        });
  }

  static Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: watch(
          ClientState.rendersSinceUpdate,
          (int frames) =>
              text("Warning: No message received from server $frames")));

  static Positioned buildWatchInterpolation() => Positioned(
        bottom: 0,
        left: 0,
        child: watch(GameState.player.interpolating, (bool value) {
          if (!value)
            return text("Interpolation Off",
                onPressed: () => GameState.player.interpolating.value = true);
          return watch(ClientState.rendersSinceUpdate, (int frames) {
            return text("Frames: $frames",
                onPressed: () => GameState.player.interpolating.value = false);
          });
        }),
      );

  static Positioned buildMiniMap() => Positioned(
        left: 6,
        top: 6,
        child: buildDialogUIControl(
          child: onPressed(
            action: GameState.actionGameDialogShowMap,
            child: Container(
                padding: const EdgeInsets.all(4),
                color: brownDark,
                child: GameMapWidget(width: 133, height: 133)),
          ),
        ),
      );

  static Widget buildContainerQuestUpdated() => Container(
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

  static Widget buildRowMainMenu() =>
      GameUI.buildDialogUIControl(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildButtonTogglePlayMode(),
              width3,
              watch(ServerState.sceneEditable, buildWatchSceneEditableControls),
              width3,
              GameUI.buildIconAudio(),
              width3,
              GameUI.buildIconZoom(),
              width3,
              onPressed(
                child: GameUI.buildIconFullscreen(),
                action:  Engine.fullscreenToggle,
              ),
              onPressed(
                child: GameUI.buildIconHome(),
                action: GameNetwork.disconnect,
              ),
            ]
        ),
      );

  static Widget buildWatchSceneEditableControls(bool sceneEditable) {
    return buildWatchBool(GameUI.timeVisible, buildTime);
  }

  static Widget buildIconAudio() =>
      onPressed(
        action: GameAudio.toggleMuted,
        child: watch(GameAudio.muted, (bool t) =>
            GameUI.buildAtlasIconType(t ? IconType.Sound_Disabled : IconType.Sound_Enabled, scale: Icon_Scale)
        ),
      );

  static Widget buildIconFullscreen() => WatchBuilder(
      Engine.fullScreen,
      (bool fullscreen) => onPressed(
          action: Engine.fullscreenToggle,
          child: GameUI.buildAtlasIconType(IconType.Fullscreen, scale: Icon_Scale)));

  static Widget buildIconZoom() => onPressed(
      action: GameActions.toggleZoom, child: buildAtlasIconType(IconType.Zoom, scale: Icon_Scale));

  static Widget buildIconHome() => onPressed(
      action: GameNetwork.disconnect, child: buildAtlasIconType(IconType.Home, scale: Icon_Scale));

  static Widget buildIconSlotEmpty() =>
      buildAtlasIconType(IconType.Slot, scale: GameInventoryUI.Slot_Scale);

  static Widget buildAtlasIconType(int iconType,
          {double scale = 1, int color = 1, double size = AtlasIcons.Size}) =>
      Engine.buildAtlasImage(
        image: GameImages.atlas_icons,
        srcX: AtlasIcons.getSrcX(iconType),
        srcY: AtlasIcons.getSrcY(iconType),
        srcWidth: size,
        srcHeight: size,
        scale: scale,
        color: color,
      );

  static Widget buildAtlasItemType(int itemType, {double scale = 1}) =>
      Engine.buildAtlasImage(
        image: GameImages.atlas_items,
        srcX: AtlasItems.getSrcX(itemType),
        srcY: AtlasItems.getSrcY(itemType),
        srcWidth: AtlasItems.getSrcWidth(itemType),
        srcHeight: AtlasItems.getSrcHeight(itemType),
        scale: scale * (32.0 / AtlasItems.getSrcWidth(itemType)),
      );

  static Widget buildAtlasNodeType(int nodeType) => Engine.buildAtlasImage(
        image: GameImages.atlas_nodes,
        srcX: AtlasNodeX.mapNodeType(nodeType),
        srcY: AtlasNodeY.mapNodeType(nodeType),
        srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
        srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
      );

  static Widget buildDialogUIControl({required Widget child}) =>
      buildDialog(child: child, dialogType: DialogType.UI_Control);

  static Widget buildDialog({required Widget child, required int dialogType}) =>
      MouseRegion(
        onEnter: (PointerEnterEvent event) {
          ClientState.hoverDialogType.value = dialogType;
        },
        onExit: (PointerExitEvent event) {
          ClientState.hoverDialogType.value = DialogType.None;
        },
        child: child,
      );

  static Widget buildPlayMode(bool edit) =>
      edit ? watch(GameEditor.editTab, EditorUI.buildUI) : buildStackPlay();

  static Widget buildStackPlay() => StackFullscreen(children: [
        GameUIInteract.buildWatchInteractMode(),
        watch(ClientState.hoverIndex,
            GameInventoryUI.buildPositionedContainerItemTypeInformation),
        watch(ClientState.hoverTargetType,
            GameInventoryUI.buildPositionedContainerHoverTarget),
        Positioned(
            bottom: 24,
            left: 24,
            child: watch(ServerState.playerAttributes, buildButtonAttributes)),
        Positioned(
          left: 50,
          top: 50,
          child: buildWatchBool(
              ClientState.windowVisibleAttributes, buildWindowAttributes),
        ),
        Positioned(
          child: Container(
            width: Engine.screen.width,
            alignment: Alignment.center,
            child: buildWatchPlayerLevel(),
          ),
          bottom: 12,
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: buildDialogUIControl(
            child: buildColumnBelt(),
          ),
        ),
      ]);

  static Column buildColumnBelt() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildRowBeltItems(),
              width32,
            ],
          ),
          buildRowHotKeyLettersAndInventory(),
        ],
      );

  static Row buildRowHotKeyLettersAndInventory() => Row(
        children: [
          width96,
          buildWatchBeltType(ServerState.playerBelt5_ItemType),
          width64,
          buildWatchBeltType(ServerState.playerBelt6_ItemType),
          buildButtonInventory(),
        ],
      );

  static Stack buildButtonInventory() {
    return Stack(
          children: [
            // TODO DragTarget
            DragTarget<int>(
              onWillAccept: (int? data){
                return data != null;
              },
              onAccept: (int? data){
                 if (data == null) return;
                 ClientEvents.onAcceptDragInventoryIcon();
              },
              builder: (context, data, dataRejected){
                return onPressed(
                  hint: "Inventory",
                  action: GameNetwork.sendClientRequestInventoryToggle,
                  onRightClick: GameNetwork.sendClientRequestInventoryToggle,
                  child: buildAtlasIconType(IconType.Inventory, scale: 2.0),
                );
              },
            ),
            Positioned(top: 5, left: 5, child: text("R"))
          ],
        );
  }

  static Row buildRowBeltItems() => Row(
      mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildWatchBeltType(ServerState.playerBelt1_ItemType),
          buildWatchBeltType(ServerState.playerBelt2_ItemType),
          buildWatchBeltType(ServerState.playerBelt3_ItemType),
          buildWatchBeltType(ServerState.playerBelt4_ItemType),
        ],
      );

  static Widget buildDragTargetSlot({required int index, double scale = 1.0, Color? outlineColor}) =>
      DragTarget<int>(
        builder: (context, data, rejectedData) =>
            Container(
               width: 64,
               height: 64,
               decoration: buildDecorationBorder(
                   colorBorder: outlineColor ?? GameColors.brown01,
                   colorFill: GameColors.brown02,
                   width: 2,
               ),
            ),
        onWillAccept: (int? data) => data != null,
        onAccept: (int? data) {
          if (data == null) return;
          GameNetwork.sendClientRequestInventoryMove(
            indexFrom: data,
            indexTo: index,
          );
        },
      );

  static Widget buildWatchBeltType(Watch<int> watchBeltType) {
    return watch(
          watchBeltType,
          (int beltItemType) {
            return Stack(
            children: [
              watch(ServerState.equippedWeaponIndex, (equippedWeaponIndex) =>
                buildDragTargetSlot(
                  index: ServerQuery.mapWatchBeltTypeToItemType(watchBeltType),
                  scale: 2.0,
                  outlineColor: ServerQuery.mapWatchBeltTypeToItemType(watchBeltType) == equippedWeaponIndex ? GameColors.white : GameColors.brown02
                ),),
              Positioned(
                left: 5,
                top: 5,
                child: text(ClientQuery.mapWatchBeltTypeTokeyboardKeyString(watchBeltType)),
              ),
              if (beltItemType != ItemType.Empty)
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  child: GameInventoryUI.buildDraggableItemIndex(
                      itemIndex: ServerQuery.mapWatchBeltTypeToItemType(watchBeltType),
                      scale: 2,
                  ),
                ),

              if (beltItemType != ItemType.Empty)
                Positioned(
                    right: 5,
                    bottom: 5,
                    child: buildInventoryAware(
                        builder: () => text(
                          ServerQuery.getWatchBeltTypeWatchQuantity(watchBeltType).value,
                          italic: true,
                          color: Colors.white70,
                        ))),
            ],
          );
          });
  }

  static Widget buildStackHotKeyContainer({
    required int itemType,
    required String hotKey,
  }) => Stack(
      children: [
        buildAtlasIconType(IconType.Slot, scale: 2.0),
        buildAtlasItemType(itemType, scale: 1.8),
        Positioned(
          left: 5,
          top: 5,
          child: text(hotKey),
        ),
        if (ItemType.getConsumeType(itemType) != ItemType.Empty)
          Positioned(
              right: 5,
              bottom: 5,
              child: buildInventoryAware(
                  builder: () => text(
                        ServerQuery.getItemTypeConsumesRemaining(itemType),
                        italic: true,
                        color: Colors.white70,
                      ))),
        if (itemType != ItemType.Empty && GamePlayer.weapon.value == itemType)
          Container(
            width: 64,
            height: 64,
            decoration: buildDecorationBorder(
              colorBorder: Colors.white,
              colorFill: Colors.transparent,
              width: 3,
            ),
          )
      ],
    );

  /// Automatically rebuilds whenever the inventory gets updated
  static Widget buildInventoryAware({required BasicWidgetBuilder builder}) =>
      watch(ClientState.inventoryReads, (int reads) => builder());

  static Widget buildWindowAttributes() =>
      watch(ServerState.playerAttributes, (int attributes) {
        final remaining = attributes > 0;
        return buildDialogUIControl(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: GameColors.brownDark,
            width: GameUIStyle.Window_Attributes_Width,
            height: GameUIStyle.Window_Attributes_Height,
            child: Column(
              children: [
                Container(
                  height: GameUIStyle.Window_Attributes_Height - 60,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        text("Weapon Capacity"),
                        text("Weapon Accuracy"),
                        text("Reload Speed"),
                        text("Fire Rate"),
                        text("Movement Speed"),
                        text("Change Weapon Speed"),
                        text("Ability: Throw Grenade"),
                        text("Ability: Heal"),
                        text("Ability: Blink"),
                        text("Ability: Double Damage"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Max Health"),
                            Row(
                              children: [
                                watch(ServerState.playerPerkMaxHealth, text),
                                width16,
                                container(
                                    action: remaining ? ServerActions.selectPerkTypeMaxHealth : null,
                                    child: text('+', align: TextAlign.center),
                                    width: 50,
                                    height: 50,
                                    color: GameColors.brownLight,
                                    alignment: Alignment.center,
                                ),
                              ],
                            )
                          ],
                        ),
                        height4,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Damage"),
                            Row(
                              children: [
                                watch(ServerState.playerPerkMaxDamage, text),
                                width16,
                                container(
                                    action: remaining ? ServerActions.selectPerkTypeDamage : null,
                                    child: text('+', align: TextAlign.center),
                                    width: 50,
                                    height: 50,
                                    color: GameColors.brownLight,
                                    alignment: Alignment.center,
                                ),
                              ],
                            )

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (remaining) text("REMAINING $attributes"),
              ],
            ),
          ),
        );
      });

  static Widget buildButtonAttributes(int attributes) {
    if (attributes == 0) return const SizedBox();
    return buildDialog(
      dialogType: DialogType.UI_Control,
      child: container(
          action: ClientActions.windowTogglePlayerAttributes,
          alignment: Alignment.center,
          color: GameColors.brownDark,
          child: text("ATTRIBUTES +$attributes", align: TextAlign.center)),
    );
  }

  static Widget buildWatchPlayerLevel() => watch(
      ServerState.playerLevel,
      (int level) => Tooltip(
            child: watch(
                ServerState.playerExperiencePercentage, buildPlayerExperience),
            message: "Level $level",
          ));

  static Widget buildPlayerExperience(double experience) =>
      buildDialogUIControl(
        child: Container(
          width: GameUIStyle.ExperienceBarWidth,
          height: GameUIStyle.ExperienceBarHeight,
          color: GameUIStyle.ExperienceBarColorBackground,
          alignment: Alignment.centerLeft,
          child: Container(
            width: GameUIStyle.ExperienceBarWidth * experience,
            height: GameUIStyle.ExperienceBarHeight,
            color: GameUIStyle.ExperienceBarColorFill,
          ),
        ),
      );

  static Decoration buildDecorationBorder({
    required Color colorBorder,
    required Color colorFill,
    required double width,
    double borderRadius = 0.0,
  }) =>
      BoxDecoration(
          border: Border.all(color: colorBorder, width: width),
          borderRadius: BorderRadius.circular(borderRadius),
          color: colorFill
      );

  static Widget buildButtonTogglePlayMode() {
    return watch(ServerState.sceneEditable, (bool isOwner) {
      if (!isOwner) return const SizedBox();
      return watch(ClientState.edit, (bool edit) {
        return container(
            toolTip: "Tab",
            child: edit ? "PLAY" : "EDIT",
            action: GameActions.actionToggleEdit,
            color: GameColors.green,
            alignment: Alignment.center,
            width: 100);
      });
    });
  }

  static Widget buildPositionedContainerRespawn(){
    const width = 200;
    return Positioned(
      bottom: 150,
      child: Container(
        width: Engine.screen.width,
        alignment: Alignment.center,
        child: GameUI.buildDialogUIControl(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text('You Died'),
              height8,
              container(
                alignment: Alignment.center,
                child: "Respawn",
                action: GameNetwork.sendClientRequestRespawn,
                color: greyDark,
                width: width * Engine.GoldenRatio_0_618,
              )
            ],
          ),
        ),
      ),
    );
  }
}
