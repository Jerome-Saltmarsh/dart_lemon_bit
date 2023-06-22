
import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

class CombatGame extends IsometricGame {
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