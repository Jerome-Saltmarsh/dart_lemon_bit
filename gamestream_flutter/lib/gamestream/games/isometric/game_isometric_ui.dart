import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_icons.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player_score.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_dialog.dart';
import 'package:gamestream_flutter/widgets/build_button.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:golden_ratio/constants.dart';

import 'game_isometric_colors.dart';


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

  static Widget buildWindowMenuItem({
    required String title,
    required  Widget child,
  }) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildText(title, size: 20, color: Colors.white70),
          child,
        ],
      );

  static Widget buildWindowMenu({List<Widget>? children, double width = 200}) =>
      GSDialog(
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
                      buildText("SOUND", size: 20, color: Colors.white70),
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
                      buildText("MUSIC", size: 20, color: Colors.white70),
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
                      buildText("FULLSCREEN", size: 20, color: Colors.white70),
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
                child: buildText("DISCONNECT", size: 25),
              ),
              height24,
            ],
          ),
        ),
    );

  static Widget buildWindowLightSettings(){
    return Container(
      padding: GameStyle.Padding_6,
      color: GameIsometricColors.brownDark,
      width: 300,
      child: Column(
        children: [
          buildText("Light-Settings", bold: true),
          height8,
          onPressed(
              action: gamestream.isometric.clientState.toggleDynamicShadows,
              child: Refresh(() => buildText('dynamic-shadows-enabled: ${gamestream.isometric.clientState.dynamicShadows}'))
          ),
          onPressed(
              child: Refresh(() => buildText('blend-mode: ${engine.bufferBlendMode.name}')),
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
              buildText("<-", onPressed: (){
                gamestream.isometric.nodes.setInterpolationLength(gamestream.isometric.nodes.interpolation_length - 1);
              }),
              Refresh(() => buildText('light-size: ${gamestream.isometric.nodes.interpolation_length}')),
              buildText("->", onPressed: (){
                gamestream.isometric.nodes.setInterpolationLength(gamestream.isometric.nodes.interpolation_length + 1);
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText("<-", onPressed: (){
                final indexCurrent = EaseType.values.indexOf(gamestream.isometric.nodes.interpolation_ease_type.value);
                final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
                gamestream.isometric.nodes.interpolation_ease_type.value = EaseType.values[indexNext];
              }),
              watch(gamestream.isometric.nodes.interpolation_ease_type, buildText),
              buildText("->", onPressed: (){
                final indexCurrent = EaseType.values.indexOf(gamestream.isometric.nodes.interpolation_ease_type.value);
                final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
                gamestream.isometric.nodes.interpolation_ease_type.value = EaseType.values[indexNext];
              }),
            ],
          ),

          height16,
          buildText("ambient-color"),
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
      if (gameStatus == GameStatus.Playing) return nothing;
      return IgnorePointer(
        child: Positioned(
          top: 60,
          child: Container(
              alignment: Alignment.center,
              width: engine.screen.width,
              child: buildText("Waiting for more players to join")),
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
    if (message.isEmpty) return nothing;
    return MouseRegion(
      onEnter: (_){
        gamestream.isometric.clientState.messageClear();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black12,
        child: buildText(message, onPressed: gamestream.isometric.clientState.messageClear),),
    );
  }

  static WatchBuilder<int> buildWatchAreaType() =>
      WatchBuilder(gamestream.isometric.server.areaType, (int areaType) {
        return WatchBuilder(gamestream.isometric.clientState.areaTypeVisible, (bool areaTypeVisible){
          return IgnorePointer(
            child: AnimatedOpacity(
              opacity: areaTypeVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: buildText(AreaType.getName(areaType), size: 30),
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
          ? nothing
          : watch(gamestream.isometric.clientState.touchButtonSide, buildStackInputModeTouch);

  static Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: watch(
          gamestream.rendersSinceUpdate,
              (int frames) =>
              buildText("Warning: No message received from server $frames")));

  static Positioned buildWatchInterpolation() => Positioned(
    bottom: 0,
    left: 0,
    child: watch(gamestream.isometric.player.interpolating, (bool value) {
      if (!value)
        return buildText("Interpolation Off",
            onPressed: () => gamestream.isometric.player.interpolating.value = true);
      return watch(gamestream.rendersSinceUpdate, (int frames) {
        return buildText("Frames: $frames",
            onPressed: () => gamestream.isometric.player.interpolating.value = false);
      });
    }),
  );

  static Widget buildPlayersScore(){
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          watch(gamestream.isometric.server.highScore, (int highScore){
            return buildText('WORLD RECORD: $highScore');
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
            buildText(playerScore.name, bold: playerScore.id == gamestream.isometric.player.id.value),
            buildText(playerScore.credits, bold: playerScore.id == gamestream.isometric.player.id.value),
          ],
        ),
      );

  static Widget buildMainMenu({List<Widget>? children}) {
    final controlTime = buildTime();
    return GSDialog(
      child: watch(gamestream.isometric.clientState.window_visible_menu, (bool menuVisible){
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
      }),
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

  static Widget buildPanelCredits() {
    return Column(
      children: [
        Container(
            width: 64,
            height: 64,
            child: buildAtlasItemType(ItemType.Resource_Credit)),
        width4,
        watch(gamestream.isometric.clientState.playerCreditsAnimation, (value) => buildText(value, size: 25)),
      ],
    );
  }

  static Widget buildContainer({required Widget child, double? width}) =>
      GSDialog(
          child: Container(
            padding: GameStyle.Padding_6,
            color: GameStyle.Container_Color,
            width: width,
            child: child,
          )
      );

  static Widget buildItemTypeBars(int amount) => Row(
      children: List.generate(5, (i) => Container(
        width: 8,
        height: 15,
        color: i < amount ? GameIsometricColors.blue : GameIsometricColors.blue05,
        margin: i < 4 ? const EdgeInsets.only(right: 5) : null,
      )
      )
  );

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
          buildText(ItemType.getName(buffType)),
        ],
      ),
    );

    return watch(buffDuration, (int duration) {
      if (duration <= 0) return nothing;
      return container;
    });
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

  static Widget buildPlayerExperienceBar(double experience) =>
      GSDialog(
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
        return buildButton(
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
        child: GSDialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildText('YOU DIED', size: 30),
              height8,
              buildButton(
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
        return buildText(padZero(hours), size: 22);
      }),
      buildText(":", size: 22),
      WatchBuilder(gamestream.isometric.server.minutes, (int minutes){
        return buildText(padZero(minutes), size: 22);
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

  static void onVisibilityChangedMessageBox(bool visible){
    if (visible) {
      GameIsometricUI.textFieldMessage.requestFocus();
      return;
    }
    GameIsometricUI.textFieldMessage.unfocus();
    GameIsometricUI.textEditingControllerMessage.text = "";
  }


}
