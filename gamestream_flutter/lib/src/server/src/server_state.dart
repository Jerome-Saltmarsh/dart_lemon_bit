import 'package:gamestream_flutter/library.dart';

/// the data inside server state belongs to the server and can only be read
/// writing to server state is forbidden
class ServerState {
  static final areaType = Watch(AreaType.None, onChanged: ServerEvents.onChangedAreaType);
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
  static final rain = Watch(RainType.None, onChanged: GameEvents.onChangedRain);
  static final weatherBreeze = Watch(false);
  static final hours = Watch(0, onChanged: GameEvents.onChangedHour);
  static final minutes = Watch(0);
  static final gameType = Watch<int?>(null, onChanged: ServerEvents.onChangedGameType);
  static final lightning = Watch(LightningType.Off, onChanged: ServerEvents.onChangedLightning);
  static final watchTimePassing = Watch(false);
  static final windTypeAmbient = Watch(WindType.Calm, onChanged: GameEvents.onChangedWindType);
  static final ambientShade = Watch(Shade.Bright, onChanged: GameEvents.onChangedAmbientShade);
  static final error = Watch("invalid request", onChanged: GameEvents.onChangedError);

  static final playerBelt1_ItemType = Watch(ItemType.Empty);
  static final playerBelt2_ItemType = Watch(ItemType.Empty);
  static final playerBelt3_ItemType = Watch(ItemType.Empty);
  static final playerBelt4_ItemType = Watch(ItemType.Empty);
  static final playerBelt5_ItemType = Watch(ItemType.Empty);
  static final playerBelt6_ItemType = Watch(ItemType.Empty);

  static final playerBelt1_Quantity = Watch(0);
  static final playerBelt2_Quantity = Watch(0);
  static final playerBelt3_Quantity = Watch(0);
  static final playerBelt4_Quantity = Watch(0);
  static final playerBelt5_Quantity = Watch(0);
  static final playerBelt6_Quantity = Watch(0);

  static final equippedWeaponIndex = Watch(0);

  static final watchBeltItemTypes = [
    playerBelt1_ItemType,
    playerBelt2_ItemType,
    playerBelt3_ItemType,
    playerBelt4_ItemType,
    playerBelt5_ItemType,
    playerBelt6_ItemType,
  ];

  // VARIABLES
  static var inventory = Uint16List(0);
  static var inventoryQuantity = Uint16List(0);
}


