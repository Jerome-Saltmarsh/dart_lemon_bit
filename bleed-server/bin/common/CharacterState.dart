enum CharacterState {
  Idle,
  Dead,
  Firing,
  Striking,
  Running,
  Reloading,
  ChangingWeapon,
  Performing,
}

const List<CharacterState> characterStates = CharacterState.values;

