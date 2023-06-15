import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_nodes.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';

extension CaptureTheFlagRender on CaptureTheFlagGame {


  void renderCaptureTheFlag() {
    engine.paint.color = Colors.orange;

    if (debugMode.value){
      renderDebugMode(gamestream.isometric.nodes);
    }
    if (objectiveLinesEnabled){
      renderObjectiveLines();
    }
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
}