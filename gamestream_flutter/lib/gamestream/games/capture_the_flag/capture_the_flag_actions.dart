

import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_game.dart';

extension CaptureTheFlagActions on CaptureTheFlagGame {


  void selectCharacterClass(CaptureTheFlagCharacterClass value) =>
      gamestream.network.sendClientRequest(
          ClientRequest.Capture_The_Flag,
          '${CaptureTheFlagRequest.selectClass.index} ${value.index}'
      );

  void toggleSelectedCharacterAIRole() =>
      gamestream.network.sendClientRequest(
          ClientRequest.Capture_The_Flag,
          CaptureTheFlagRequest.toggleSelectedAIRole.index
      );

  void sendCaptureTheFlagRequest(CaptureTheFlagRequest value, [dynamic message]){
    gamestream.network.sendClientRequest(
        ClientRequest.Capture_The_Flag,
        '${value.index} $message'
    );
  }
}