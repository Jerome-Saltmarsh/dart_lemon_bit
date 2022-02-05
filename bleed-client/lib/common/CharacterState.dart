enum CharacterState {
  Idle,
  Dead,
  Firing,
  Striking,
  Running,
  ChangingWeapon,
  Performing,
}

const List<CharacterState> characterStates = CharacterState.values;

