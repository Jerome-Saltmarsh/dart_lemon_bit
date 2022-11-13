import 'package:gamestream_flutter/library.dart';

/// the data inside server state belongs to the server and can only be read
/// writing to server state is forbidden
class ServerState {
  static final interactMode = Watch(InteractMode.None, onChanged: GameEvents.onChangedPlayerInteractMode);
  static final playerHealth = Watch(0);
  static final playerEquippedWeaponAmmunitionType = Watch(0);
  static final playerEquippedWeaponAmmunitionQuantity = Watch(0);
  static final playerMaxHealth = Watch(0);
  static final playerGold = Watch(0);
  static final playerExperiencePercentage = Watch(0.0);
  static final playerLevel = Watch(1);
  static final playerAttributes = Watch(0);
  static final sceneEditable = Watch(false);
  static final sceneName = Watch<String?>(null);
  static final rain = Watch(Rain.None, onChanged: GameEvents.onChangedRain);
  static final weatherBreeze = Watch(false);

  static var inventory = Uint16List(0);
  static var inventoryQuantity = Uint16List(0);

  static final lightning = Watch(Lightning.Off, onChanged: (Lightning value){
    if (value != Lightning.Off){
      ClientState.nextLightning = 0;
    }
  });

  static final watchTimePassing = Watch(false);
  static final windAmbient = Watch(Wind.Calm, onChanged: GameEvents.onChangedWind);
  static final ambientShade = Watch(Shade.Bright, onChanged: GameEvents.onChangedAmbientShade);
}


