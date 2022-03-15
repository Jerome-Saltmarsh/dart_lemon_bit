enum CharacterState {
  Idle,
  Dead,
  Running,
  Changing,
  Performing,
  Hurt,
}

const characterStates = CharacterState.values;

extension CharacterStateProperties on CharacterState {
  bool get idle => this == CharacterState.Idle;
  bool get running => this == CharacterState.Running;
  bool get hurt => this == CharacterState.Hurt;
  bool get performing => this == CharacterState.Performing;
}

