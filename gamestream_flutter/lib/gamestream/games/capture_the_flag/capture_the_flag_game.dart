


import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_render.dart';
import 'capture_the_flag_ui.dart';

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


  @override
  Widget customBuildUI(BuildContext context) => buildCaptureTheFlagGameUI();

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