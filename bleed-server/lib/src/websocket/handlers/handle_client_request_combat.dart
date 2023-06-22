

import 'package:bleed_server/common/src/combat/combat_request.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/isometric/item_type.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/games/combat/combat_player.dart';
import 'package:bleed_server/src/utilities/is_valid_index.dart';
import 'package:bleed_server/src/websocket/websocket_connection.dart';

extension HandleClientRequestCombat on WebSocketConnection {

  void handleClientRequestCombat(Player? player, List<String> arguments) {
    if (player is! CombatPlayer) {
      errorInvalidPlayerType();
      return;
    }

    final combatRequestIndex = parseArg2(arguments);

    if (combatRequestIndex == null)
      return;

    if (!isValidIndex(combatRequestIndex, CombatRequest.values)) {
      errorInvalidClientRequest();
      return;
    }

    final combatRequest = CombatRequest.values[combatRequestIndex];

    switch (combatRequest){
      case CombatRequest.Select_Power:
        break;
      case CombatRequest.Select_Weapon_Primary:
        final value = parseArg1(arguments);
        if (value == null) return;
        if (!ItemType.isTypeWeapon(value)) {
          player.writeGameError(GameError.Invalid_Weapon_Type);
          return;
        }
        player.weaponPrimary = value;
        player.weaponType = value;
        player.onWeaponTypeChanged();
        break;
      case CombatRequest.Select_Weapon_Secondary:
        final value = parseArg1(arguments);
        if (value == null) return;
        if (!ItemType.isTypeWeapon(value)) {
          player.writeGameError(GameError.Invalid_Weapon_Type);
          return;
        }
        player.weaponSecondary = value;
        player.weaponType = value;
        player.onWeaponTypeChanged();
        break;
    }
  }

}