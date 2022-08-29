enum ClientRequest {
  Update,
  Join,
  Attack,
  Attack_Basic,
  Caste,
  Caste_Basic,
  Revive,
  Equip,
  Toggle_Debug,
  Version,
  Speak,
  Skip_Hour,
  Reverse_Hour,
  Teleport,
  Deck_Add_Card,
  Deck_Select_Card,
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
  Save_Scene,
  Editor_Set_Scene_Name,
  Time_Set_Hour,
  Submit_Player_Design,
  Editor_Set_Canvas_Size,
  Canvas_Modify_Size,
  Npc_Talk_Select_Option,
  GameObject,
  Node,
  Editor_Load_Scene,
}

const clientRequests = ClientRequest.values;
final clientRequestsLength = clientRequests.length;
