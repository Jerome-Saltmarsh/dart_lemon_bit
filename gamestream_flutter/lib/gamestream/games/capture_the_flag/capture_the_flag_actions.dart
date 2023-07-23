

import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_power.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';

extension CaptureTheFlagActions on CaptureTheFlagGame {


  void selectCharacterClass(CaptureTheFlagCharacterClass value) =>
      gamestream.sendClientRequest(
          ClientRequest.Capture_The_Flag,
          '${CaptureTheFlagRequest.selectClass.index} ${value.index}'
      );

  void toggleSelectedCharacterAIRole() =>
      gamestream.sendClientRequest(
          ClientRequest.Capture_The_Flag,
          CaptureTheFlagRequest.toggleSelectedAIRole.index
      );

  void debugSelectAI() => sendCaptureTheFlagRequest(
    CaptureTheFlagRequest.Debug_Selected_Character_AI
  );

  void upgradePower(CaptureTheFlagPower power) =>
      gamestream.sendClientRequest(
          ClientRequest.Capture_The_Flag,
          '${CaptureTheFlagRequest.Upgrade_Power.index} ${power.type.value.index}'
      );

  void sendCaptureTheFlagRequest(CaptureTheFlagRequest value, [dynamic message]){
    gamestream.sendClientRequest(
        ClientRequest.Capture_The_Flag,
        '${value.index} $message'
    );
  }
}