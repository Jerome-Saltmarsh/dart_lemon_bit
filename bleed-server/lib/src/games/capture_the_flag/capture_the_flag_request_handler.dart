

import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_character_class.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_request.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_ai.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/utilities/is_valid_index.dart';
import 'package:bleed_server/src/websocket/websocket_connection.dart';

extension CaptureTheFlagRequestHandler on WebSocketConnection {

  void handleClientRequestCaptureTheFlag(List<String> arguments){
    final player = this.player;
    if (player is! CaptureTheFlagPlayer) {
      errorInvalidPlayerType();
      return;
    }
    final captureTheFlagRequestIndex = parseArg1(arguments);
    if (captureTheFlagRequestIndex == null) return;
    if (!isValidIndex(captureTheFlagRequestIndex, CaptureTheFlagRequest.values)){
      errorInvalidClientRequest();
      return;
    }
    final captureTheFlagClientRequest = CaptureTheFlagRequest.values[captureTheFlagRequestIndex];

    switch (captureTheFlagClientRequest){
      case CaptureTheFlagRequest.selectClass:
        final characterClassIndex = parseArg2(arguments);
        if (characterClassIndex == null) return;
        if (!isValidIndex(characterClassIndex, CaptureTheFlagCharacterClass.values)){
          return errorInvalidClientRequest();
        }
        final characterClass = CaptureTheFlagCharacterClass.values[characterClassIndex];
        player.game.playerSelectCharacterClass(player, characterClass);
        break;

      case CaptureTheFlagRequest.toggleSelectedAIRole:
        final selectedCharacter = player.selectedCharacter;
        if (selectedCharacter is! CaptureTheFlagAI){
          return errorInvalidClientRequest();
        }
        selectedCharacter.toggleRole();
        break;
      case CaptureTheFlagRequest.Activate_Power_1:
        player.activatePower1();
        break;
    }
  }
}