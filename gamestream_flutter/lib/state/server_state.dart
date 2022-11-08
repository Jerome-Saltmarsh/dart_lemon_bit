import 'package:gamestream_flutter/library.dart';

class ServerState {
  static final interactMode = Watch(InteractMode.None, onChanged: GameEvents.onChangedPlayerInteractMode);
  static final playerHealth = Watch(0);
  static final playerEquippedWeaponAmmunitionType = Watch(0);
  static final playerEquippedWeaponAmmunitionQuantity = Watch(0);
  static var playerMaxHealth = 0;
}


