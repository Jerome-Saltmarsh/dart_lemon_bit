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

const stateIdleIndex = 0;
const stateDeadIndex = 1;
const stateRunningIndex = 2;
const stateChanging = 3;
const statePerformingIndex = 4;
const stateHurtIndex = 5;

const characterStates = CharacterState.values;

extension CharacterStateProperties on CharacterState {
  bool get idle => this == stateIdle;
  bool get running => this == stateRunning;
  bool get hurt => this == stateHurt;
  bool get performing => this == statePerforming;
}

