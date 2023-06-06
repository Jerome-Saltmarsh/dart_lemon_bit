


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:bleed_common/src/capture_the_flag/src.dart';

class CaptureTheFlagGame extends GameIsometric {

  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);

  final flagPositionRed = Vector3();
  final flagPositionBlue = Vector3();

  final flagStatusRed = Watch(CaptureTheFlagFlagStatus.At_Base);
  final flagStatusBlue = Watch(CaptureTheFlagFlagStatus.At_Base);

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    engine.paint.color = Colors.red;
    engine.drawLine(player.renderX, player.renderY, flagPositionRed.renderX, flagPositionRed.renderY);
    engine.paint.color = Colors.blue;
    engine.drawLine(player.renderX, player.renderY, flagPositionBlue.renderX, flagPositionBlue.renderY);
  }

  @override
  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: 16,
            right: 16,
            child: buildMiniMap(mapSize: 200),
        ),
        Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: GameStyle.Container_Padding,
              color: GameStyle.Container_Color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    text("SCORE"),
                    WatchBuilder(scoreRed, (score) => text("RED: $score")),
                    WatchBuilder(scoreBlue, (score) => text("BlUE: $score")),
                ],
              ),
            ),
        ),
        Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: GameStyle.Container_Padding,
              color: GameStyle.Container_Color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text("FLAG STATUS"),
                  WatchBuilder(flagStatusRed, (status) => text("RED STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
                  WatchBuilder(flagStatusBlue, (status) => text("BLUE STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
                ],
              ),
            )),
        Positioned(
            top: 16,
            right: 16,
            child: GameIsometricUI.buildRowMainMenu(),
        ),
      ],
    );
  }

  Widget buildMiniMap({required double mapSize}) {
    return IgnorePointer(
      child: Container(
        width: mapSize + 3,
        height: mapSize + 3,
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
              width: mapSize,
              height: mapSize,
              child:   watch(gamestream.games.isometric.clientState.sceneChanged, (_){
            return engine.buildCanvas(paint: (Canvas canvas, Size size){
              const scale = 2.0;
              canvas.scale(scale, scale);
              final screenCenterX = size.width * 0.5;
              final screenCenterY = size.height * 0.5;
              const ratio = 2 / 48.0;

              final chaseTarget = gamestream.games.isometric.camera.chaseTarget;
              if (chaseTarget != null){
                final targetX = chaseTarget.renderX * ratio;
                final targetY = chaseTarget.renderY * ratio;
                final translate = mapSize / 4;
                final cameraX = targetX - (screenCenterX / scale) - translate;
                final cameraY = targetY - (screenCenterY / scale) - translate;
                canvas.translate(-cameraX, -cameraY);
              }

              gamestream.games.isometric.minimap.renderCanvas(canvas);

              final serverState = gamestream.games.isometric.serverState;
              final player = gamestream.games.isometric.player;

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
          })
        ),
        ),
      ),
    );
  }



}