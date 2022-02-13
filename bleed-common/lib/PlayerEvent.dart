
enum PlayerEvent {
  Level_Up,
  Skill_Upgraded,
  Teleported,
  Dash_Activated,
  Item_Purchased,
  Item_Equipped,
  Item_Sold,
  Drink_Potion,
}

final List<PlayerEvent> playerEvents = PlayerEvent.values;