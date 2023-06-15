


import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_render.dart';
import 'capture_the_flag_ui.dart';
import 'capture_the_flag_events.dart';

class CaptureTheFlagGame extends GameIsometric {

  var objectiveLinesEnabled = false;
  var characterTargetTotal = 0;


  final Gamestream gamestream;
  final flagPositionRed = IsometricPosition();
  final flagPositionBlue = IsometricPosition();
  final basePositionRed = IsometricPosition();
  final basePositionBlue = IsometricPosition();
  final characterPaths = <Uint16List>[];
  final characterTargets = Float32List(2000);
  final playerFlagStatus = Watch(CaptureTheFlagPlayerStatus.No_Flag);
  final scoreRed = Watch(0);
  final scoreBlue = Watch(0);
  final debugMode = Watch(false);
  final selectClass = Watch(false);
  final gameStatus = Watch(CaptureTheFlagGameStatus.In_Progress);
  final nextGameCountDown = Watch(0);
  final characterSelected = Watch(false);
  final characterSelectedX = Watch(0.0);
  final characterSelectedY = Watch(0.0);
  final characterSelectedZ = Watch(0.0);
  final characterSelectedPath = Uint16List(500);
  final characterSelectedPathIndex = Watch(0);
  final characterSelectedPathEnd = Watch(0);
  final characterSelectedPathRender = WatchBool(false);
  final characterSelectedTarget = Watch(false);
  final characterSelectedTargetType = Watch("");
  final characterSelectedTargetX = Watch(0.0);
  final characterSelectedTargetY = Watch(0.0);
  final characterSelectedTargetZ = Watch(0.0);
  final characterSelectedTargetRenderLine = WatchBool(false);

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
}