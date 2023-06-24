

import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/utils/is_valid_index.dart';
import 'package:bleed_server/websocket/websocket_connection.dart';

import 'capture_the_flag_ai.dart';
import 'capture_the_flag_player.dart';

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
        final selectedCharacter = player.debugCharacter;
        if (selectedCharacter is! CaptureTheFlagAI){
          return errorInvalidClientRequest();
        }
        selectedCharacter.toggleRole();
        break;
      case CaptureTheFlagRequest.Activate_Power_1:
        player.activatePower1();
        break;
      case CaptureTheFlagRequest.Activate_Power_2:
        player.activatePower2();
        break;
      case CaptureTheFlagRequest.Activate_Power_3:
        player.activatePower3();
        break;
      case CaptureTheFlagRequest.Upgrade_Power:
        final powerTypeIndex = parseArg2(arguments);
        if (powerTypeIndex == null) return;
        if (!isValidIndex(powerTypeIndex, CombatPowerType.values)){
          errorInvalidClientRequest();
          return;
        }
        final powerType = CaptureTheFlagPowerType.values[powerTypeIndex];
        player.upgradePowerType(powerType);
        break;
      case CaptureTheFlagRequest.Debug_Selected_Character_AI:
        final selected = player.debugCharacter;
        if (selected is! CaptureTheFlagAI) break;
        selected.customOnUpdate();
        break;
    }
  }
}