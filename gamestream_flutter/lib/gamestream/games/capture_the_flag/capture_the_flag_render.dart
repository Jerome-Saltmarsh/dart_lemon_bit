import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_properties.dart';

extension CaptureTheFlagRender on CaptureTheFlagGame {

  void renderCaptureTheFlag() {
    engine.paint.color = Colors.orange;

    if (objectiveLinesEnabled){
      renderObjectiveLines();
    }

    renderPlayerActivatedPower();
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

  void renderLineToRedBase() {
    engine.paint.color = Colors.red;
    engine.drawLine(player.renderX, player.renderY, basePositionRed.renderX, basePositionRed.renderY);
  }

  void renderLineToBlueBase() {
    engine.paint.color = Colors.blue;
    engine.drawLine(player.renderX, player.renderY, basePositionBlue.renderX, basePositionBlue.renderY);
  }

  void renderPlayerActivatedPower() {
    final activatedPowerType = playerActivatedPowerType.value;

    if (activatedPowerType == null) return;

    if (playerActivatedPowerRange.value > 0) {
      isometric.renderer.renderCircle(
        player.x,
        player.y,
        player.z,
        playerActivatedPowerRange.value,
        sections: 24,
      );
    }

    switch (activatedPowerType.mode) {
      case CaptureTheFlagPowerMode.Self:
        break;
      case CaptureTheFlagPowerMode.Targeted_Enemy:
        if (playerActivatedTargetSet) {
          engine.setPaintColor(Colors.red);
          isometric.renderer.renderCircleAtIsometricPosition(
            position: playerActivatedTarget,
            radius: 40,
          );
        }
        break;
      case CaptureTheFlagPowerMode.Targeted_Ally:
        if (playerActivatedTargetSet) {
          engine.setPaintColor(Colors.green);
          isometric.renderer.renderCircleAtIsometricPosition(
            position: playerActivatedTarget,
            radius: 40,
          );
        }
        break;
      case CaptureTheFlagPowerMode.Positional:
        isometric.renderer.renderCircle(
          playerActivatedPowerX.value,
          playerActivatedPowerY.value,
          player.z,
          40,
        );
        break;
    }
  }
}

