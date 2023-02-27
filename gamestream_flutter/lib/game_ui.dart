import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/game_minimap.dart';
import 'package:gamestream_flutter/game_ui_interact.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_ui_config.dart';


class GameUI {
  static const Icon_Scale = 1.5;
  static final messageBoxVisible = Watch(false, clamp: (bool value) {
    if (ServerState.gameType.value == GameType.Practice) return false;
    return value;
  }, onChanged: onVisibilityChangedMessageBox);
  static final textEditingControllerMessage = TextEditingController();
  static final textFieldMessage = FocusNode();
  static final panelTypeKey = <int, GlobalKey>{};
  static final playerTextStyle = TextStyle(color: Colors.white);
  static final timeVisible = Watch(true);


  static Widget buildUI() => StackFullscreen(children: [
        buildWatchBool(ClientState.triggerAlarmNoMessageReceivedFromServer,
            buildDialogFramesSinceUpdate),
        buildWatchBool(GamePlayer.alive, buildPositionedContainerRespawn, false),
        Positioned(
            top: 0,
            right: 0,
            child: buildRowMainMenu()
        ),
        Positioned(
          child: buildMapCircle(),
          bottom: GameStyle.Default_Padding,
          right: GameStyle.Default_Padding,
        ),
        WatchBuilder(ClientState.edit, buildPlayMode),
        WatchBuilder(GameIO.inputMode, buildStackInputMode),
        buildWatchBool(ClientState.debugMode, GameDebug.buildStackDebug),
        buildPositionedAreaType(),
        buildPositionedMessageStatus(),
        buildWatchGameStatus(),
        buildWatchBool(ClientState.window_visible_settings, buildWindowSettings),
      ]);

  static Container buildMapCircle() {
    return Container(
          width: 203,
          height: 203,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black38, width: 3),
              color: Colors.black38
          ),
          child: ClipOval(
            child: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // border: Border.all(color: Colors.black38, width: 3),
                  // color: Colors.black12
                ),
                width: 200,
                height: 200,
                child: buildGeneratedMiniMap()),
          ),
        );
  }

  static Widget buildWindowSettings(){
     return Container(
        padding: GameStyle.Padding_6,
        color: GameColors.brownDark,
        width: 300,
        child: Column(
          children: [
            text("Settings", bold: true),
            height8,
            onPressed(
                action: GameSettings.ToggleDynamicShadows,
                child: Refresh(() => text('dynamic-shadows-enabled: ${GameSettings.Dynamic_Shadows}'))
            ),
            onPressed(
                child: Refresh(() => text('blend-mode: ${Engine.bufferBlendMode.name}')),
                action: (){
                  final currentIndex = BlendMode.values.indexOf(Engine.bufferBlendMode);
                  final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                  Engine.bufferBlendMode = BlendMode.values[nextIndex];
                }
            ),
            height8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("<-", onPressed: (){
                  GameNodes.setInterpolationLength(GameNodes.interpolation_length - 1);
                }),
                Refresh(() => text('light-size: ${GameNodes.interpolation_length}')),
                text("->", onPressed: (){
                  GameNodes.setInterpolationLength(GameNodes.interpolation_length + 1);
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("<-", onPressed: (){
                  final indexCurrent = EaseType.values.indexOf(GameNodes.interpolation_ease_type.value);
                  final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
                  GameNodes.interpolation_ease_type.value = EaseType.values[indexNext];
                }),
                watch(GameNodes.interpolation_ease_type, text),
                text("->", onPressed: (){
                  final indexCurrent = EaseType.values.indexOf(GameNodes.interpolation_ease_type.value);
                  final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
                  GameNodes.interpolation_ease_type.value = EaseType.values[indexNext];
                }),
              ],
            ),

            height16,
            text("ambient-color"),
            ColorPicker(
              portraitOnly: true,
              pickerColor: HSVColor.fromAHSV(
                  GameNodes.ambient_alp / 255,
                  GameNodes.ambient_hue.toDouble(),
                  GameNodes.ambient_sat / 100,
                  GameNodes.ambient_val / 100,
              ).toColor(),
              onColorChanged: (color){
                ClientState.overrideColor.value = true;
                final hsvColor = HSVColor.fromColor(color);
                GameNodes.ambient_alp = (hsvColor.alpha * 255).round();
                GameNodes.ambient_hue = hsvColor.hue.round();
                GameNodes.ambient_sat = (hsvColor.saturation * 100).round();
                GameNodes.ambient_val = (hsvColor.value * 100).round();
                GameNodes.resetNodeColorsToAmbient();
              },
            ),
          ],
        ),
     );
  }


  static Widget buildGeneratedMiniMap(){
    return watch(ClientState.sceneChanged, (_){
        return Engine.buildCanvas(paint: (Canvas canvas, Size size){
          const scale = 2.0;
          canvas.scale(scale, scale);
          final screenCenterX = size.width * 0.5;
          final screenCenterY = size.height * 0.5;
          const ratio = 2 / 48.0;
          final targetX = GameCamera.chaseTarget.renderX * ratio;
          final targetY = GameCamera.chaseTarget.renderY * ratio;
          const translate = 50;
          final cameraX = targetX - (screenCenterX / scale) - translate;
          final cameraY = targetY - (screenCenterY / scale) - translate;
          canvas.translate(-cameraX, -cameraY);

          GameMinimap.renderCanvas(canvas);

          for (var i = 0; i < ServerState.totalCharacters; i++) {
            final character = ServerState.characters[i];
            final isPlayer = GamePlayer.isCharacter(character);
            Engine.renderExternalCanvas(
                canvas: canvas,
                image: GameImages.atlas_gameobjects,
                srcX: 0,
                srcY: isPlayer ? 96 : character.allie ? 81 : 72,
                srcWidth: 8,
                srcHeight: 8,
                dstX: character.renderX * ratio,
                dstY: character.renderY * ratio,
                scale: 0.25
            );
          }
        });
    });
  }

  static Widget buildWatchGameStatus() {
    return watch(ServerState.gameStatus, (int gameStatus) {
           if (gameStatus == GameStatus.Playing) return GameStyle.Null;
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
    if (message.isEmpty) return GameStyle.Null;
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
                child: watch(GamePlayer.weapon, (int itemType) => buildAtlasItemType(itemType)),
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
          ? GameStyle.Null
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
        child: watch(GamePlayer.interpolating, (bool value) {
          if (!value)
            return text("Interpolation Off",
                onPressed: () => GamePlayer.interpolating.value = true);
          return watch(ClientState.rendersSinceUpdate, (int frames) {
            return text("Frames: $frames",
                onPressed: () => GamePlayer.interpolating.value = false);
          });
        }),
      );

  static Widget buildRowMainMenu() =>
      GameUI.buildDialogUIControl(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildButtonTogglePlayMode(),
              width3,
              buildTime(),
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
          {double scale = 1, int color = 1}) =>
      Engine.buildAtlasImage(
        image: GameImages.atlas_icons,
        srcX: AtlasIcons.getSrcX(iconType),
        srcY: AtlasIcons.getSrcY(iconType),
        srcWidth: AtlasIcons.getSrcWidth(iconType),
        srcHeight: AtlasIcons.getSrcHeight(iconType),
        scale: scale,
        color: color,
      );

  static Widget buildAtlasItemType(int itemType) =>
      FittedBox(
        child: Engine.buildAtlasImage(
          image: ItemType.isTypeGameObject(itemType)
              ? GameImages.atlas_gameobjects
              : GameImages.atlas_items,
          srcX: AtlasItems.getSrcX(itemType),
          srcY: AtlasItems.getSrcY(itemType),
          srcWidth: AtlasItems.getSrcWidth(itemType),
          srcHeight: AtlasItems.getSrcHeight(itemType),
        ),
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
        visibleBuilder(GameOptions.inventory, GameUIInteract.buildWatchInteractMode()),
        watch(ClientState.hoverIndex,
            GameInventoryUI.buildPositionedContainerItemTypeInformation),
        watch(ClientState.hoverTargetType,
            GameInventoryUI.buildPositionedContainerHoverTarget),
        Positioned(
          child: Container(
            width: Engine.screen.width,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPlayerWeapons(),
              ],
            ),
          ),
          bottom: GameStyle.Default_Padding,
        ),
        Positioned(
            bottom: GameStyle.Default_Padding,
            left: GameStyle.Default_Padding,
            child: Row(
              children: [
                buildPanelCredits(),
                width16,
                buildPanelTotalGrenades(),
              ],
            )),
            visibleBuilder(
            GameOptions.inventory,
            Positioned(
              bottom: GameStyle.Default_Padding,
              right: GameStyle.Default_Padding,
              child: buildDialogUIControl(
                child: buildColumnBelt(),
              ),
            )),
          Positioned(
              top: GameStyle.Default_Padding,
              left: GameStyle.Default_Padding,
              child: visibleBuilder(
                  ClientState.window_visible_items,
                  buildWindowPlayerItems(),
              ),
              // child: buildWindowPlayerItems(),
          ),
          Positioned(
            top: GameStyle.Default_Padding,
            left: GameStyle.Window_PlayerItems_Width + (GameStyle.Default_Padding * 2),
            child: buildWindowMouseOverItemType(),
          ),
          Positioned(
            child: buildWindowPerks(),
            left: GameStyle.Default_Padding,
            top: GameStyle.Default_Padding,
          )
      ]);

  static Row buildPanelCredits() {
    return Row(
                children: [
                  buildAtlasItemType(ItemType.Resource_Credit),
                  width4,
                  watch(ClientState.playerCreditsAnimation, (value) => text(value, size: 25)),
                ],
              );
  }

  static Widget buildWindowMouseOverItemType(){
    return watch(GamePlayer.items_reads, (_){
      return watch(GameOptions.ItemType_Damage, (MapListInt itemMap){
        return watch(ClientState.mouseOverItemType, (int itemType){
          if (itemType < 0) return GameStyle.Null;
          final entry = itemMap[itemType];
          if (entry == null) return GameStyle.Null;
          final currentLevel = GamePlayer.items[itemType] ?? 1;
          return buildContainer(
            width: GameStyle.Window_PlayerItems_Width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: buildAtlasItemType(itemType),
                    ),
                    text(ItemType.getName(itemType), size: 22, color: Colors.white70)
                  ],
                ),
                text("Damage: ${capIndex(entry, currentLevel)}"),
              ],
            ),
          );
        });
      });
    });

  }

  static Widget buildContainer({required Widget child, double? width}) =>
    buildDialogUIControl(
        child: Container(
          padding: GameStyle.Padding_6,
          color: GameStyle.Container_Color,
          width: width,
          child: child,
      )
    );

  static int mapItemTabToIconType(ItemGroup itemTab) => const {
      ItemGroup.Primary_Weapon: IconType.Primary_Weapon,
      ItemGroup.Secondary_Weapon: IconType.Secondary_Weapon,
      ItemGroup.Tertiary_Weapon: IconType.Tertiary_Weapon,
      ItemGroup.Head_Type: IconType.Head_Type,
      ItemGroup.Body_Type: IconType.Body_Type,
      ItemGroup.Legs_Type: IconType.Leg_Type,
      ItemGroup.Unknown: IconType.Bag_White,
    }[itemTab] ?? IconType.Unknown;

  static Widget buildIconItemTab(ItemGroup itemTab) =>
      onPressed(
          action: ClientState.itemGroup.value != itemTab
              ? () => ClientState.itemGroup.value = itemTab
              : null,
          child: Container(
            width: 50,
              height: 50,
              color: ClientState.itemGroup.value == itemTab ? Colors.white12 : Colors.transparent,
              child: buildAtlasIconType(mapItemTabToIconType(itemTab))),
              );

  static Widget buildWindowPlayerItems(){
      return watch(GamePlayer.items_reads, (t) {
        return watch(ClientState.itemGroup, (ItemGroup activeItemGroup) {
          return buildContainer(
            width: GameStyle.Window_PlayerItems_Width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const[
                      ItemGroup.Primary_Weapon,
                      // ItemGroup.Secondary_Weapon,
                      ItemGroup.Tertiary_Weapon,
                      ItemGroup.Unknown,
                    ].map(buildIconItemTab).toList()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: GamePlayer
                      .getItemTypesByItemGroup(activeItemGroup)
                      .map((itemType) => buildItemRow(
                        itemType: itemType,
                        itemValue: GamePlayer.items[itemType] ?? 0,
                      )
                  ).toList(),
                ),
              ],
            ),
          );
        });
      });
  }

  static Widget buildItemRow({
    required int itemType,
    required int itemValue,
  }){
    return watch(GamePlayer.getItemTypeWatch(itemType), (int equippedItemType) {
       final active = equippedItemType == itemType;
       final fullyUpgraded = itemValue >= 5;
       final cost = fullyUpgraded ? 0 : GameOptions.ItemType_Cost.value[itemType]?[itemValue] ?? 0;

       return MouseRegion(
         onEnter: (_){
           ClientState.mouseOverItemType.value = itemType;
         },
         onExit: (_){
           if (ClientState.mouseOverItemType.value == itemType) {
             ClientState.mouseOverItemType.value = -1;
           }
         },
         child: onPressed(
           action: () =>
               GameNetwork.sendClientRequest(ClientRequest.Equip, itemType),
           child: Container(
             color: active ? Colors.white24 : Colors.transparent,
             padding: GameStyle.Padding_6,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Container(
                     constraints: const BoxConstraints(maxWidth: 150),
                     child: buildAtlasItemType(itemType),
                     height: 50,
                     alignment: Alignment.center,
                     color: Colors.black12,
                     padding: GameStyle.Padding_4,
                 ),
                 if (itemValue > 0) buildItemTypeBars(itemValue),
                 onPressed(
                   action: fullyUpgraded ? null : () => GameNetwork.sendClientRequest(
                       ClientRequest.Purchase_Item,
                       itemType,
                   ),
                   child: Container(
                     width: 100,
                     alignment: Alignment.center,
                     color: Colors.white12,
                     padding: GameStyle.Padding_6,
                     child:
                     fullyUpgraded ? text("MAX", color: GameColors.white60) :
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         watch(ServerState.playerCredits, (int playerCredits) {
                           return text(itemValue < 1 ? "BUY" : "UPGRADE", color: cost <= playerCredits ? Colors.white : Colors.white38);
                         }),
                         Row(
                           children: [
                             Container(
                                 width: 12,
                                 height: 12,
                                 child: buildAtlasItemType(ItemType.Resource_Credit)),
                             width2,
                             text(cost),
                           ],
                         )
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ),
       );
    });
  }

  static Widget buildItemTypeBars(int amount) => Row(
        children: List.generate(5, (i) => Container(
                  width: 8,
                  height: 15,
                  color: i < amount ? GameColors.blue : GameColors.blue05,
                  margin: i < 4 ? const EdgeInsets.only(right: 5) : null,
                )
        )
  );

  static Widget buildItemRow2({
    required Watch<int> watch,
    required int itemType,
    required int amount,
    required bool active,
  }){
    return onPressed(
      action: () =>
          GameNetwork.sendClientRequest(ClientRequest.Equip, itemType),
      child: Container(
        color: active ? Colors.white24 : Colors.transparent,
        padding: GameStyle.Padding_6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                buildAtlasItemType(itemType),
                width8,
                text(ItemType.getName(itemType)),
              ],
            ),
            text(amount),
          ],
        ),
      ),
    );
  }

  static Widget buildWindowPerks() =>
    visibleBuilder(GameOptions.perks, Container(
      color: GameStyle.Container_Color,
      padding: GameStyle.Padding_6,
      child: Column(
          children: PerkType.Values.map((perkType) => Row(children: [
            text(PerkType.getName(perkType))
          ],)).toList()
      ),
    ));


  static Widget buildPanelTotalGrenades() {
    return watch(GamePlayer.totalGrenades, (int totalGrenades) => totalGrenades <= 0
                  ? GameStyle.Null
                  : Tooltip(
      message: "Press SPACE to throw grenade",
                    child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            child: buildAtlasItemType(
                                ItemType.GameObjects_Grenade),
                          ),
                          width4,
                          text(totalGrenades, size: 25),
                        ],
                      ),
                  ));
  }

  static Widget buildHudPlayerWeapon() => watch(GamePlayer.weapon, (int weaponType){
    final consumeType = ItemType.getConsumeType(weaponType);
      return buildDialogUIControl(
        child: GameInventoryUI.buildHoverTarget(
            child: Container(
              width: 240,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    color: Colors.black12,
                    padding: GameStyle.Padding_6,
                    child: buildAtlasItemType(weaponType),
                  ),
                  if (consumeType != ItemType.Empty)
                    Container(
                      height: 50,
                      color: Colors.black12,
                      padding: GameStyle.Padding_6,
                      margin: const EdgeInsets.only(left: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildAtlasItemType(consumeType),
                          watch(ClientState.inventoryReads, (int value){
                            return text('${ServerQuery.getEquippedWeaponQuantity()} / ${ServerQuery.countItemTypeQuantityInPlayerPossession(consumeType)}', size: 25);
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            hoverTargetType: ClientType.Hover_Target_Player_Stats_Damage,
        ),
      );
  });


  static Widget buildPlayerWeapons() => watch(GamePlayer.weapon, (int playerWeaponType){
    const Border_Width = 3.0;
    return buildDialogUIControl(
      child: Row(
        children: [
          buildPlayerHealth(),
          width4,
          // watch(GamePlayer.weaponRanged, (int playerWeaponRanged) {
             Row(
               children: [
                 watch(GamePlayer.weaponPrimary, (int itemType) {
                   final active = playerWeaponType == itemType;
                   return border(
                     color: active ? playerWeaponType == itemType ? Colors.white70 : Colors.black54 : Colors.transparent,
                     width: Border_Width,
                     child: Container(
                       constraints: BoxConstraints(maxWidth: 120),
                       height: GameStyle.Player_Weapons_Icon_Size,
                       color: active ? Colors.black45 : Colors.black12,
                       padding: GameStyle.Padding_4,
                       child: buildAtlasItemType(itemType),
                     ),
                   );
                 }),
                 width4,
                 watch(GamePlayer.weaponSecondary, (int itemType) {
                   final active = playerWeaponType == itemType;
                   return border(
                     color: active ? playerWeaponType == itemType ? Colors.white70 : Colors.black54 : Colors.transparent,
                     width: Border_Width,
                     child: Container(
                       height: GameStyle.Player_Weapons_Icon_Size,
                       color: active ? Colors.black45 : Colors.black12,
                       padding: GameStyle.Padding_2,
                       child: buildAtlasItemType(itemType),
                     ),
                   );
                 }),
               ],
             ),
          // }),
          // width32,
          // buildIconPlayerWeaponMelee(),
          width4,
          buildPlayerEnergy(),
        ],
      ),
    );
  });

  static Widget buildIconPlayerWeaponMelee(){
    return watch(GamePlayer.weapon, (int playerWeaponType){
      return watch(GamePlayer.weaponTertiary, (int itemType) {
        return border(
          color: playerWeaponType == itemType ? Colors.white70 : Colors.black54,
          width: 3,
          child: Container(
            height: GameStyle.Player_Weapons_Icon_Size,
            color: Colors.black45,
            padding: GameStyle.Padding_2,
            child: buildAtlasItemType(itemType),
          ),
        );
      });
    });
  }

  static Widget buildPlayerHealth() {
    return border(
          width: GameStyle.Player_Weapons_Border_Size,
          color: GameColors.Red_3,
          child: Container(
            width: GameStyle.Player_Weapons_Icon_Size,
            height: GameStyle.Player_Weapons_Icon_Size,
            alignment: Alignment.center,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  width: GameStyle.Player_Weapons_Icon_Size,
                  height: GameStyle.Player_Weapons_Icon_Size,
                  alignment: Alignment.topCenter,
                  child: watch(ServerState.playerMaxHealth, (int maxHealth) {
                    return watch(ServerState.playerHealth, (int health){
                       final percentage = health / max(maxHealth, 1);
                       return Container(
                         width: GameStyle.Player_Weapons_Icon_Size,
                         height: GameStyle.Player_Weapons_Icon_Size * percentage,
                         color: GameColors.Red_3,
                       );
                    });
                  }),
                ),
                Container(
                    width: 40,
                    height: 40,
                    child: FittedBox(
                      child: buildAtlasIconType(
                          IconType.Heart,
                          color: Colors.black87.value,
                      ),
                    )
                ),
              ],

            ),
          ),
        );
  }

  static Widget buildPlayerEnergy() {
    return border(
          width: GameStyle.Player_Weapons_Border_Size,
          color: GameColors.yellow,
          child: Container(
            width: GameStyle.Player_Weapons_Icon_Size,
            height: GameStyle.Player_Weapons_Icon_Size,
            alignment: Alignment.center,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  width: GameStyle.Player_Weapons_Icon_Size,
                  height: GameStyle.Player_Weapons_Icon_Size,
                  alignment: Alignment.topCenter,
                  child: watch(GamePlayer.energyMax, (int energyMax) {
                    return watch(GamePlayer.energy, (int energy){
                       return Container(
                         width: GameStyle.Player_Weapons_Icon_Size,
                         height: GameStyle.Player_Weapons_Icon_Size * energy / max(energyMax, 1),
                         color:  GameColors.yellow,
                       );
                    });
                  }),
                ),
                Container(
                    width: 40,
                    height: 40,
                    child: FittedBox(
                      child: buildAtlasIconType(
                        IconType.Energy,
                        color: Colors.black87.value,
                      ),
                    )
                ),
              ],
            ),
          ),
        );
  }


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
        buildAtlasItemType(itemType),
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

  static Widget buildWatchPlayerLevel() => watch(
      ServerState.playerLevel,
      (int level) => Tooltip(
            child: watch(
                ServerState.playerExperiencePercentage, buildPlayerExperienceBar),
            message: "Level $level",
          ));

  static Widget buildPlayerExperienceBar(double experience) =>
      buildDialogUIControl(
        child: Container(
          width: GameStyle.ExperienceBarWidth,
          height: GameStyle.ExperienceBarHeight,
          color: GameStyle.ExperienceBarColorBackground,
          alignment: Alignment.centerLeft,
          child: Container(
            width: GameStyle.ExperienceBarWidth * experience,
            height: GameStyle.ExperienceBarHeight,
            color: GameStyle.ExperienceBarColorFill,
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
      top: 150,
      child: Container(
        width: Engine.screen.width,
        alignment: Alignment.center,
        child: GameUI.buildDialogUIControl(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text('YOU DIED', size: 30),
              height8,
              container(
                alignment: Alignment.center,
                child: "RESPAWN",
                action: GameNetwork.sendClientRequestRespawn,
                color: GameColors.Red_3,
                width: width * Engine.GoldenRatio_0_618,
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildTime() => Tooltip(
    message: "Time",
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WatchBuilder(ServerState.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(ServerState.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    ),
  );

  int getItemTypeIconColor(int itemType){
    return const <int, int> {

    }[itemType] ?? 0;
  }
}
