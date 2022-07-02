enum ClientRequest {
  Update,
  Join,
  Attack,
  Attack_Secondary,
  Revive,
  Equip,
  Purchase,
  Toggle_Debug,
  Version,
  Speak,
  Skip_Hour,
  Reverse_Hour,
  Teleport,
  Upgrade,
  Scene_Save,
  Select_Character_Type,
  Deck_Add_Card,
  Deck_Select_Card,
  Set_Block,
  Spawn_Zombie,
  Set_Weapon,
  Set_Armour,
  Set_Head_Type,
  Set_Pants_Type,
  Upgrade_Weapon_Damage,
  Purchase_Weapon,
  Equip_Weapon,
  Store_Close,
  Weather_Toggle_Rain,
  Weather_Toggle_Breeze,
  Weather_Toggle_Wind,
  Weather_Toggle_Lightning,
  Weather_Toggle_Time_Passing,
}

const clientRequests = ClientRequest.values;
final clientRequestsLength = clientRequests.length;
