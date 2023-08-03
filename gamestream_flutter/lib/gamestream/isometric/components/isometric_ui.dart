import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_icons.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';
import 'package:gamestream_flutter/utils.dart';


class IsometricUI with IsometricComponent {
  static const Icon_Scale = 1.5;

  Widget buildMapCircle({required double size}) {
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

  Widget buildWindowMenuItem({
    required String title,
    required  Widget child,
  }) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildText(title, size: 20, color: Colors.white70),
          child,
        ],
      );

  Widget buildWindowMenu({List<Widget>? children, double width = 200}) =>
      GSContainer(
        child: Container(
          width: width,
          alignment: Alignment.center,
          color: style.containerColor,
          padding: style.containerPadding,
          child: IsometricBuilder(
            builder: (context, isometric) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  onPressed(
                    action: audio.toggleMutedSound,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText('SOUND', size: 20, color: Colors.white70),
                          buildWatch(audio.enabledSound, buildIconCheckbox),
                        ],
                      ),
                    ),
                  ),
                  height6,
                  onPressed(
                    action: audio.toggleMutedMusic,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText('MUSIC', size: 20, color: Colors.white70),
                          buildWatch(audio.mutedMusic, (bool muted) => buildIconCheckbox(!muted)),
                        ],
                      ),
                    ),
                  ),
                  height6,
                  onPressed(
                    action: isometric.engine.fullscreenToggle,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText('FULLSCREEN', size: 20, color: Colors.white70),
                          buildWatch(isometric.engine.fullScreen, buildIconCheckbox),
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
                    action: network.websocket.disconnect,
                    child: buildText('DISCONNECT', size: 25),
                  ),
                  height24,
                ],
              );
            }
          ),
        ),
    );

  Widget buildGeneratedMiniMap({required double translate}){
    return IsometricBuilder(
      builder: (context, isometric) {
        return buildWatch(isometric.scene.nodesChangedNotifier, (_){
          return isometric.engine.buildCanvas(paint: (Canvas canvas, Size size){
            const scale = 2.0;
            canvas.scale(scale, scale);
            final screenCenterX = size.width * 0.5;
            final screenCenterY = size.height * 0.5;
            const ratio = 2 / 48.0;

            final chaseTarget = isometric.camera.target;
            if (chaseTarget != null){
              final targetX = chaseTarget.renderX * ratio;
              final targetY = chaseTarget.renderY * ratio;
              final cameraX = targetX - (screenCenterX / scale) - translate;
              final cameraY = targetY - (screenCenterY / scale) - translate;
              canvas.translate(-cameraX, -cameraY);
            }

            isometric.minimap.renderCanvas(canvas);

            final player = isometric.player;

            for (var i = 0; i < isometric.scene.totalCharacters; i++) {
              final character = isometric.scene.characters[i];
              final isPlayer = player.isCharacter(character);
              isometric.engine.renderExternalCanvas(
                  canvas: canvas,
                  image: isometric.images.atlas_gameobjects,
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
    );
  }

  Positioned buildPositionedMessageStatus() => Positioned(
    bottom: 150,
    child: IgnorePointer(
      child: Container(
        width: engine.screen.width,
        alignment: Alignment.center,
        child: buildWatch(options.messageStatus, buildMessageStatus),
      ),
    ),
  );


  Widget buildMessageStatus(String message){
    if (message.isEmpty) return nothing;
    return MouseRegion(
      onEnter: (_){
        action.messageClear();
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.black12,
          child: buildText(message, onPressed: action.messageClear)),
    );
  }

  Widget buildDialogFramesSinceUpdate() => Positioned(
      top: 8,
      left: 8,
      child: buildWatch(
          options.rendersSinceUpdate,
              (int frames) =>
              buildText('Warning: No message received from server $frames')));

  Widget buildMainMenu({List<Widget>? children}) {
    final controlTime = buildTime();
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        options.windowOpenMenu.value = true;
      },
      onExit: (PointerExitEvent event) {
        options.windowOpenMenu.value = false;
      },
      child: buildWatch(options.windowOpenMenu, (bool menuVisible){
        return Container(
          color: menuVisible ? style.containerColor : Colors.transparent,
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

  Widget buildIconAudioSound() =>
      onPressed(
        hint: 'toggle sound',
        action: audio.toggleMutedSound,
        child: Container(
          width: 32,
          child: buildWatch(audio.enabledSound, (bool t) =>
              buildAtlasIconType(t ? IconType.Sound_Enabled : IconType.Sound_Disabled, scale: Icon_Scale)
          ),
        ),
      );

  Widget buildIconAudioMusic() =>
      onPressed(
        hint: 'toggle music',
        action: audio.toggleMutedMusic,
        child: buildWatch(audio.mutedMusic, (bool musicMuted) =>
            Container(
                width: 32,
                child: buildAtlasIconType(musicMuted ? IconType.Music_Disabled : IconType.Music_Enabled))
        ),
      );

  Widget buildIconFullscreen() => WatchBuilder(
      engine.fullScreen,
          (bool fullscreen) => onPressed(
          hint: 'toggle fullscreen',
          action: engine.fullscreenToggle,
          child: Container(
              width: 32,
              child: buildAtlasIconType(IconType.Fullscreen, scale: Icon_Scale))));

  Widget buildIconZoom() => onPressed(
      action: action.toggleZoom, child: buildAtlasIconType(IconType.Zoom, scale: Icon_Scale));

  Widget buildIconMenu() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Home),
      )
  );

  Widget buildIconCog() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Cog),
      )
  );

  Widget buildIconCogTurned() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 32,
        child: buildAtlasIconType(IconType.Cog_Turned),
      )
  );

  Widget buildAtlasIconType(IconType iconType,
      {double scale = 1, int color = 1}) =>
      FittedBox(
        child: engine.buildAtlasImage(
          image: images.atlas_icons,
          srcX: AtlasIcons.getSrcX(iconType),
          srcY: AtlasIcons.getSrcY(iconType),
          srcWidth: AtlasIcons.getSrcWidth(iconType),
          srcHeight: AtlasIcons.getSrcHeight(iconType),
          scale: scale,
          color: color,
        ),
      );

  Widget buildAtlasNodeType(int nodeType) => engine.buildAtlasImage(
    image: images.atlas_nodes,
    srcX: AtlasNodeX.mapNodeType(nodeType),
    srcY: AtlasNodeY.mapNodeType(nodeType),
    srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
    srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
  );

  Widget buildItemTypeBars(int amount) => Row(
      children: List.generate(5, (i) => Container(
        width: 8,
        height: 15,
        color: i < amount ? Colors.blue : Colors.blue.withOpacity(0.5),
        margin: i < 4 ? const EdgeInsets.only(right: 5) : null,
      )
      )
  );

  Widget buildRowItemTypeLevel(int level){
    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: 5,
          height: 20,
          color: index < level ? Colors.blue : Colors.blue.withOpacity(0.5),
          margin: const EdgeInsets.only(right: 2),
        );
      }),
    );
  }

  Widget buildButtonTogglePlayMode() {
    return buildWatch(scene.sceneEditable, (bool isOwner) {
      if (!isOwner) return const SizedBox();
      return buildWatch(options.edit, (bool edit) {
        return buildButton(
            toolTip: 'Tab',
            child: edit ? 'PLAY' : 'EDIT',
            action: options.toggleEditMode,
            color: Colors.green,
            alignment: Alignment.center,
            width: 100);
      });
    });
  }

  Widget buildTime() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      WatchBuilder(environment.hours, (int hours) =>
          buildText(padZero(hours), size: 22)),
      buildText(':', size: 22),
      WatchBuilder(environment.minutes, (int minutes) =>
          buildText(padZero(minutes), size: 22)),
    ],
  );

  int getItemTypeIconColor(int itemType){
    return const <int, int> {

    }[itemType] ?? 0;
  }

  Widget buildIconCheckbox(bool value) => Container(
    width: 32,
    child: buildAtlasIconType(value ? IconType.Checkbox_True : IconType.Checkbox_False),
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

  Widget buildImageGameObject(int objectType) =>
      buildImageFromSrc(
        images.atlas_gameobjects,
        Atlas.getSrc(GameObjectType.Object, objectType),
      );

  Widget buildImageFromSrc(ui.Image image, List<double> src) =>
      IsometricBuilder(builder: (context, isometric) =>
          isometric.engine.buildAtlasImage(
            image: image,
            srcX: src[Atlas.SrcX],
            srcY: src[Atlas.SrcY],
            srcWidth: src[Atlas.SrcWidth],
            srcHeight: src[Atlas.SrcHeight],
          ));
}
