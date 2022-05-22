enum ClientRequest {
  Update,
  Join,
  Join_Custom,
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
  Modify_Game,
  Sell_Slot,
  Equip_Slot,
  Unequip_Slot,
  Character_Save,
  Character_Load,
  Construct,
  Upgrade,
  Scene,
  Select_Character_Type,
  Toggle_Objects_Destroyable,
  Deck_Add_Card,
  Deck_Select_Card,
}

const clientRequests = ClientRequest.values;