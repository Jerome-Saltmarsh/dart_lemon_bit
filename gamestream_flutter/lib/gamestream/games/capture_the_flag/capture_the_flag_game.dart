


import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

class CaptureTheFlagGame extends GameIsometric {

  var objectiveLinesEnabled = false;
  var characterTargetTotal = 0;

  final Gamestream gamestream;
  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);
  final flagPositionRed = IsometricPosition();
  final flagPositionBlue = IsometricPosition();
  final basePositionRed = IsometricPosition();
  final basePositionBlue = IsometricPosition();
  final playerFlagStatus = Watch(CaptureTheFlagPlayerStatus.No_Flag);
  final selectClass = Watch(false);
  final gameStatus = Watch(CaptureTheFlagGameStatus.In_Progress);
  final nextGameCountDown = Watch(0);
  final characterPaths = <Uint16List>[];
  final characterTargets = Float32List(2000);
  final debugMode = Watch(false);
  final characterSelected = Watch(false);

  late final flagRedStatus = Watch(CaptureTheFlagFlagStatus.At_Base, onChanged: onChangedFlagRedStatus);
  late final flagBlueStatus = Watch(CaptureTheFlagFlagStatus.At_Base, onChanged: onChangedFlagBlueStatus);

  CaptureTheFlagGame({required this.gamestream}) : super(isometric: gamestream.isometric);

  bool get playerIsTeamRed => player.team.value == CaptureTheFlagTeam.Red;
  bool get playerIsTeamBlue => player.team.value == CaptureTheFlagTeam.Blue;

  final characterSelectedPosition = IsometricPosition();

  void onChangedFlagRedStatus(int flagStatus) {
    if (playerIsTeamRed) {
       switch (flagStatus) {
         case CaptureTheFlagFlagStatus.Carried_By_Allie:
           gamestream.audio.voiceYourTeamHasYourFlag.play();
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
        gamestream.audio.voiceYourTeamHasTheEnemyFlag.play();
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
           gamestream.audio.voiceYourTeamHasYourFlag.play();
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
        gamestream.audio.voiceYourTeamHasTheEnemyFlag.play();
        break;
      case CaptureTheFlagFlagStatus.At_Base:
        gamestream.audio.voiceTheEnemyFlagIsAtTheirBase.play();
        break;
      case CaptureTheFlagFlagStatus.Dropped:
        gamestream.audio.voiceTheEnemyFlagHasBeenDropped.play();
        break;
    }
  }

  void renderLineToEnemyFlag(){
    if (playerIsTeamRed) {
      renderLineToBlueFlag();
    } else {
      renderLineToRedFlag();
    }
  }

  void renderLineToOwnFlag(){
    if (playerIsTeamRed) {
      renderLineToRedFlag();
    } else {
      renderLineToBlueFlag();
    }
  }

  void renderLineToOwnBase(){
    if (playerIsTeamRed) {
      renderLineToRedBase();
    } else {
      renderLineToBlueBase();
    }
  }

  bool get teamFlagIsAtBase => flagStatusAlly == CaptureTheFlagFlagStatus.At_Base;

  int get flagStatusAlly => playerIsTeamRed ? flagRedStatus.value : flagBlueStatus.value;
  int get flagStatusEnemy => playerIsTeamRed ? flagBlueStatus.value : flagRedStatus.value;

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);

    engine.paint.color = Colors.orange;

    if (debugMode.value){
      renderDebugMode(gamestream.isometric.nodes);
    }
    if (objectiveLinesEnabled){
      renderObjectiveLines();
    }
  }

  void renderObjectiveLines() {
    switch (playerFlagStatus.value){
      case CaptureTheFlagPlayerStatus.No_Flag:
        renderLineToEnemyFlag();
        if (!teamFlagIsAtBase) {
          renderLineToOwnFlag();
        }
        break;
      case CaptureTheFlagPlayerStatus.Holding_Team_Flag:
        renderLineToOwnBase();
        break;
      case CaptureTheFlagPlayerStatus.Holding_Enemy_Flag:
        renderLineToOwnBase();
        break;
    }
  }

  void renderDebugMode(IsometricNodes nodes) {
    renderCharacterPaths(nodes);
    renderCharacterTargets();
  }

  void renderCharacterPaths(IsometricNodes nodes) {
    for (final path in characterPaths) {
      for (var i = 0; i < path.length - 1; i++){
        final a = path[i];
        final b = path[i + 1];
        engine.drawLine(
            nodes.getIndexRenderX(a),
            nodes.getIndexRenderY(a),
            nodes.getIndexRenderX(b),
            nodes.getIndexRenderY(b),
        );
      }
    }
  }

  void renderCharacterTargets() {
    engine.setPaintColor(Colors.green);
    for (var i = 0; i < characterTargetTotal; i++) {
      final j = i * 6;
      gamestream.isometric.renderer.renderLine(
          characterTargets[j + 0],
          characterTargets[j + 1],
          characterTargets[j + 2],
          characterTargets[j + 3],
          characterTargets[j + 4],
          characterTargets[j + 5],
      );
    }
  }


  void renderLineToRedBase() {
    engine.paint.color = Colors.red;
    engine.drawLine(player.renderX, player.renderY, basePositionRed.renderX, basePositionRed.renderY);
  }

  void renderLineToBlueBase() {
    engine.paint.color = Colors.blue;
    engine.drawLine(player.renderX, player.renderY, basePositionBlue.renderX, basePositionBlue.renderY);
  }

  void renderLineToRedFlag() {
    if (flagRedStatus.value == CaptureTheFlagFlagStatus.Respawning) return;
    engine.paint.color = Colors.red;
    engine.drawLine(player.renderX, player.renderY, flagPositionRed.renderX, flagPositionRed.renderY);
  }

  void renderLineToBlueFlag() {
    if (flagBlueStatus.value == CaptureTheFlagFlagStatus.Respawning) return;
    engine.paint.color = Colors.blue;
    engine.drawLine(player.renderX, player.renderY, flagPositionBlue.renderX, flagPositionBlue.renderY);
  }

  @override
  Widget customBuildUI(BuildContext context) => Stack(
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
            child: buildWindowFlagStatus()),
        Positioned(
          top: 16,
          right: 16,
          child: buildWindowMenu(),
        ),
      ],
    );

  Widget buildWindowMap() => buildMiniMap(mapSize: 200);

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

  void onRedTeamScore(){
    print("onRedTeamScore()");
    if (playerIsTeamRed){
      gamestream.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      gamestream.audio.voiceTheEnemyHasScored.play();
    }
  }

  void onBlueTeamScore() {
    print("onBlueTeamScore()");
    if (playerIsTeamBlue){
      gamestream.audio.voiceYourTeamHasScoredAPoint.play();
    } else {
      gamestream.audio.voiceTheEnemyHasScored.play();
    }
  }

  void selectCharacterClass(CaptureTheFlagCharacterClass value) =>
      gamestream.network.sendClientRequest(
        ClientRequest.Capture_The_Flag,
        '${CaptureTheFlagRequest.selectClass.index} ${value.index}'
      );

  void toggleDebugMode() => sendCaptureTheFlagRequest(
      CaptureTheFlagRequest.toggleDebug
    );

  void sendCaptureTheFlagRequest(CaptureTheFlagRequest value, [dynamic message]){
    gamestream.network.sendClientRequest(
        ClientRequest.Capture_The_Flag,
        '${value.index} $message'
    );
  }
}