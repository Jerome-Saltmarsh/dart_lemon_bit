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
      render.circleOutline(
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
          engine.setPaintColor(Colors.red);
          render.circleOutlineAtPosition(
            position: playerActivatedTarget,
            radius: 40,
          );
        }
        break;
      case PowerMode.Targeted_Ally:
        if (playerActivatedTargetSet) {
          engine.setPaintColor(Colors.green);
          render.circleOutlineAtPosition(
            position: playerActivatedTarget,
            radius: 40,
          );
        }
        break;
      case PowerMode.Positional:
        render.circleOutline(
          playerActivatedPowerX.value,
          playerActivatedPowerY.value,
          player.z,
          40,
        );
        break;
    }
  }
}

