enum CharacterState {
  Idle,
  Walking,
  Dead,
  Aiming,
  Firing,
  Striking,
  Running,
  Reloading,
  ChangingWeapon
}

const List<CharacterState> characterStates = CharacterState.values;
