
import 'package:bleed_server/gamestream.dart';

mixin class GameFight2DCharacter {
  static const Running_Strike_Velocity = 5.0;
  static const Friction_Floor = 0.88;
  static const Friction_Floor_Sliding = 0.92;
  static const Friction_Air = 0.95;
  static const Jump_Acceleration_Horizontal = 4.0;
  static const Jump_Frame = 4;
  static const Max_Jumps = 2;
  static const gravity = 1.00;
  static const runAcceleration = 1.0;
  static const airAcceleration = 0.5;
  static const jumpAcceleration = 20.0;
  static const rollingAcceleration = 0.75;
  static const strikeUpAcceleration = 2.5;
  static const fallAcceleration = 0.5;
  static const maxRunSpeed = 6.0;
  static const Max_Jump_Velocity = 3.0;
  static const Damage_Force_Ratio = 0.1;

  final strikeFrame = 5;
  final strikeSwingFrame = 3;

  var damage = 0;
  var mass = 1.0;
  var emitEventJump = false;
  var stateDuration = 0;
  var stateDurationTotal = 0;
  var x = 0.0;
  var y = 0.0;
  var ignoreCollisions = false;
  var accelerationX = 0.0;
  var accelerationY = 0.0;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var grounded = false;
  var jumpCount = 0;
  var strikeDamage = 5;
  var runningStrikeDamage = 4;

  var _direction = GameFight2DDirection.Left;
  var _state = GameFight2DCharacterState.Idle;
  var _jumpingRequested = false;

  int get direction => _direction;
  int get state => _state;
  double get damageForce => damage * Damage_Force_Ratio;
  bool get jumpingRequested => _jumpingRequested;

  bool get invulnerable {
    return state == GameFight2DCharacterState.Rolling;
  }

  set direction(int value){
    if (busy) return;
    _direction = value;
  }

  void forceFaceLeft(){
    _direction = GameFight2DDirection.Left;
  }

  void forceFaceRight(){
    _direction = GameFight2DDirection.Right;
  }

  set jumpingRequested(bool value){
    if (_jumpingRequested == value) return;
    _jumpingRequested = value;
    if (_jumpingRequested) {
      jump();
    }
  }

  int get stateDamage => switch (state) {
    GameFight2DCharacterState.Striking => 4,
    GameFight2DCharacterState.Airborn_Strike_Up => 6,
    GameFight2DCharacterState.Airborn_Strike => 4,
    GameFight2DCharacterState.Airborn_Strike_Down => 6,
    GameFight2DCharacterState.Running_Strike => 3,
    GameFight2DCharacterState.Striking_Up => 6,
    GameFight2DCharacterState.Crouching_Strike => 3,
    _ => 0
  };

  double get stateAttackForceX {
    final value = switch (state) {
      GameFight2DCharacterState.Striking => 0.75,
      GameFight2DCharacterState.Running_Strike => 0.75,
      GameFight2DCharacterState.Striking_Up => 0.0,
      GameFight2DCharacterState.Airborn_Strike => 1.0,
      GameFight2DCharacterState.Airborn_Strike_Down => 0.0,
      GameFight2DCharacterState.Airborn_Strike_Up => 0.0,
      GameFight2DCharacterState.Crouching_Strike => 0.5,
      _ => 0
    }.toDouble();
    return facingLeft ? -value : value;
  }

  double get stateAttackForceY {
    return switch (state) {
      GameFight2DCharacterState.Striking => -0.5,
      GameFight2DCharacterState.Running_Strike => -0.5,
      GameFight2DCharacterState.Striking_Up => -1.0,
      GameFight2DCharacterState.Airborn_Strike => 0.2,
      GameFight2DCharacterState.Airborn_Strike_Down => 1.0,
      GameFight2DCharacterState.Airborn_Strike_Up => -1.0,
      GameFight2DCharacterState.Crouching_Strike => -0.5,
      _ => 0
    }.toDouble();
  }

  bool get interruptable => stateDurationTotal == 0 || stateDuration > stateDurationTotal;

  int get statePriority => GameFight2DCharacterState.getPriority(_state);

  set state(int value) {

    if (GameFight2DCharacterState.getPriority(value) <= statePriority) {
      if (!interruptable) return;
    }
    if (value == _state) return;

    assert((){
      print("next state changed from: ${GameFight2DCharacterState.getName(_state)} to: ${GameFight2DCharacterState.getName(value)}");
      return true;
    }());

    _state = value;
    stateDuration = 0;
    stateDurationTotal = getStateDurationTotal(_state);
  }

  // PROPERTIES

  bool get facingLeft => direction == GameFight2DDirection.Left;

  bool get jumping =>
      state == GameFight2DCharacterState.Jumping ||
          state == GameFight2DCharacterState.Second_Jump;

  bool get running =>
      state == GameFight2DCharacterState.Running;

  bool get hurting =>
      state == GameFight2DCharacterState.Hurting          ||
      _state == GameFight2DCharacterState.Hurting_Airborn ;

  bool get busy {
    // if (stateDurationInterruptable > 0){
    //   return stateDuration < stateDurationInterruptable;
    // }
    if (stateDurationTotal > 0){
      return stateDuration < stateDurationTotal;
    }
    return false;
  }

  bool get striking =>
      state     == GameFight2DCharacterState.Striking       ||
      state     == GameFight2DCharacterState.Airborn_Strike ||
      state     == GameFight2DCharacterState.Running_Strike ||
      state     == GameFight2DCharacterState.Striking_Up    ;

  bool get falling => velocityY > 0;

  bool get maxJumpsReached => jumpCount >= Max_Jumps;

  // METHODS

  void hurt() {
    state = grounded ? GameFight2DCharacterState.Hurting : GameFight2DCharacterState.Hurting_Airborn;
  }

  void hurtAirborn() {
    state = GameFight2DCharacterState.Hurting_Airborn;
  }

  void strike() {
    if (!grounded) {
      state = GameFight2DCharacterState.Airborn_Strike;
      return;
    }
    if (running && velocityX.abs() > Running_Strike_Velocity){
      state = GameFight2DCharacterState.Running_Strike;
      return;
    }
    state = GameFight2DCharacterState.Striking;
  }

  void runLeft() {
    faceLeft();
    run();
  }

  void runRight() {
    faceRight();
    run();
  }

  void run() => state = grounded
        ? GameFight2DCharacterState.Running
        : GameFight2DCharacterState.Airborn_Movement;

  void faceLeft() {
    direction = GameFight2DDirection.Left;
  }

  void faceRight() {
    direction = GameFight2DDirection.Right;
  }

  bool get canStrikeUpOrDown => (jumping && stateDuration < Jump_Frame) || !busy;

  void strikeUp() {
    if (!canStrikeUpOrDown) return;
    forceIdle();
    state = grounded
        ? GameFight2DCharacterState.Striking_Up
        : GameFight2DCharacterState.Airborn_Strike_Up;
  }

  void strikeDown() {
    if (!canStrikeUpOrDown) return;
    forceIdle();
    state = grounded ? GameFight2DCharacterState.Crouching_Strike : GameFight2DCharacterState.Airborn_Strike_Down;
  }

  void airbornStrikeUp() {
    state = GameFight2DCharacterState.Airborn_Strike_Up;
  }

  void jump() {

    if (jumpingRequested) return;
    jumpingRequested = true;

    if (striking && canStrikeUpOrDown) {
      strikeUp();
      return;
    }

    if (maxJumpsReached) return;

    if (!grounded) {
      state = GameFight2DCharacterState.Second_Jump;
      return;
    }
    if (velocityY < 0) return;
    state = GameFight2DCharacterState.Jumping;
  }

  void idle() {
    if (busy) return;
    forceIdle();
  }

  void fallDown(){
    state = GameFight2DCharacterState.Idle_Airborn;
  }

  void forceIdle() {
    final _nextState = grounded
        ? GameFight2DCharacterState.Idle
        : GameFight2DCharacterState.Idle_Airborn;

    if (_state == _nextState) return;
    _state = _nextState;
    stateDuration = 0;
    stateDurationTotal = 0;
  }

  void respawn() {
    x = 0;
    y = 0;
    velocityX = 0;
    velocityY = 0;
    accelerationX = 0;
    accelerationY = 0;
    stateDuration = 0;
    damage = 0;
    forceIdle();
  }

  void update() {

    if (stateDurationTotal > 0 && stateDuration > stateDurationTotal){
      forceIdle();
    }

    switch (state) {
      case GameFight2DCharacterState.Idle:
        if (!grounded && falling){
          fallDown();
        }
        break;
      case GameFight2DCharacterState.Airborn_Movement:
        if (facingLeft) {
          accelerationX -= airAcceleration;
        } else {
          accelerationX += airAcceleration;
        }
        break;
      case GameFight2DCharacterState.Running:
        if (facingLeft) {
          if (velocityX > -maxRunSpeed){
            accelerationX -= runAcceleration;
          }
        } else {
          if (velocityX < maxRunSpeed){
            accelerationX += runAcceleration;
          }
        }
        break;
      case GameFight2DCharacterState.Jumping:
        if (stateDuration == Jump_Frame) {
          applyJumpAcceleration(jumpAcceleration);
        }
        if (falling) {
          forceIdle();
        }
        break;
      case GameFight2DCharacterState.Rolling:
        if (stateDuration > 25) break;
        accelerationX += facingLeft ? -rollingAcceleration : rollingAcceleration;
        break;
      case GameFight2DCharacterState.Second_Jump:
        if (stateDuration == Jump_Frame) {
          applyJumpAcceleration(jumpAcceleration);
          break;
        }
        break;
      case GameFight2DCharacterState.Running_Strike:
        if (stateDuration == 0) {
          const runStrikeAcceleration = 3.0;
          if (facingLeft){
            accelerationX -= runStrikeAcceleration;
          } else {
            accelerationX += runStrikeAcceleration;
          }
          break;
        }
        break;
      case GameFight2DCharacterState.Fall_Fast:
        accelerationY += fallAcceleration;
        break;
      case GameFight2DCharacterState.Airborn_Strike_Up:
        if (stateDuration == 0) {
          accelerationY -= strikeUpAcceleration;
          break;
        }
        break;
    }

    if (!grounded) {
      accelerationY += gravity;
    }
    velocityX += accelerationX;
    velocityY += accelerationY;
    accelerationX = 0;
    accelerationY = 0;
    velocityX *= friction;
    stateDuration++;
  }

  void applyVelocity(){
    x += velocityX;
    y += velocityY;
  }

  void applyJumpAcceleration(double jumpAcceleration) {
    if (maxJumpsReached) return;

    accelerationY -= jumpAcceleration;
    jumpCount++;
    emitEventJump = true;
    if (!grounded){
      jumpCount = 5;
    }
  }

  double get friction {
    if (grounded) {
      if (state == GameFight2DCharacterState.Running_Strike) {
        return Friction_Floor_Sliding;
      }
      return Friction_Floor;
    }

    return Friction_Air;
  }

  static int getStateDurationTotal(int state) => const {
    GameFight2DCharacterState.Striking: 30,
    GameFight2DCharacterState.Running_Strike: 30,
    GameFight2DCharacterState.Crouching_Strike: 30,
    GameFight2DCharacterState.Jumping: Jump_Frame + 1,
    GameFight2DCharacterState.Airborn_Strike: 30,
    GameFight2DCharacterState.Airborn_Strike_Up: 30,
    GameFight2DCharacterState.Airborn_Strike_Down: 30,
    GameFight2DCharacterState.Striking_Up: 20,
    GameFight2DCharacterState.Second_Jump: 12,
    GameFight2DCharacterState.Hurting: 30,
    GameFight2DCharacterState.Hurting_Airborn: 30,
    GameFight2DCharacterState.Rolling: 30,
  }[state] ?? 0;

  static int getStateDurationInterruptable(int state) => const {
    GameFight2DCharacterState.Jumping: 10,
    GameFight2DCharacterState.Second_Jump: 10,
  }[state] ?? 0;
}
