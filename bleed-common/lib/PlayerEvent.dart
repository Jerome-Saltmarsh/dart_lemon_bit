
enum PlayerEvent {
  Level_Up,
  Skill_Upgraded,
  Teleported,
  Dash_Activated,
  Item_Purchased,
  Item_Equipped,
  Item_Sold,
  Drink_Potion,
  Orb_Earned_Topaz,
  Orb_Earned_Ruby,
  Orb_Earned_Emerald,
}

final List<PlayerEvent> playerEvents = PlayerEvent.values;