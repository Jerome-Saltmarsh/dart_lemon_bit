
enum PlayerEvent {
  Level_Up,
  Skill_Upgraded,
  Teleported,
  Dash_Activated,
  Item_Purchased,
  Item_Equipped,
}

final List<PlayerEvent> playerEvents = PlayerEvent.values;