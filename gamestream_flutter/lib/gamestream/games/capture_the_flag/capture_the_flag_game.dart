


import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game_ui.dart';
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

  final characterSelectedX = Watch(0.0);
  final characterSelectedY = Watch(0.0);
  final characterSelectedZ = Watch(0.0);

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
  Widget customBuildUI(BuildContext context) => buildCaptureTheFlagGameUI();

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