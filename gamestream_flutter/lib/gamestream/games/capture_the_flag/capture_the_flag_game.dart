


import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_actions.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_power.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_render.dart';
import 'capture_the_flag_ui.dart';
import 'capture_the_flag_events.dart';

class CaptureTheFlagGame extends GameIsometric {

  var objectiveLinesEnabled = false;
  var characterTargetTotal = 0;
  var playerActivatedTargetSet = false;

  final Gamestream gamestream;
  final tab = Watch(CaptureTheFlagUITabs.Selected_Character);
  final flagPositionRed = IsometricPosition();
  final flagPositionBlue = IsometricPosition();
  final basePositionRed = IsometricPosition();
  final basePositionBlue = IsometricPosition();
  final characterPaths = <Uint16List>[];
  final characterTargets = Float32List(1000);
  final playerFlagStatus = Watch(CaptureTheFlagPlayerStatus.No_Flag);
  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);
  final debugMode = WatchBool(true);
  final selectClass = Watch(false);
  final gameStatus = Watch(CaptureTheFlagGameStatus.In_Progress);
  final nextGameCountDown = Watch(0);
  final characterSelected = Watch(false);
  final characterSelectedIsAI = Watch(false);
  final characterSelectedAIDecision = Watch(CaptureTheFlagAIDecision.Idle);
  final characterSelectedAIRole = Watch(CaptureTheFlagAIRole.Defense);
  final characterSelectedX = Watch(0.0);
  final characterSelectedY = Watch(0.0);
  final characterSelectedZ = Watch(0.0);
  final characterSelectedRuntimeType = Watch("");
  final characterSelectedPath = Uint16List(500);
  final characterSelectedPathIndex = Watch(0);
  final characterSelectedPathEnd = Watch(0);
  final characterSelectedPathRender = WatchBool(true);
  final characterSelectedTarget = Watch(false);
  final characterSelectedTargetType = Watch("");
  final characterSelectedTargetX = Watch(0.0);
  final characterSelectedTargetY = Watch(0.0);
  final characterSelectedTargetZ = Watch(0.0);
  final characterSelectedTargetRenderLine = WatchBool(true);

  final playerActivatedPowerType = Watch<CaptureTheFlagPowerType?>(null);
  final playerActivatedPowerRange = Watch(0.0);
  final playerActivatedPowerX = Watch(0.0);
  final playerActivatedPowerY = Watch(0.0);
  final playerActivatedTarget = IsometricPosition();
  final playerPower1 = CaptureTheFlagPower();
  final playerPower2 = CaptureTheFlagPower();

  late final flagRedStatus = Watch(CaptureTheFlagFlagStatus.At_Base, onChanged: onChangedFlagRedStatus);
  late final flagBlueStatus = Watch(CaptureTheFlagFlagStatus.At_Base, onChanged: onChangedFlagBlueStatus);

  CaptureTheFlagGame({required this.gamestream}) : super(isometric: gamestream.isometric);

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    renderCaptureTheFlag();
  }

  @override
  Widget customBuildUI(BuildContext context) => buildCaptureTheFlagGameUI();

  @override
  void onKeyPressed(int key) {
    super.onKeyPressed(key);

    switch (key){
      case KeyCode.Digit_1:
        activatePower1();
        break;
      case KeyCode.Digit_2:
        activatePower2();
        break;
    }
  }

  void activatePower1() =>
      sendCaptureTheFlagRequest(CaptureTheFlagRequest.Activate_Power_1);

  void activatePower2() =>
      sendCaptureTheFlagRequest(CaptureTheFlagRequest.Activate_Power_2);

}