enum GameError {
  Invalid_Client_Request,
  Unable_To_Join_Game,
  Invalid_Player_Type,
  Invalid_Weapon_Type,
  Invalid_Power_Type,
  Power_Not_Ready,
  Upgrade_Power_Error,
  Insufficient_Skill_Points,
  Invalid_Inventory_Index,
  Invalid_Inventory_Request_Index,
  Respawn_Duration_Remaining,
  Insufficient_Energy,
  Insufficient_Ammunition,
  Insufficient_Resources,
  Insufficient_Gold,
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
  GameObject_Not_Found,
  Invalid_Item_Index,
  Invalid_Talk_Option,
  Invalid_Weapon_Index,
  Invalid_Treasure_Index,
  Treasures_Full,
  Talent_Already_Unlocked,
  Parent_Talent_Required_To_Unlock,
  Talent_Max_Level,
  Selected_Mark_Index_Not_Set,
  Invalid_Mark_Stack_Index,
  // Insufficient_Element_Points,
  // Insufficient_Elements,
  Weapon_Rack_Full,
  Insufficient_Weapon_Charges,
  No_Weapon_Equipped,
  Weapon_Required,
  Bow_Required,
  Sword_Required,
  Staff_Required,
  Melee_Weapon_Required,
  Insufficient_Magic,
  Invalid_Portal_Scene,
  No_Connecting_Portal,
  Potion_Slots_Full,
  Invalid_Skill_Slot_Index,
  Invalid_Skill_Type_Index,
  Skill_Type_Locked,
  Amulet_Item_Null,
  Amulet_Item_Required,
  GameObject_Cannot_Be_Acquired,
  Invalid_GameObject_State,
  Item_Not_Consumable,
  Invalid_Object_Level,
  Invalid_Object_Damage,
  Perform_Duration_Null,
  Character_Weapon_Range_Null,
  Level_Required,
  Invalid_Amulet_Item_Index,
  Invalid_Amulet_Item_Level,
  Max_Damage_Null,
  Min_Damage_Null,
  Slot_Type_Required,
  Invalid_Slot_Type_Index,
  Slot_Type_Empty,
  Not_Implemented,
  Cheats_Disabled,
  Potions_Health_Full,
  Potions_Magic_Full,
  Potions_Health_Empty,
  Potions_Magic_Empty,
  ;

  static GameError fromIndex(int index) {
    if (index < 0) throw Exception('$index < 0');
    if (index >= values.length) throw Exception('$index > gameErrors.length');
    return values[index];
  }
}
