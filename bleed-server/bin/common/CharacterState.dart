enum CharacterState {
  Idle,
  Walking,
  Dead,
  Aiming,
  Firing,
  Striking,
  Running,
  Reloading,
  ChangingWeapon,
  Performing,
}

const List<CharacterState> characterStates = CharacterState.values;

