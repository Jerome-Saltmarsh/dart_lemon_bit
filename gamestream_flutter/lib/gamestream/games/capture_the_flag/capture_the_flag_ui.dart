
import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/library.dart';

extension CaptureTheFlagUI on CaptureTheFlagGame {

  Widget buildCaptureTheFlagGameUI(){
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: buildWindowGameStatus(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: buildWindowMap(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: buildWindowSelectClass(),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: buildWindowScore(),
        ),
        Positioned(
            bottom: 16,
            left: 16,
            child: buildWindowSelectedCharacter()),
        Positioned(
          top: 16,
          right: 16,
          child: buildWindowMenu(),
        ),
      ],
    );
  }

  WatchBuilder<CaptureTheFlagGameStatus> buildWindowGameStatus() {
    return WatchBuilder(gameStatus, (value){
      if (value == CaptureTheFlagGameStatus.In_Progress) return nothing;
      return buildFullscreen(
        child: Container(
          width: 300,
          height: 200,
          color: GameStyle.Container_Color,
          padding: GameStyle.Container_Padding,
          alignment: Alignment.center,
          child: Column(
            children: [
              text(value.name),
              WatchBuilder(nextGameCountDown, (nextGameCountDown) =>
                  text("NEXT GAME STARTS IN $nextGameCountDown")),
            ],
          ),
        ),
      );
    });
  }



  Widget buildWindowMap() => buildMiniMap(mapSize: 200);

  Widget buildWindowMenu() {
    return GameIsometricUI.buildRowMainMenu(children: [
      GameIsometricUI.buildWindowMenuItem(
        title: "DEBUG",
        child: watch(debugMode, GameIsometricUI.buildIconCheckbox),
      )
    ]);
  }

  Container buildWindowFlagStatus() {
    return Container(
      padding: GameStyle.Container_Padding,
      color: GameStyle.Container_Color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          onPressed(
            action: toggleDebugMode,
            child: GameIsometricUI.buildWindowMenuItem(
              title: "DEBUG",
              child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: watch(debugMode, GameIsometricUI.buildIconCheckbox)),
            ),
          ),
          text("FLAG STATUS"),
          WatchBuilder(flagRedStatus, (status) => text("RED STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
          WatchBuilder(flagBlueStatus, (status) => text("BLUE STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
        ],
      ),
    );
  }

  Container buildWindowScore() {
    return Container(
      padding: GameStyle.Container_Padding,
      color: GameStyle.Container_Color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WatchBuilder(debugMode, (playerFlagStatus) => text("Debug Mode: ${CaptureTheFlagPlayerStatus.getName(playerFlagStatus)}")),
          WatchBuilder(playerFlagStatus, (playerFlagStatus) => text("Player Flag Status: ${CaptureTheFlagPlayerStatus.getName(playerFlagStatus)}")),
          WatchBuilder(isometric.player.team, (team) => text("TEAM: $team")),
          text("SCORE"),
          WatchBuilder(scoreRed, (score) => text("RED: $score")),
          WatchBuilder(scoreBlue, (score) => text("BlUE: $score")),
        ],
      ),
    );
  }

  WatchBuilder<bool> buildWindowSelectClass() {
    return WatchBuilder(selectClass, (value){
      if (!value) return const SizedBox();
      return buildFullscreen(
        child: Container(
          color: GameStyle.Container_Color,
          padding: GameStyle.Container_Padding,
          width: 300,
          height: 400,
          child: Column(
            children: CaptureTheFlagCharacterClass.values
                .map((characterClass) => onPressed(
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: text(characterClass.name, size: 20)),
                action: () => selectCharacterClass(characterClass)))
                .toList(growable: false),
          ),
        ),
      );
    });
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

                final serverState = isometric.server;
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

                if (flagRedStatus.value != CaptureTheFlagFlagStatus.Respawning) {
                  engine.renderExternalCanvas(
                      canvas: canvas,
                      image: GameImages.atlas_gameobjects,
                      srcX: AtlasItems.getSrcX(ItemType.GameObjects_Flag_Red),
                      srcY: AtlasItems.getSrcY(ItemType.GameObjects_Flag_Red),
                      srcWidth: AtlasItems.getSrcWidth(
                          ItemType.GameObjects_Flag_Red),
                      srcHeight: AtlasItems.getSrcHeight(
                          ItemType.GameObjects_Flag_Red),
                      dstX: flagPositionRed.renderX * ratio,
                      dstY: flagPositionRed.renderY * ratio,
                      scale: 0.1
                  );
                }

                if (flagBlueStatus.value != CaptureTheFlagFlagStatus.Respawning) {
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
                }

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

  Widget buildWindowSelectedCharacter(){
    return WatchBuilder(characterSelected, (characterSelected){
      if (!characterSelected) return nothing;
      return Container(
        color: GameStyle.Container_Color,
        padding: GameStyle.Container_Padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WatchBuilder(characterSelectedX, (x) => text("x: ${x.toInt()}")),
            WatchBuilder(characterSelectedY, (y) => text("y: ${y.toInt()}")),
            WatchBuilder(characterSelectedZ, (z) => text("z: ${z.toInt()}")),
          ],
        ),
      );
    });
  }
}