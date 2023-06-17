import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_icons.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/dialog_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player_score.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/widgets/animated_widget.dart';
import 'package:golden_ratio/constants.dart';

import 'game_isometric_colors.dart';


const nothing = SizedBox();

class GameIsometricUI {
  static const Server_FPS = 45;
  static const Icon_Scale = 1.5;
  static final messageBoxVisible = Watch(false, clamp: (bool value) {
    return value;
  }, onChanged: onVisibilityChangedMessageBox);
  static final textEditingControllerMessage = TextEditingController();
  static final textFieldMessage = FocusNode();
  static final panelTypeKey = <int, GlobalKey>{};
  static final playerTextStyle = TextStyle(color: Colors.white);
  static final timeVisible = Watch(true);

  static Widget buildMapCircle({required double size}) {
    return IgnorePointer(
      child: Container(
        width: size + 3,
        height: size + 3,
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
              ),
              width: size,
              height: size,
              child: buildGeneratedMiniMap(translate: size / 4.0)),
        ),
      ),
    );
  }

  static Widget buildWindowCharacterCreation() {

    const textSize = 22;

    const weaponTypes = const [
      ItemType.Weapon_Ranged_Plasma_Rifle,
      ItemType.Weapon_Ranged_Plasma_Pistol,
      ItemType.Weapon_Ranged_Shotgun,
      ItemType.Weapon_Ranged_Bazooka,
      ItemType.Weapon_Ranged_Sniper_Rifle,
      ItemType.Weapon_Ranged_Flamethrower,
      ItemType.Weapon_Ranged_Teleport,
      // ItemType.Weapon_Melee_Knife,
      ItemType.Weapon_Melee_Crowbar,
      ItemType.Weapon_Melee_Sword,
    ];

    const titleFontSize = 22;
    const titleFontColor = Colors.white24;

    const containerWidth = 150.0;
    const containerHeight = 300.0;

    final columnPowers = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        text('space-bar', size: titleFontSize, color: titleFontColor, italic: true),
        height12,
        buildIconPlayerPowerType(),
        height24,
        Container(
          width: containerWidth,
          height: containerHeight,
          child: SingleChildScrollView(
            child: Column(
                children: const <int> [
                  PowerType.Bomb,
                  PowerType.Stun,
                  PowerType.Invisible,
                  PowerType.Shield,
                  PowerType.Teleport,
                ].map((int powerType){
                  return onPressed(
                    action: () => gamestream.network.sendClientRequest(ClientRequest.Select_Power, powerType),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: watch(gamestream.isometric.player.powerType, (int playerPowerType){
                        return text(PowerType.getName(powerType),
                          color: powerType == playerPowerType ? GameIsometricColors.orange : GameIsometricColors.white80,
                          size: textSize,
                        );
                      }),
                    ),
                  );
                }).toList(growable: false)
            ),
          ),
        ),
      ],
    );

    final columnSelectWeaponLeft = watch(gamestream.isometric.player.weaponPrimary, (int weaponPrimary) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          text('left-click', size: titleFontSize, color: titleFontColor, italic: true),
          height12,
          buildIconPlayerWeaponPrimary(),
          height24,
          Container(
            height: containerHeight,
            width: containerWidth,
            child: SingleChildScrollView(
              child: Column(
                children: (weaponTypes).map((int itemType) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: onPressed(
                      action: () => gamestream.network.sendClientRequestSelectWeaponPrimary(itemType),
                      child: text(ItemType.getName(itemType),
                        color: weaponPrimary == itemType ? GameIsometricColors.orange : GameIsometricColors.white80,
                        size: textSize,
                      )),
                ),
                ).toList(growable: false),
              ),
            ),
          ),
          // buildIconPlayerWeaponPrimary(),
        ],
      );
    });

    final columnSelectWeaponRight = watch(gamestream.isometric.player.weaponSecondary, (int weaponSecondary) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          text('right-click', size: titleFontSize, color: titleFontColor, italic: true),
          height12,
          buildIconPlayerWeaponSecondary(),
          height24,
          Container(
            width: containerWidth,
            height: containerHeight,
            child: SingleChildScrollView(
              child: Column(
                children: (weaponTypes).map((int itemType) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: onPressed(
                      action: () => gamestream.network.sendClientRequestSelectWeaponSecondary(itemType),
                      child: text(ItemType.getName(itemType),
                        color: weaponSecondary == itemType ? GameIsometricColors.orange : GameIsometricColors.white80,
                        size: textSize,
                      )),
                ),
                ).toList(growable: false),
              ),
            ),
          ),
        ],
      );
    });

    final buttonPlay = onPressed(
      action: gamestream.isometric.revive,
      child: MouseOver(
          builder: (mouseOver) {
            return Container(
              width: 150,
              height: 150 * goldenRatio_0381,
              alignment: Alignment.center,
              color: GameIsometricColors.green.withAlpha(mouseOver ? 140 : 100),
              child: text("START", size: 45, color: GameIsometricColors.green),
            );
          }
      ),
    );

    return buildFullscreen(
      child: buildDialogUIControl(
        child: Container(
          width: 600,
          padding: GameStyle.Padding_6,
          color: GameStyle.Container_Color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              height32,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  columnSelectWeaponLeft,
                  columnPowers,
                  columnSelectWeaponRight,
                ],
              ),
              height64,
              buttonPlay,
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildWindowMenuItem({
    required String title,
    required  Widget child,
  }) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text(title, size: 20, color: Colors.white70),
          child,
        ],
      );

  static Widget buildWindowMenu({List<Widget>? children}){
    const width = 200.0;
    return buildDialogUIControl(
      child: Container(
        width: width,
        alignment: Alignment.center,
        color: GameStyle.Container_Color,
        padding: GameStyle.Container_Padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            onPressed(
              action: gamestream.audio.toggleMutedSound,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("SOUND", size: 20, color: Colors.white70),
                    watch(gamestream.audio.enabledSound, buildIconCheckbox),
                  ],
                ),
              ),
            ),
            height6,
            onPressed(
              action: gamestream.audio.toggleMutedMusic,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("MUSIC", size: 20, color: Colors.white70),
                    watch(gamestream.audio.mutedMusic, (bool muted) => buildIconCheckbox(!muted)),
                  ],
                ),
              ),
            ),
            height6,
            onPressed(
              action: engine.fullscreenToggle,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("FULLSCREEN", size: 20, color: Colors.white70),
                    watch(engine.fullScreen, buildIconCheckbox),
                  ],
                ),
              ),
            ),
            if (children != null)
              height6,
            if (children != null)
              ...children,
            height24,
            onPressed(
              action: gamestream.network.disconnect,
              child: text("DISCONNECT", size: 25),
            ),
            height24,
          ],
        ),
      ),
    );
  }

  static Widget buildWindowLightSettings(){
    return Container(
      padding: GameStyle.Padding_6,
      color: GameIsometricColors.brownDark,
      width: 300,
      child: Column(
        children: [
          text("Light-Settings", bold: true),
          height8,
          onPressed(
              action: gamestream.isometric.clientState.toggleDynamicShadows,
              child: Refresh(() => text('dynamic-shadows-enabled: ${gamestream.isometric.clientState.dynamicShadows}'))
          ),
          onPressed(
              child: Refresh(() => text('blend-mode: ${engine.bufferBlendMode.name}')),
              action: (){
                final currentIndex = BlendMode.values.indexOf(engine.bufferBlendMode);
                final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                engine.bufferBlendMode = BlendMode.values[nextIndex];
              }
          ),
          height8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text("<-", onPressed: (){
                gamestream.isometric.nodes.setInterpolationLength(gamestream.isometric.nodes.interpolation_length - 1);
              }),
              Refresh(() => text('light-size: ${gamestream.isometric.nodes.interpolation_length}')),
              text("->", onPressed: (){
                gamestream.isometric.nodes.setInterpolationLength(gamestream.isometric.nodes.interpolation_length + 1);
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text("<-", onPressed: (){
                final indexCurrent = EaseType.values.indexOf(gamestream.isometric.nodes.interpolation_ease_type.value);
                final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
                gamestream.isometric.nodes.interpolation_ease_type.value = EaseType.values[indexNext];
              }),
              watch(gamestream.isometric.nodes.interpolation_ease_type, text),
              text("->", onPressed: (){
                final indexCurrent = EaseType.values.indexOf(gamestream.isometric.nodes.interpolation_ease_type.value);
                final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
                gamestream.isometric.nodes.interpolation_ease_type.value = EaseType.values[indexNext];
              }),
            ],
          ),

          height16,
          text("ambient-color"),
          ColorPicker(
            portraitOnly: true,
            pickerColor: HSVColor.fromAHSV(
              gamestream.isometric.nodes.ambient_alp / 255,
              gamestream.isometric.nodes.ambient_hue.toDouble(),
              gamestream.isometric.nodes.ambient_sat / 100,
              gamestream.isometric.nodes.ambient_val / 100,
            ).toColor(),
            onColorChanged: (color){
              gamestream.isometric.clientState.overrideColor.value = true;
              final hsvColor = HSVColor.fromColor(color);
              gamestream.isometric.nodes.ambient_alp = (hsvColor.alpha * 255).round();
              gamestream.isometric.nodes.ambient_hue = hsvColor.hue.round();
              gamestream.isometric.nodes.ambient_sat = (hsvColor.saturation * 100).round();
              gamestream.isometric.nodes.ambient_val = (hsvColor.value * 100).round();
              gamestream.isometric.nodes.resetNodeColorsToAmbient();
            },
          ),
        ],
      ),
    );
  }

  static Widget buildGeneratedMiniMap({required double translate}){
    return watch(gamestream.isometric.clientState.sceneChanged, (_){
      return engine.buildCanvas(paint: (Canvas canvas, Size size){
        const scale = 2.0;
        canvas.scale(scale, scale);
        final screenCenterX = size.width * 0.5;
        final screenCenterY = size.height * 0.5;
        const ratio = 2 / 48.0;

        final chaseTarget = gamestream.isometric.camera.chaseTarget;
        if (chaseTarget != null){
          final targetX = chaseTarget.renderX * ratio;
          final targetY = chaseTarget.renderY * ratio;
          final cameraX = targetX - (screenCenterX / scale) - translate;
          final cameraY = targetY - (screenCenterY / scale) - translate;
          canvas.translate(-cameraX, -cameraY);
        }

        gamestream.isometric.minimap.renderCanvas(canvas);

        final serverState = gamestream.isometric.server;
        final player = gamestream.isometric.player;

        for (var i = 0; i < serverState.totalCharacters; i++) {
          final character = serverState.characters[i];
          final isPlayer = player.isCharacter(character);
          engine.renderExternalCanvas(
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
    return watch(gamestream.isometric.server.gameStatus, (int gameStatus) {
      if (gameStatus == GameStatus.Playing) return GameStyle.Null;
      return IgnorePointer(
        child: Positioned(
          top: 60,
          child: Container(
              alignment: Alignment.center,
              width: engine.screen.width,
              child: text("Waiting for more players to join")),
        ),
      );
    });
  }

  static Positioned buildPositionedAreaType() => Positioned(
    top: 75,
    child: Container(
        width: engine.screen.width,
        alignment: Alignment.center,
        child: buildWatchAreaType()
    ),
  );

  static Positioned buildPositionedMessageStatus() => Positioned(
    bottom: 150,
    child: IgnorePointer(
      child: Container(
        width: engine.screen.width,
        alignment: Alignment.center,
        child: watch(gamestream.isometric.clientState.messageStatus, buildMessageStatus),
      ),
    ),
  );


  static Widget buildMessageStatus(String message){
    if (message.isEmpty) return GameStyle.Null;
    return MouseRegion(
      onEnter: (_){
        gamestream.isometric.clientState.messageClear();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black12,
        child: text(message, onPressed: gamestream.isometric.clientState.messageClear),),
    );
  }

  static WatchBuilder<int> buildWatchAreaType() =>
      WatchBuilder(gamestream.isometric.server.areaType, (int areaType) {
        return WatchBuilder(gamestream.isometric.clientState.areaTypeVisible, (bool areaTypeVisible){
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
    // Positioned(
    //   right: side ? GameUIConfig.runButtonPadding : null,
    //   left: side ? null : GameUIConfig.runButtonPadding,
    //   child: Container(
    //     height: engine.screen.height,
    //     alignment: Alignment.center,
    //     child: onPressed(
    //       action: GameUIConfig.runButtonPressed,
    //       child: Container(
    //         width: GameUIConfig.runButtonSize,
    //         height: GameUIConfig.runButtonSize,
    //         alignment: Alignment.center,
    //         child: watch(gamestream.isometricEngine.player.weapon, (int itemType) => buildAtlasItemType(itemType)),
    //         decoration: BoxDecoration(
    //           shape: BoxShape.circle,
    //           border: Border.all(color: Colors.white70, width: 5),
    //           color: GameUIConfig.runButtonColor,
    //         ),
    //       ),
    //     ),
    //   ),
    // ),
  ]);

  static Widget buildStackInputMode(int inputMode) =>
      inputMode == InputMode.Keyboard
          ? GameStyle.Null
          : watch(gamestream.isometric.clientState.touchButtonSide, buildStackInputModeTouch);

  static Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: watch(
          gamestream.isometric.clientState.rendersSinceUpdate,
              (int frames) =>
              text("Warning: No message received from server $frames")));

  static Positioned buildWatchInterpolation() => Positioned(
    bottom: 0,
    left: 0,
    child: watch(gamestream.isometric.player.interpolating, (bool value) {
      if (!value)
        return text("Interpolation Off",
            onPressed: () => gamestream.isometric.player.interpolating.value = true);
      return watch(gamestream.isometric.clientState.rendersSinceUpdate, (int frames) {
        return text("Frames: $frames",
            onPressed: () => gamestream.isometric.player.interpolating.value = false);
      });
    }),
  );

  static Widget buildWindowPlayerRespawnTimer(){
    return buildWatchBool(gamestream.isometric.clientState.control_visible_respawn_timer, () {
      return Container(
        width: 240,
        height: 240 * goldenRatio_0381,
        color: GameStyle.Container_Color,
        padding: GameStyle.Container_Padding,
        alignment: Alignment.center,
        child: watch(gamestream.isometric.player.respawnTimer, (int respawnTimer){
          return text("RESPAWN: ${respawnTimer ~/ Server_FPS}", size: 25);
        }),
      );
    });
  }

  static Widget buildPlayersScore(){
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          watch(gamestream.isometric.server.highScore, (int highScore){
            return text('WORLD RECORD: $highScore');
          }),
          height8,
          watch(gamestream.isometric.server.playerScoresReads, (_) => Container(
            padding: GameStyle.Padding_6,
            color: Colors.black26,
            constraints: BoxConstraints(
              maxHeight: 400,
            ),
            width: 180,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: gamestream.isometric.server.playerScores
                      .map(buildRowPlayerScore)
                      .toList(growable: false)
              ),
            ),
          )),
        ],
      ),
    );
  }

  static Widget buildRowPlayerScore(IsometricPlayerScore playerScore) =>
      Container(
        color: playerScore.id == gamestream.isometric.player.id.value
            ? Colors.white10
            : Colors.transparent,
        padding: GameStyle.Padding_4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text(playerScore.name, bold: playerScore.id == gamestream.isometric.player.id.value),
            text(playerScore.credits, bold: playerScore.id == gamestream.isometric.player.id.value),
          ],
        ),
      );

  static Widget buildMainMenu({List<Widget>? children}) {
    final controlTime = buildTime();

    final panel = watch(gamestream.isometric.clientState.window_visible_menu, (bool menuVisible){
      return Container(
        color: menuVisible ? GameStyle.Container_Color : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            height16,
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  controlTime,
                  width32,
                  menuVisible ? buildIconCogTurned() : buildIconCog(),
                  width16,
                ]
            ),
            if (menuVisible)
              buildWindowMenu(children: children),
          ],
        ),
      );
    });

    return GameIsometricUI.buildDialogUIControl(
      child: MouseOver(
        onEnter: gamestream.isometric.clientState.window_visible_menu.setTrue,
        onExit: gamestream.isometric.clientState.window_visible_menu.setFalse,
        builder: (bool mouseOver) => panel,
      ),
    );
  }

  static Widget buildIconAudioSound() =>
      onPressed(
        hint: "toggle sound",
        action: gamestream.audio.toggleMutedSound,
        child: Container(
          width: 32,
          child: watch(gamestream.audio.enabledSound, (bool t) =>
              GameIsometricUI.buildAtlasIconType(t ? IconType.Sound_Enabled : IconType.Sound_Disabled, scale: Icon_Scale)
          ),
        ),
      );

  static Widget buildIconAudioMusic() =>
      onPressed(
        hint: 'toggle music',
        action: gamestream.audio.toggleMutedMusic,
        child: watch(gamestream.audio.mutedMusic, (bool musicMuted) =>
            Container(
                width: 32,
                child: GameIsometricUI.buildAtlasIconType(musicMuted ? IconType.Music_Disabled : IconType.Music_Enabled))
        ),
      );

  static Widget buildIconFullscreen() => WatchBuilder(
      engine.fullScreen,
          (bool fullscreen) => onPressed(
          hint: "toggle fullscreen",
          action: engine.fullscreenToggle,
          child: Container(
              width: 32,
              child: GameIsometricUI.buildAtlasIconType(IconType.Fullscreen, scale: Icon_Scale))));

  static Widget buildIconZoom() => onPressed(
      action: gamestream.isometric.actions.toggleZoom, child: buildAtlasIconType(IconType.Zoom, scale: Icon_Scale));

  static Widget buildIconMenu() => onPressed(
      action: gamestream.isometric.clientState.window_visible_menu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Home),
      )
  );

  static Widget buildIconCog() => onPressed(
      action: gamestream.isometric.clientState.window_visible_menu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Cog),
      )
  );

  static Widget buildIconCogTurned() => onPressed(
      action: gamestream.isometric.clientState.window_visible_menu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Cog_Turned),
      )
  );

  static Widget buildIconSlotEmpty() =>
      buildAtlasIconType(IconType.Slot, scale: GameInventoryUI.Slot_Scale);

  static Widget buildAtlasIconType(int iconType,
      {double scale = 1, int color = 1}) =>
      FittedBox(
        child: engine.buildAtlasImage(
          image: GameImages.atlas_icons,
          srcX: AtlasIcons.getSrcX(iconType),
          srcY: AtlasIcons.getSrcY(iconType),
          srcWidth: AtlasIcons.getSrcWidth(iconType),
          srcHeight: AtlasIcons.getSrcHeight(iconType),
          scale: scale,
          color: color,
        ),
      );

  static Widget buildAtlasItemType(int itemType, {int color = 1}) =>
      FittedBox(
        child: engine.buildAtlasImage(
          image: ItemType.isTypeGameObject(itemType)
              ? GameImages.atlas_gameobjects
              : GameImages.atlas_items,
          srcX: AtlasItems.getSrcX(itemType),
          srcY: AtlasItems.getSrcY(itemType),
          srcWidth: AtlasItems.getSrcWidth(itemType),
          srcHeight: AtlasItems.getSrcHeight(itemType),
          color: color,
        ),
      );

  static Widget buildAtlasNodeType(int nodeType) => engine.buildAtlasImage(
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
          gamestream.isometric.ui.hoverDialogType.value = dialogType;
        },
        onExit: (PointerExitEvent event) {
          gamestream.isometric.ui.hoverDialogType.value = DialogType.None;
        },
        child: child,
      );

  static Widget buildPlayMode(bool edit) =>
      edit ? buildEditor() : watch(gamestream.gameType, buildStackPlay);

  static Widget buildEditor(){
    return watch(gamestream.isometric.editor.editTab, EditorUI.buildUI);
  }

  static Widget buildStackPlay(GameType gameType) => StackFullscreen(children: [
    if (gameType == GameType.Combat)
      buildWatchBool(gamestream.isometric.clientState.window_visible_player_creation, buildWindowCharacterCreation),
    if (gameType == GameType.Combat)
      buildWatchBool(gamestream.isometric.clientState.control_visible_respawn_timer, () =>
          Positioned(
            bottom: GameStyle.Default_Padding,
            left: 0,
            child: Container(
                width: engine.screen.width,
                alignment: Alignment.center,
                child: buildWindowPlayerRespawnTimer()),
          )
      ),
    buildWatchBool(gamestream.isometric.clientState.control_visible_player_power, (){
      return buildWatchBool(gamestream.isometric.player.powerReady, () =>
          Positioned(
            child: buildIconPlayerPowerType(),
            left: GameStyle.Default_Padding,
            bottom: GameStyle.Default_Padding,
          )
      );
    }),

  ]);

  static Widget buildPanelCredits() {
    return Column(
      children: [
        Container(
            width: 64,
            height: 64,
            child: buildAtlasItemType(ItemType.Resource_Credit)),
        width4,
        watch(gamestream.isometric.clientState.playerCreditsAnimation, (value) => text(value, size: 25)),
      ],
    );
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
        action: gamestream.isometric.clientState.itemGroup.value != itemTab
            ? () => gamestream.isometric.clientState.itemGroup.value = itemTab
            : null,
        child: Container(
            width: 50,
            height: 50,
            color: gamestream.isometric.clientState.itemGroup.value == itemTab ? Colors.white12 : Colors.transparent,
            child: buildAtlasIconType(mapItemTabToIconType(itemTab))),
      );

  // static Widget buildWindowPlayerItems(){
  //     return watch(gamestream.isometricEngine.player.items_reads, (t) {
  //       return watch(gamestream.isometricEngine.clientState.itemGroup, (ItemGroup activeItemGroup) {
  //         return buildContainer(
  //           width: GameStyle.Window_PlayerItems_Width,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: const[
  //                     ItemGroup.Primary_Weapon,
  //                     // ItemGroup.Secondary_Weapon,
  //                     ItemGroup.Tertiary_Weapon,
  //                     ItemGroup.Unknown,
  //                   ].map(buildIconItemTab).toList()),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: gamestream.isometricEngine.player
  //                     .getItemTypesByItemGroup(activeItemGroup)
  //                     .map((itemType) => buildItemRow(
  //                       itemType: itemType,
  //                       itemValue: gamestream.isometricEngine.player.items[itemType] ?? 0,
  //                     )
  //                 ).toList(),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  //     });
  // }

  // static Widget buildItemRow({
  //   required int itemType,
  //   required int itemValue,
  // }){
  //   return watch(gamestream.isometricEngine.player.getItemTypeWatch(itemType), (int equippedItemType) {
  //      final active = equippedItemType == itemType;
  //      final fullyUpgraded = itemValue >= 5;
  //      final cost = fullyUpgraded ? 0 : GameOptions.ItemType_Cost.value[itemType]?[itemValue] ?? 0;
  //
  //      return MouseRegion(
  //        onEnter: (_){
  //          gamestream.isometricEngine.clientState.mouseOverItemType.value = itemType;
  //        },
  //        onExit: (_){
  //          if (gamestream.isometricEngine.clientState.mouseOverItemType.value == itemType) {
  //            gamestream.isometricEngine.clientState.mouseOverItemType.value = -1;
  //          }
  //        },
  //        child: onPressed(
  //          action: () =>
  //              GameNetwork.sendClientRequest(ClientRequest.Equip, itemType),
  //          child: Container(
  //            color: active ? Colors.white24 : Colors.transparent,
  //            padding: GameStyle.Padding_6,
  //            child: Row(
  //              mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //              children: [
  //                Container(
  //                    constraints: const BoxConstraints(maxWidth: 150),
  //                    child: buildAtlasItemType(itemType),
  //                    height: 50,
  //                    alignment: Alignment.center,
  //                    color: Colors.black12,
  //                    padding: GameStyle.Padding_4,
  //                ),
  //                if (itemValue > 0) buildItemTypeBars(itemValue),
  //                onPressed(
  //                  action: fullyUpgraded ? null : () => GameNetwork.sendClientRequest(
  //                      ClientRequest.Purchase_Item,
  //                      itemType,
  //                  ),
  //                  child: Container(
  //                    width: 100,
  //                    alignment: Alignment.center,
  //                    color: Colors.white12,
  //                    padding: GameStyle.Padding_6,
  //                    child:
  //                    fullyUpgraded ? text("MAX", color: GameIsometricColors.white60) :
  //                    Row(
  //                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                      children: [
  //                        watch(gamestream.isometricEngine.serverState.playerCredits, (int playerCredits) {
  //                          return text(itemValue < 1 ? "BUY" : "UPGRADE", color: cost <= playerCredits ? Colors.white : Colors.white38);
  //                        }),
  //                        Row(
  //                          children: [
  //                            Container(
  //                                width: 12,
  //                                height: 12,
  //                                child: buildAtlasItemType(ItemType.Resource_Credit)),
  //                            width2,
  //                            text(cost),
  //                          ],
  //                        )
  //                      ],
  //                    ),
  //                  ),
  //                ),
  //              ],
  //            ),
  //          ),
  //        ),
  //      );
  //   });
  // }

  static Widget buildItemTypeBars(int amount) => Row(
      children: List.generate(5, (i) => Container(
        width: 8,
        height: 15,
        color: i < amount ? GameIsometricColors.blue : GameIsometricColors.blue05,
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
          gamestream.network.sendClientRequest(ClientRequest.Equip, itemType),
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

  static Widget buildIconPlayerPowerType(){
    return watch(gamestream.isometric.player.powerReady, (bool powerReady) {
      return !powerReady ? width64 :
      watch(gamestream.isometric.player.powerType, buildIconPowerType);
    });
  }

  static Widget buildPanelTotalGrenades() {
    final icon = Container(
      width: 48,
      height: 48,
      child: buildAtlasItemType(
          ItemType.Weapon_Thrown_Grenade),
    );
    return buildDialogUIControl(
      child: Tooltip(
        message: 'SPACE-BAR',
        child: watch(gamestream.isometric.player.totalGrenades, (int totalGrenades) => Row(
            children: List.generate(totalGrenades, (index) => icon))
        ),
      ),
    );
  }

  static Widget buildWatchBuff(Watch<int> buffDuration, int buffType){

    final container = Container(
      margin: const EdgeInsets.only(right: 4),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            child: buildAtlasItemType(buffType),
          ),
          height4,
          // Container(
          //   color: Colors.black26,
          //   child: watch(buffDuration, text),
          // ),
          text(ItemType.getName(buffType)),
        ],
      ),
    );

    return watch(buffDuration, (int duration) {
      if (duration <= 0) return GameStyle.Null;
      return container;
    });
  }

  // static Widget buildRowPlayerWeapons() => IgnorePointer(
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         buildIconPlayerWeaponPrimary(),
  //         width96,
  //         buildIconPlayerPowerType(),
  //         width96,
  //         buildIconPlayerWeaponSecondary(),
  //       ],
  //     ),
  // );

  static Container buildIconPlayerWeaponSecondary() {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      height: 64,
      child: watch(gamestream.isometric.player.weaponSecondary, buildAtlasItemType),
    );
  }

  static Widget buildIconPowerType(int powerType){
    assert (PowerType.values.contains(powerType));
    final powerTypeIcon = const <int, int> {
      PowerType.None      : IconType.Power_None,
      PowerType.Bomb      : IconType.Power_Bomb,
      PowerType.Teleport  : IconType.Power_Teleport,
      PowerType.Invisible : IconType.Power_Invisible,
      PowerType.Shield    : IconType.Power_Shield,
      PowerType.Stun      : IconType.Power_Stun,
      PowerType.Revive    : IconType.Power_Revive,
    }[powerType] ?? -1;
    return Container(
      height: 64,
      constraints: BoxConstraints(maxWidth: 120),
      child: buildAtlasIconType(powerTypeIcon),
    );
  }

  static Container buildIconPlayerWeaponPrimary() {
    return Container(
      constraints: BoxConstraints(maxWidth: 120, maxHeight: 64),
      height: 64,
      child: watch(gamestream.isometric.player.weaponPrimary, buildAtlasItemType),
    );
  }

  static Widget buildRowItemTypeLevel(int level){
    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: 5,
          height: 20,
          color: index < level ? GameIsometricColors.blue : GameIsometricColors.blue05,
          margin: const EdgeInsets.only(right: 2),
        );
      }),
    );
  }

  static Widget buildIconPlayerWeaponMelee(){
    return watch(gamestream.isometric.player.weapon, (int playerWeaponType){
      return watch(gamestream.isometric.player.weaponTertiary, (int itemType) {
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
    final height = 87.0;
    final width = height * goldenRatio_0618;
    return border(
      width: GameStyle.Player_Weapons_Border_Size,
      color: GameIsometricColors.Red_3,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: width,
              height: height,
              alignment: Alignment.topCenter,
              child: watch(gamestream.isometric.server.playerMaxHealth, (int maxHealth) {
                return watch(gamestream.isometric.server.playerHealth, (int health){
                  final percentage = health / max(maxHealth, 1);
                  return Container(
                    width: width,
                    height: height * percentage,
                    color: GameIsometricColors.Red_3,
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
    final height = 87.0;
    final width = height * goldenRatio_0618;
    return border(
      width: GameStyle.Player_Weapons_Border_Size,
      color: GameIsometricColors.yellow,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: width,
              height: height,
              alignment: Alignment.topCenter,
              child: watch(gamestream.isometric.player.energyMax, (int energyMax) {
                return watch(gamestream.isometric.player.energy, (int energy){
                  return Container(
                    width: width,
                    height: height * energy / max(energyMax, 1),
                    color:  GameIsometricColors.yellow,
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
      buildWatchBeltType(gamestream.isometric.server.playerBelt5_ItemType),
      width64,
      buildWatchBeltType(gamestream.isometric.server.playerBelt6_ItemType),
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
            gamestream.isometric.clientState.onAcceptDragInventoryIcon();
          },
          builder: (context, data, dataRejected){
            return onPressed(
              hint: "Inventory",
              action: gamestream.network.sendClientRequestInventoryToggle,
              onRightClick: gamestream.network.sendClientRequestInventoryToggle,
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
      buildWatchBeltType(gamestream.isometric.server.playerBelt1_ItemType),
      buildWatchBeltType(gamestream.isometric.server.playerBelt2_ItemType),
      buildWatchBeltType(gamestream.isometric.server.playerBelt3_ItemType),
      buildWatchBeltType(gamestream.isometric.server.playerBelt4_ItemType),
    ],
  );

  static Widget buildDragTargetSlot({required int index, double scale = 1.0, Color? outlineColor}) =>
      DragTarget<int>(
        builder: (context, data, rejectedData) =>
            Container(
              width: 64,
              height: 64,
              decoration: buildDecorationBorder(
                colorBorder: outlineColor ?? GameIsometricColors.brown01,
                colorFill: GameIsometricColors.brown02,
                width: 2,
              ),
            ),
        onWillAccept: (int? data) => data != null,
        onAccept: (int? data) {
          if (data == null) return;
          gamestream.network.sendClientRequestInventoryMove(
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
              watch(gamestream.isometric.server.equippedWeaponIndex, (equippedWeaponIndex) =>
                  buildDragTargetSlot(
                      index: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType),
                      scale: 2.0,
                      outlineColor: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType) == equippedWeaponIndex ? GameIsometricColors.white : GameIsometricColors.brown02
                  ),),
              Positioned(
                left: 5,
                top: 5,
                child: text(mapWatchBeltTypeTokeyboardKeyString(watchBeltType)),
              ),
              if (beltItemType != ItemType.Empty)
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  child: GameInventoryUI.buildDraggableItemIndex(
                    itemIndex: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType),
                    scale: 2,
                  ),
                ),

              if (beltItemType != ItemType.Empty)
                Positioned(
                    right: 5,
                    bottom: 5,
                    child: buildInventoryAware(
                        builder: () => text(
                          gamestream.isometric.server.getWatchBeltTypeWatchQuantity(watchBeltType).value,
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
                  gamestream.isometric.server.getItemTypeConsumesRemaining(itemType),
                  italic: true,
                  color: Colors.white70,
                ))),
      if (itemType != ItemType.Empty && gamestream.isometric.player.weapon.value == itemType)
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
      watch(gamestream.isometric.clientState.inventoryReads, (int reads) => builder());

  static Widget buildWatchPlayerLevel() => watch(
      gamestream.isometric.server.playerLevel,
          (int level) => Tooltip(
        child: watch(
            gamestream.isometric.server.playerExperiencePercentage, buildPlayerExperienceBar),
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
    return watch(gamestream.isometric.server.sceneEditable, (bool isOwner) {
      if (!isOwner) return const SizedBox();
      return watch(gamestream.isometric.clientState.edit, (bool edit) {
        return container(
            toolTip: "Tab",
            child: edit ? "PLAY" : "EDIT",
            action: gamestream.isometric.actions.actionToggleEdit,
            color: GameIsometricColors.green,
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
        width: engine.screen.width,
        alignment: Alignment.center,
        child: GameIsometricUI.buildDialogUIControl(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text('YOU DIED', size: 30),
              height8,
              container(
                alignment: Alignment.center,
                child: "RESPAWN",
                action: gamestream.isometric.revive,
                color: GameIsometricColors.Red_3,
                width: width * Engine.GoldenRatio_0_618,
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildTime() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      WatchBuilder(gamestream.isometric.server.hours, (int hours){
        return text(padZero(hours), size: 22);
      }),
      text(":", size: 22),
      WatchBuilder(gamestream.isometric.server.minutes, (int minutes){
        return text(padZero(minutes), size: 22);
      }),
    ],
  );

  int getItemTypeIconColor(int itemType){
    return const <int, int> {

    }[itemType] ?? 0;
  }

  static Widget buildIconCheckbox(bool value) => Container(
    width: 32,
    child: buildAtlasIconType(value ? IconType.Checkbox_True : IconType.Checkbox_False),
  );

  static String mapWatchBeltTypeTokeyboardKeyString(Watch<int> hotKeyWatch){
    if (hotKeyWatch == gamestream.isometric.server.playerBelt1_ItemType) return '1';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt2_ItemType) return '2';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt3_ItemType) return '3';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt4_ItemType) return '4';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt5_ItemType) return 'Q';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt6_ItemType) return 'E';
    throw Exception("ClientQuery.mapHotKeyWatchToString($hotKeyWatch)");
  }
}
