
import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

class CombatGame extends GameIsometric {
  CombatGame({required super.isometric});

  void sendClientRequestSelectWeaponPrimary(int value) =>
      sendCombatRequest(CombatRequest.Select_Weapon_Primary, value);

  void sendClientRequestSelectWeaponSecondary(int value) =>
      sendCombatRequest(CombatRequest.Select_Weapon_Secondary, value);

  void sendClientRequestSelectPower(int value) =>
      sendCombatRequest(CombatRequest.Select_Power, value);

  void sendCombatRequest(CombatRequest combatRequest, [dynamic message]) =>
      gamestream.network.sendClientRequest(ClientRequest.Combat, message);
}