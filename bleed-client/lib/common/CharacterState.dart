enum CharacterState {
  Idle,
  Dead,
  Firing,
  Striking,
  Running,
  Changing,
  Performing,
}

const List<CharacterState> characterStates = CharacterState.values;

extension CharacterStateProperties on CharacterState {
  bool get idle => this == CharacterState.Idle;
  bool get running => this == CharacterState.Running;
}

