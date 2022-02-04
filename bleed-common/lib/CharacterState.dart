enum CharacterState {
  Idle,
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

