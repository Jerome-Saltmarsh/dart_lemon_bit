enum CharacterState {
  Idle,
  Dead,
  Firing,
  Running,
  Changing,
  Performing,
}

const characterStates = CharacterState.values;

extension CharacterStateProperties on CharacterState {
  bool get idle => this == CharacterState.Idle;
  bool get running => this == CharacterState.Running;
}

