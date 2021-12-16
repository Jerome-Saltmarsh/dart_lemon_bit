
final List<PlayerEventType> playerEventTypes = PlayerEventType.values;

enum PlayerEventType {
  Acquired_Handgun,
  Acquired_Shotgun,
  Acquired_SniperRifle,
  Acquired_AssaultRifle,
  HealthChanged,
  GrenadeCountChanged,
  MedCountChanged,
  LivesChanged,
  RoundsChanged_Handgun,
  RoundsChanged_Shotgun,
  RoundsChanged_SniperRifle,
  RoundsChanged_AssaultRifle,
  ClipsChanged_Handgun,
  ClipsChanged_Shotgun,
  ClipsChanged_SniperRifle,
  ClipsChanged_AssaultRifle,
  Level_Increased,
  Skill_Upgraded,
}

class PlayerEvent {
  PlayerEventType type;
  int value;
  bool sent = false;
  PlayerEvent(this.type, this.value);
}
