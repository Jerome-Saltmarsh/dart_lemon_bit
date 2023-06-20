
enum GameError {
  Invalid_Client_Request,
  Unable_To_Join_Game,
  Invalid_Player_Type,
  Invalid_Weapon_Type,
  Invalid_Power_Type,
  Power_Not_Ready,
  Invalid_Inventory_Index,
  Invalid_Inventory_Request_Index,
  Respawn_Duration_Remaining,
  Insufficient_Energy,
  Insufficient_Ammunition,
  Insufficient_Resources,
  Insufficient_Credits,
  Already_Equipped,
  Target_Required,
  CharacterTypeAlreadySelected,
  Cannot_Purchase_At_The_Moment,
  Inventory_Equip_Failed_Belt_Full,
  Inventory_Equip_Failed_Inventory_Full,
  Invalid_Purchase_index,
  Cannot_Edit_Scene,
  GameNotFound,
  PlayerNotFound,
  ClientRequestRequired,
  UnrecognizedClientRequest,
  InvalidPlayerUUID,
  ClientRequestArgumentsEmpty,
  PlayerStillAlive,
  PlayerDead,
  PlayerBusy,
  InvalidArguments,
  InvalidWeaponIndex,
  LobbyNotFound,
  LobbyUserNotFound,
  GameFull,
  CannotRevive,
  CannotSpawnNpc,
  InvalidPurchaseType,
  IntegerExpected,
  InsufficientFunds,
  WeaponNotAcquired,
  WeaponAlreadyAcquired,
  InsufficientSkillPoints,
  InsufficientOrbs,
  Inventory_Full,
  InsufficientMana,
  Cooldown_Remaining,
  SkillLocked,
  SkillPointsRequired,
  Subscription_Required,
  Custom_Map_Not_Found,
  Login_Error,
  Account_Not_Found,
  Account_Required,
  Construct_Insufficient_Resources,
  Construct_Invalid_Tile,
  Construct_Area_Not_Available,
  Character_Select_Not_Required,
  Choose_Card,
  Save_Scene_Failed,
  Load_Scene_Failed,
}

GameError parseIndexToGameError(int index) {
  final values = GameError.values;
  if (index < 0) throw Exception('$index < 0');
  if (index >= values.length) throw Exception('$index > gameErrors.length');
return values[index];
}