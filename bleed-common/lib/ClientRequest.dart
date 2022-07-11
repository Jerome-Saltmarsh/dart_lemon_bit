enum ClientRequest {
  Update,
  Join,
  Attack,
  Revive,
  Equip,
  Toggle_Debug,
  Version,
  Speak,
  Skip_Hour,
  Reverse_Hour,
  Teleport,
  Upgrade,
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
  Weather_Set_Rain,
  Weather_Set_Wind,
  Weather_Set_Lightning,
  Weather_Toggle_Breeze,
  Weather_Toggle_Time_Passing,
  Custom_Game_Names,
  Editor_Load_Game,
  Editor_Set_Scene_Name,
  Time_Set_Hour,
  Submit_Player_Design,
  Editor_Set_Canvas_Size,
}

const clientRequests = ClientRequest.values;
final clientRequestsLength = clientRequests.length;
