enum ClientRequest {
  Update,
  Join,
  Revive,
  Toggle_Debug,
  Version,
  Speak,
  Teleport,
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
  Npc_Talk_Select_Option,
  GameObject,
  Node,
  Editor_Load_Scene,
  Teleport_Scene,
  Spawn_Node_Data,
  Spawn_Node_Data_Modify,
  Game_Waves,
  Edit,
}

const clientRequests = ClientRequest.values;
final clientRequestsLength = clientRequests.length;
