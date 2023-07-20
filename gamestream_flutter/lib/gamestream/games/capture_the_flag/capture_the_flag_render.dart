import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';
import 'capture_the_flag_properties.dart';

extension CaptureTheFlagRender on CaptureTheFlagGame {

  void renderCaptureTheFlag() {
    gamestream.engine.paint.color = Colors.orange;

    if (objectiveLinesEnabled){
      renderObjectiveLines();
    }

    renderPlayerActivatedPower();
  }

  void renderLineToRedFlag() {
    if (flagRedStatus.value == CaptureTheFlagFlagStatus.Respawning) return;
    gamestream.engine.paint.color = Colors.red;
    gamestream.engine.drawLine(player.renderX, player.renderY, flagPositionRed.renderX, flagPositionRed.renderY);
  }

  void renderLineToBlueFlag() {
    if (flagBlueStatus.value == CaptureTheFlagFlagStatus.Respawning) return;
    gamestream.engine.paint.color = Colors.blue;
    gamestream.engine.drawLine(player.renderX, player.renderY, flagPositionBlue.renderX, flagPositionBlue.renderY);
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
    gamestream.engine.paint.color = Colors.red;
    gamestream.engine.drawLine(player.renderX, player.renderY, basePositionRed.renderX, basePositionRed.renderY);
  }

  void renderLineToBlueBase() {
    gamestream.engine.paint.color = Colors.blue;
    gamestream.engine.drawLine(player.renderX, player.renderY, basePositionBlue.renderX, basePositionBlue.renderY);
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
      case PowerMode.Equip:
        break;
      case PowerMode.Self:
        break;
      case PowerMode.Targeted_Enemy:
        if (playerActivatedTargetSet) {
          gamestream.engine.setPaintColor(Colors.red);
          isometric.renderer.renderCircleAtPosition(
            position: playerActivatedTarget,
            radius: 40,
          );
        }
        break;
      case PowerMode.Targeted_Ally:
        if (playerActivatedTargetSet) {
          gamestream.engine.setPaintColor(Colors.green);
          isometric.renderer.renderCircleAtPosition(
            position: playerActivatedTarget,
            radius: 40,
          );
        }
        break;
      case PowerMode.Positional:
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

