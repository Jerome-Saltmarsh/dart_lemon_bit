


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_actions.dart';
import 'capture_the_flag_power.dart';
import 'capture_the_flag_render.dart';
import 'capture_the_flag_ui.dart';
import 'capture_the_flag_events.dart';

class CaptureTheFlagGame extends IsometricGame {

  var objectiveLinesEnabled = false;
  var characterTargetTotal = 0;
  var playerActivatedTargetSet = false;

  final Gamestream gamestream;
  final tab = Watch(CaptureTheFlagUITabs.Selected_Character);
  final flagPositionRed = IsometricPosition();
  final flagPositionBlue = IsometricPosition();
  final basePositionRed = IsometricPosition();
  final basePositionBlue = IsometricPosition();
  final playerFlagStatus = Watch(CaptureTheFlagPlayerStatus.No_Flag);
  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);
  final selectClass = Watch(false);
  final gameStatus = Watch(CaptureTheFlagGameStatus.In_Progress);
  final nextGameCountDown = Watch(0);

  final playerActivatedPowerType = Watch<CaptureTheFlagPowerType?>(null);
  final playerActivatedPowerRange = Watch(0.0);
  final playerActivatedPowerX = Watch(0.0);
  final playerActivatedPowerY = Watch(0.0);
  final playerActivatedTarget = IsometricPosition();
  final playerPower1 = CaptureTheFlagPower();
  final playerPower2 = CaptureTheFlagPower();
  final playerPower3 = CaptureTheFlagPower();
  final playerLevel = Watch(0);
  final playerExperience = Watch(0);
  final playerExperienceRequiredForNextLevel = Watch(0);
  final skillPoints = Watch(0);

  late final audioOnLevelGain = gamestream.audio.collect_star_3;

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
      case KeyCode.Digit_3:
        activatePower3();
        break;
    }
  }

  void activatePower1() =>
      sendCaptureTheFlagRequest(CaptureTheFlagRequest.Activate_Power_1);

  void activatePower2() =>
      sendCaptureTheFlagRequest(CaptureTheFlagRequest.Activate_Power_2);

  void activatePower3() =>
      sendCaptureTheFlagRequest(CaptureTheFlagRequest.Activate_Power_3);

}