import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game_ui_interact.dart';
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
  static final messageBoxVisible = Watch(false, clamp: (bool value) {
    if (ServerState.gameType.value == GameType.Skirmish) return false;
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
        watch(GameState.player.message, buildPlayerMessage),
        buildWatchBool(ClientState.triggerAlarmNoMessageReceivedFromServer,
            buildDialogFramesSinceUpdate),
        watch(GameState.player.gameDialog, buildGameDialog),
        buildWatchBool(GameState.player.alive, buildContainerRespawn, false),
        buildTopRightMenu(),
        buildWatchBool(GameUI.mapVisible, buildMiniMap),
        watch(ClientState.edit, buildPlayMode),
        watch(GameIO.inputMode, buildStackInputMode),
        buildWatchBool(ClientState.debugVisible, GameDebug.buildStackDebug),
      ]);

  static Widget buildStackInputModeTouch(bool side) => Stack(children: [
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
              child: watch(GamePlayer.weapon, buildAtlasItemType),
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
          : watch(ClientState.touchButtonSide, buildStackInputModeTouch);

  static Widget buildPlayerMessage(String message) => Positioned(
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
                    child: text(message))),
      );

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

  static Positioned buildTopRightMenu() =>
      Positioned(top: 0, right: 0, child: buildPanelMenu());

  static Widget buildStackGameTypeDarkAge() => Stack(
        children: [
          Positioned(left: 8, bottom: 50, child: buildColumnTeleport()),
          buildWatchBool(
              GameState.player.questAdded, buildContainerQuestUpdated),
        ],
      );

  static Widget buildIconFullscreen() => WatchBuilder(
      Engine.fullScreen,
      (bool fullscreen) => onPressed(
          action: Engine.fullscreenToggle,
          child: GameUI.buildAtlasIconType(IconType.Fullscreen)));

  static Widget buildIconZoom() => onPressed(
      action: GameActions.toggleZoom, child: buildAtlasIconType(IconType.Zoom));

  static Widget buildIconHome() => onPressed(
      action: GameNetwork.disconnect, child: buildAtlasIconType(IconType.Home));

  static Widget buildIconSlotEmpty() =>
      buildAtlasIconType(IconType.Slot, scale: GameInventoryUI.Slot_Scale);

  static Widget buildAtlasIconType(int iconType,
          {double scale = 1, int color = 1, double size = AtlasIcons.Size}) =>
      Engine.buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: AtlasIcons.getSrcX(iconType),
        srcY: AtlasIcons.getSrcY(iconType),
        srcWidth: size,
        srcHeight: size,
        scale: scale,
        color: color,
      );

  static Widget buildAtlasItemType(int itemType, {double scale = 1}) =>
      Engine.buildAtlasImage(
        image: GameImages.atlasItems,
        srcX: AtlasItems.getSrcX(itemType),
        srcY: AtlasItems.getSrcY(itemType),
        srcWidth: AtlasItems.size,
        srcHeight: AtlasItems.size,
        scale: scale,
      );

  static Widget buildAtlasNodeType(int nodeType) => Engine.buildAtlasImage(
        image: GameImages.atlasNodes,
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
      edit ? watch(GameEditor.editTab, buildStackEdit) : buildStackPlay();

  static Widget buildStackPlay() => StackFullscreen(children: [
        GameUIInteract.buildWatchInteractMode(),
        watch(ClientState.hoverItemType,
            GameInventoryUI.buildPositionedContainerItemTypeInformation),
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
            child: buildColumnHotKeys(),
          ),
        ),
      ]);

  static Column buildColumnHotKeys() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildUnassignedWeaponSlot(),
              buildRowHotKeyNumbers(),
              width32,
            ],
          ),
          buildRowHotKeyLettersAndInventory(),
        ],
      );

  static Row buildRowHotKeyLettersAndInventory() => Row(
        children: [
          width96,
          buildHotKeyWatch(ClientState.hotKeyQ),
          width64,
          buildHotKeyWatch(ClientState.hotKeyE),
          buildButtonInventory(),
        ],
      );

  static Stack buildButtonInventory() {
    return Stack(
          children: [
            onPressed(
                hint: "Inventory",
                action: GameNetwork.sendClientRequestInventoryToggle,
                onRightClick: GameNetwork.sendClientRequestInventoryToggle,
                child: buildAtlasIconType(IconType.Inventory, scale: 2.0),
            ),
            Positioned(top: 5, left: 5, child: text("R"))
          ],
        );
  }

  static Row buildRowHotKeyNumbers() => Row(
      mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildHotKeyWatch(ClientState.hotKey1),
          buildHotKeyWatch(ClientState.hotKey2),
          buildHotKeyWatch(ClientState.hotKey3),
          buildHotKeyWatch(ClientState.hotKey4),
        ],
      );

  static Widget buildUnassignedWeaponSlot() => watch(
      ClientState.readsHotKeys,
      (int reads) => watch(GamePlayer.weapon, (int playerWeaponType) {
            if (ClientState.hotKey1.value == playerWeaponType ||
                ClientState.hotKey2.value == playerWeaponType ||
                ClientState.hotKey3.value == playerWeaponType ||
                ClientState.hotKey4.value == playerWeaponType ||
                ClientState.hotKeyE.value == playerWeaponType ||
                ClientState.hotKeyQ.value == playerWeaponType
            ) return const SizedBox();

            return Container(
              child: buildStackHotKeyContainer(
                  itemType: playerWeaponType, hotKey: "-"),
              margin: const EdgeInsets.only(right: 4),
            );
          }));

  static Widget buildHotKeyWatch(Watch<int> hotKeyWatch) =>
      watch(
          hotKeyWatch,
          (int thisItemType) => DragTarget<int>(
              onWillAccept: (int? data) => data != null,
              onAccept: (int? data) {
                if (data == null) return;
                ClientEvents.onHotKeyDragAccept(hotKeyWatch, data);
              },
              builder: (context, data, rejectedData) => watch(
                  GamePlayer.weapon,
                  (int playerWeaponType) => onPressed(
                        onRightClick: () =>
                            hotKeyWatch.value = ItemType.Empty,
                         action: () => ClientEvents.onHotKeyWatchButtonPressed(hotKeyWatch),
                        child: Stack(
                          children: [
                            buildAtlasIconType(IconType.Slot, scale: 2.0),
                            buildAtlasItemType(thisItemType, scale: 1.8),
                            Positioned(
                              left: 5,
                              top: 5,
                              child: text(ClientQuery.mapHotKeyWatchToString(hotKeyWatch)),
                            ),
                            if (ItemType.getConsumeType(thisItemType) !=
                                ItemType.Empty)
                              Positioned(
                                  right: 5,
                                  bottom: 5,
                                  child: buildInventoryAware(
                                      builder: () => text(
                                            ServerQuery
                                                .getItemTypeConsumesRemaining(
                                                    thisItemType),
                                            italic: true,
                                            color: Colors.white70,
                                          ))),
                            if (playerWeaponType != ItemType.Empty && playerWeaponType == thisItemType)
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
                        ),
                      ))));

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
                if (remaining) text("REMAINING $attributes"),
                Row(
                  children: [
                    text("Max Health"),
                    if (remaining) container(child: "+", width: 50, height: 50),
                  ],
                ),
                Row(
                  children: [
                    text("Inventory Size"),
                    if (remaining) container(child: "+", width: 50, height: 50),
                  ],
                ),
                Row(
                  children: [
                    text("Sword Mastery"),
                    if (remaining) container(child: "+", width: 50, height: 50),
                  ],
                ),
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
          action: ClientActions.windowOpenPlayerAttributes,
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

  static Widget buildControlPlayerEquippedWeaponAmmunition() {
    return watch(ServerState.playerEquippedWeaponAmmunitionType,
        (int ammunitionType) {
      if (ammunitionType == ItemType.Empty) return const SizedBox();
      return Row(children: [
        watch(ServerState.playerEquippedWeaponAmmunitionType,
            GameUI.buildAtlasItemType),
        width4,
        watch(ServerState.playerEquippedWeaponAmmunitionQuantity, text),
      ]);
    });
  }

  static Decoration buildDecorationBorder({
    required Color colorBorder,
    required Color colorFill,
    required double width,
    double borderRadius = 0.0,
  }) =>
      BoxDecoration(
          border: Border.all(color: colorBorder, width: width),
          borderRadius: BorderRadius.circular(borderRadius),
          color: colorFill);
}
