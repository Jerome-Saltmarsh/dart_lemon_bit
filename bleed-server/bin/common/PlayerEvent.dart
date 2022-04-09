
enum PlayerEvent {
  Level_Up,
  Skill_Upgraded,
  Teleported,
  Ammo_Acquired,
  Dash_Activated,
  Item_Purchased,
  Item_Equipped,
  Medkit,
  Item_Sold,
  Drink_Potion,
  Orb_Earned_Topaz,
  Orb_Earned_Ruby,
  Orb_Earned_Emerald,
}

const playerEvents = PlayerEvent.values;