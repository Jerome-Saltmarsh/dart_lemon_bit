enum CharacterState {
  Idle,
  Dead,
  Running,
  Changing,
  Performing,
  Hurt,
}

const stateIdle = CharacterState.Idle;
const stateRunning = CharacterState.Running;
const stateDead = CharacterState.Dead;
const stateHurt = CharacterState.Hurt;
const statePerforming = CharacterState.Hurt;

const characterStates = CharacterState.values;

extension CharacterStateProperties on CharacterState {
  bool get idle => this == stateIdle;
  bool get running => this == stateRunning;
  bool get hurt => this == stateHurt;
  bool get performing => this == statePerforming;
}

