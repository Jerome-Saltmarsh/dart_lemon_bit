


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:bleed_common/src/capture_the_flag/src.dart';

class CaptureTheFlagGame extends GameIsometric {

  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);

  final flagPositionRed = IsometricPosition();
  final flagPositionBlue = IsometricPosition();

  final basePositionRed = IsometricPosition();
  final basePositionBlue = IsometricPosition();

  late final flagRedStatus = Watch(CaptureTheFlagFlagStatus.At_Base, onChanged: onChangedFlagRedStatus);
  late final flagBlueStatus = Watch(CaptureTheFlagFlagStatus.At_Base, onChanged: onChangedFlagBlueStatus);

  CaptureTheFlagGame({required super.isometric});

  bool get playerIsTeamRed => player.team.value == CaptureTheFlagTeam.Red;
  bool get playerIsTeamBlue => player.team.value == CaptureTheFlagTeam.Blue;

  void onChangedFlagRedStatus(int flagStatus) {
    if (playerIsTeamRed) {
       switch (flagStatus) {
         case CaptureTheFlagFlagStatus.Carried_By_Allie:
           gamestream.audio.voiceAnAllyHasYourFlag.play();
           break;
         case CaptureTheFlagFlagStatus.Carried_By_Enemy:
           gamestream.audio.voiceTheEnemyHasYourFlag.play();
           break;
         case CaptureTheFlagFlagStatus.At_Base:
           gamestream.audio.voiceYourFlagIsAtYourBase.play();
           break;
         case CaptureTheFlagFlagStatus.Dropped:
           gamestream.audio.voiceYourFlagHasBeenDropped.play();
           break;
       }
       return;
    }

    assert (playerIsTeamBlue);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Allie:
        gamestream.audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        gamestream.audio.voiceAnAllyHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        gamestream.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        gamestream.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void onChangedFlagBlueStatus(int flagStatus) {
    if (playerIsTeamBlue) {
       switch (flagStatus) {
         case CaptureTheFlagFlagStatus.Carried_By_Allie:
           gamestream.audio.voiceAnAllyHasYourFlag.play();
           break;
         case CaptureTheFlagFlagStatus.Carried_By_Enemy:
           gamestream.audio.voiceTheEnemyHasYourFlag.play();
           break;
         case CaptureTheFlagFlagStatus.At_Base:
           gamestream.audio.voiceYourFlagIsAtYourBase.play();
           break;
         case CaptureTheFlagFlagStatus.Dropped:
           gamestream.audio.voiceYourFlagHasBeenDropped.play();
           break;
       }
       return;
    }

    assert (playerIsTeamRed);

    switch (flagStatus) {
      case CaptureTheFlagFlagStatus.Carried_By_Allie:
        gamestream.audio.voiceTheEnemyHasTheirFlag.play();
        break;
      case CaptureTheFlagFlagStatus.Carried_By_Enemy:
        gamestream.audio.voiceAnAllyHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        gamestream.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        gamestream.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    
    final player = isometric.player;

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
                    WatchBuilder(isometric.player.team, (team) => text("TEAM: $team")),
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
                  WatchBuilder(flagRedStatus, (status) => text("RED STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
                  WatchBuilder(flagBlueStatus, (status) => text("BLUE STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
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

  Widget buildMiniMap({required double mapSize}) => IgnorePointer(
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
              child:   watch(isometric.clientState.sceneChanged, (_){
            return engine.buildCanvas(paint: (Canvas canvas, Size size){
              const scale = 2.0;
              canvas.scale(scale, scale);
              final screenCenterX = size.width * 0.5;
              final screenCenterY = size.height * 0.5;
              const ratio = 2 / 48.0;

              final chaseTarget = isometric.camera.chaseTarget;
              if (chaseTarget != null){
                final targetX = chaseTarget.renderX * ratio;
                final targetY = chaseTarget.renderY * ratio;
                final translate = mapSize / 4;
                final cameraX = targetX - (screenCenterX / scale) - translate;
                final cameraY = targetY - (screenCenterY / scale) - translate;
                canvas.translate(-cameraX, -cameraY);
              }

              isometric.minimap.renderCanvas(canvas);

              final serverState = isometric.serverState;
              final player = isometric.player;
              final totalCharacters = serverState.totalCharacters;

              for (var i = 0; i < totalCharacters; i++) {
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

              engine.renderExternalCanvas(
                  canvas: canvas,
                  image: GameImages.atlas_gameobjects,
                  srcX: AtlasItems.getSrcX(ItemType.GameObjects_Flag_Red),
                  srcY: AtlasItems.getSrcY(ItemType.GameObjects_Flag_Red),
                  srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Flag_Red),
                  srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Flag_Red),
                  dstX: flagPositionRed.renderX * ratio,
                  dstY: flagPositionRed.renderY * ratio,
                  scale: 0.1
              );

              engine.renderExternalCanvas(
                  canvas: canvas,
                  image: GameImages.atlas_gameobjects,
                  srcX: AtlasItems.getSrcX(ItemType.GameObjects_Flag_Blue),
                  srcY: AtlasItems.getSrcY(ItemType.GameObjects_Flag_Blue),
                  srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Flag_Blue),
                  srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Flag_Blue),
                  dstX: flagPositionBlue.renderX * ratio,
                  dstY: flagPositionBlue.renderY * ratio,
                  scale: 0.1
              );

              engine.renderExternalCanvas(
                  canvas: canvas,
                  image: GameImages.atlas_gameobjects,
                  srcX: AtlasItems.getSrcX(ItemType.GameObjects_Base_Red),
                  srcY: AtlasItems.getSrcY(ItemType.GameObjects_Base_Red),
                  srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Base_Red),
                  srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Base_Red),
                  dstX: basePositionRed.renderX * ratio,
                  dstY: basePositionRed.renderY * ratio,
                  scale: 0.05
              );

              engine.renderExternalCanvas(
                  canvas: canvas,
                  image: GameImages.atlas_gameobjects,
                  srcX: AtlasItems.getSrcX(ItemType.GameObjects_Base_Blue),
                  srcY: AtlasItems.getSrcY(ItemType.GameObjects_Base_Blue),
                  srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Base_Blue),
                  srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Base_Blue),
                  dstX: basePositionBlue.renderX * ratio,
                  dstY: basePositionBlue.renderY * ratio,
                  scale: 0.05
              );


            });
          })
        ),
        ),
      ),
    );

  void onRedTeamScore(){
    if (playerIsTeamRed){
      gamestream.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      gamestream.audio.voiceTheEnemyHasScored.play();
    }
  }

  void onBlueTeamScore() {
    if (playerIsTeamBlue){
      gamestream.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      gamestream.audio.voiceTheEnemyHasScored.play();
    }
  }
}