import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_icons.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:golden_ratio/constants.dart';

import 'isometric_colors.dart';


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
      GSContainer(
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
                      buildText('SOUND', size: 20, color: Colors.white70),
                      buildWatch(gamestream.audio.enabledSound, buildIconCheckbox),
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
                      buildText('MUSIC', size: 20, color: Colors.white70),
                      buildWatch(gamestream.audio.mutedMusic, (bool muted) => buildIconCheckbox(!muted)),
                    ],
                  ),
                ),
              ),
              height6,
              onPressed(
                action: gamestream.engine.fullscreenToggle,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('FULLSCREEN', size: 20, color: Colors.white70),
                      buildWatch(gamestream.engine.fullScreen, buildIconCheckbox),
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
                child: buildText('DISCONNECT', size: 25),
              ),
              height24,
            ],
          ),
        ),
    );

  static Widget buildGeneratedMiniMap({required double translate}){
    return buildWatch(gamestream.isometric.client.nodesChangedNotifier, (_){
      return gamestream.engine.buildCanvas(paint: (Canvas canvas, Size size){
        const scale = 2.0;
        canvas.scale(scale, scale);
        final screenCenterX = size.width * 0.5;
        final screenCenterY = size.height * 0.5;
        const ratio = 2 / 48.0;

        final chaseTarget = gamestream.isometric.camera.target;
        if (chaseTarget != null){
          final targetX = chaseTarget.renderX * ratio;
          final targetY = chaseTarget.renderY * ratio;
          final cameraX = targetX - (screenCenterX / scale) - translate;
          final cameraY = targetY - (screenCenterY / scale) - translate;
          canvas.translate(-cameraX, -cameraY);
        }

        gamestream.isometric.minimap.renderCanvas(canvas);

        final scene = gamestream.isometric.scene;
        final serverState = gamestream.isometric.server;
        final player = gamestream.isometric.player;

        for (var i = 0; i < scene.totalCharacters; i++) {
          final character = scene.characters[i];
          final isPlayer = player.isCharacter(character);
          gamestream.engine.renderExternalCanvas(
              canvas: canvas,
              image: Images.atlas_gameobjects,
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

  static Positioned buildPositionedMessageStatus() => Positioned(
    bottom: 150,
    child: IgnorePointer(
      child: Container(
        width: gamestream.engine.screen.width,
        alignment: Alignment.center,
        child: buildWatch(gamestream.isometric.client.messageStatus, buildMessageStatus),
      ),
    ),
  );


  static Widget buildMessageStatus(String message){
    if (message.isEmpty) return nothing;
    return MouseRegion(
      onEnter: (_){
        gamestream.isometric.client.messageClear();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black12,
        child: buildText(message, onPressed: gamestream.isometric.client.messageClear),),
    );
  }

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
          : buildWatch(gamestream.isometric.client.touchButtonSide, buildStackInputModeTouch);

  static Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: buildWatch(
          gamestream.rendersSinceUpdate,
              (int frames) =>
              buildText('Warning: No message received from server $frames')));

  static Widget buildMainMenu({List<Widget>? children}) {
    final controlTime = buildTime();
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        // gamestream.isometric.ui.mouseOverDialog.value = true;
        gamestream.isometric.ui.windowOpenMenu.value = true;
      },
      onExit: (PointerExitEvent event) {
        // gamestream.isometric.ui.mouseOverDialog.value = false;
        gamestream.isometric.ui.windowOpenMenu.value = false;
      },
      child: buildWatch(gamestream.isometric.ui.windowOpenMenu, (bool menuVisible){
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
        hint: 'toggle sound',
        action: gamestream.audio.toggleMutedSound,
        child: Container(
          width: 32,
          child: buildWatch(gamestream.audio.enabledSound, (bool t) =>
              GameIsometricUI.buildAtlasIconType(t ? IconType.Sound_Enabled : IconType.Sound_Disabled, scale: Icon_Scale)
          ),
        ),
      );

  static Widget buildIconAudioMusic() =>
      onPressed(
        hint: 'toggle music',
        action: gamestream.audio.toggleMutedMusic,
        child: buildWatch(gamestream.audio.mutedMusic, (bool musicMuted) =>
            Container(
                width: 32,
                child: GameIsometricUI.buildAtlasIconType(musicMuted ? IconType.Music_Disabled : IconType.Music_Enabled))
        ),
      );

  static Widget buildIconFullscreen() => WatchBuilder(
      gamestream.engine.fullScreen,
          (bool fullscreen) => onPressed(
          hint: 'toggle fullscreen',
          action: gamestream.engine.fullscreenToggle,
          child: Container(
              width: 32,
              child: GameIsometricUI.buildAtlasIconType(IconType.Fullscreen, scale: Icon_Scale))));

  static Widget buildIconZoom() => onPressed(
      action: gamestream.isometric.toggleZoom, child: buildAtlasIconType(IconType.Zoom, scale: Icon_Scale));

  static Widget buildIconMenu() => onPressed(
      action: gamestream.isometric.ui.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Home),
      )
  );

  static Widget buildIconCog() => onPressed(
      action: gamestream.isometric.ui.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Cog),
      )
  );

  static Widget buildIconCogTurned() => onPressed(
      action: gamestream.isometric.ui.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Cog_Turned),
      )
  );

  static Widget buildAtlasIconType(IconType iconType,
      {double scale = 1, int color = 1}) =>
      FittedBox(
        child: gamestream.engine.buildAtlasImage(
          image: Images.atlas_icons,
          srcX: AtlasIcons.getSrcX(iconType),
          srcY: AtlasIcons.getSrcY(iconType),
          srcWidth: AtlasIcons.getSrcWidth(iconType),
          srcHeight: AtlasIcons.getSrcHeight(iconType),
          scale: scale,
          color: color,
        ),
      );

  static Widget buildAtlasItemType({
    required int type,
    required int subType,
    int color = 1,
  }) {
    final src = Atlas.getSrc(type, subType);

    return FittedBox(
        child: gamestream.engine.buildAtlasImage(
          image: Images.getImageForGameObject(type),
          srcX: src[Atlas.SrcX],
          srcY: src[Atlas.SrcY],
          srcWidth: src[Atlas.SrcWidth],
          srcHeight: src[Atlas.SrcHeight],
          color: color,
        ),
      );
  }

  static Widget buildAtlasNodeType(int nodeType) => gamestream.engine.buildAtlasImage(
    image: Images.atlas_nodes,
    srcX: AtlasNodeX.mapNodeType(nodeType),
    srcY: AtlasNodeY.mapNodeType(nodeType),
    srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
    srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
  );

  static Widget buildItemTypeBars(int amount) => Row(
      children: List.generate(5, (i) => Container(
        width: 8,
        height: 15,
        color: i < amount ? IsometricColors.blue : IsometricColors.blue05,
        margin: i < 4 ? const EdgeInsets.only(right: 5) : null,
      )
      )
  );

  static Widget buildIconCombatPowerType(int powerType){
    assert (CombatPowerType.values.contains(powerType));
    final powerTypeIcon = const <int, IconType> {
      CombatPowerType.None      : IconType.Power_None,
      CombatPowerType.Bomb      : IconType.Power_Bomb,
      CombatPowerType.Teleport  : IconType.Power_Teleport,
      CombatPowerType.Invisible : IconType.Power_Invisible,
      CombatPowerType.Shield    : IconType.Power_Shield,
      CombatPowerType.Stun      : IconType.Power_Stun,
      CombatPowerType.Revive    : IconType.Power_Revive,
    }[powerType] ?? (throw Exception());
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
          color: index < level ? IsometricColors.blue : IsometricColors.blue05,
          margin: const EdgeInsets.only(right: 2),
        );
      }),
    );
  }

  // static Widget buildIconPlayerWeaponMelee(){
  //   return buildWatch(gamestream.isometric.player.weapon, (int playerWeaponType){
  //     return buildWatch(gamestream.isometric.player.weaponTertiary, (int itemType) {
  //       return buildBorder(
  //         color: playerWeaponType == itemType ? Colors.white70 : Colors.black54,
  //         width: 3,
  //         child: Container(
  //           height: GameStyle.Player_Weapons_Icon_Size,
  //           color: Colors.black45,
  //           padding: GameStyle.Padding_2,
  //           child: buildAtlasItemType(itemType),
  //         ),
  //       );
  //     });
  //   });
  // }

  static Widget buildPlayerHealth() {
    final height = 87.0;
    final width = height * goldenRatio_0618;
    return buildBorder(
      width: GameStyle.Player_Weapons_Border_Size,
      color: IsometricColors.Red_3,
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
              child: buildWatch(gamestream.isometric.player.maxHealth, (int maxHealth) {
                return buildWatch(gamestream.isometric.player.health, (int health){
                  final percentage = health / max(maxHealth, 1);
                  return Container(
                    width: width,
                    height: height * percentage,
                    color: IsometricColors.Red_3,
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
    return buildBorder(
      width: GameStyle.Player_Weapons_Border_Size,
      color: IsometricColors.yellow,
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
              child: buildWatch(gamestream.isometric.player.energyMax, (int energyMax) {
                return buildWatch(gamestream.isometric.player.energy, (int energy){
                  return Container(
                    width: width,
                    height: height * energy / max(energyMax, 1),
                    color:  IsometricColors.yellow,
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
    return buildWatch(gamestream.isometric.server.sceneEditable, (bool isOwner) {
      if (!isOwner) return const SizedBox();
      return buildWatch(gamestream.isometric.client.edit, (bool edit) {
        return buildButton(
            toolTip: 'Tab',
            child: edit ? 'PLAY' : 'EDIT',
            action: gamestream.isometric.actionToggleEdit,
            color: IsometricColors.green,
            alignment: Alignment.center,
            width: 100);
      });
    });
  }

  static Widget buildTime() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      WatchBuilder(gamestream.isometric.server.hours, (int hours){
        return buildText(padZero(hours), size: 22);
      }),
      buildText(':', size: 22),
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
    GameIsometricUI.textEditingControllerMessage.text = '';
  }


}
