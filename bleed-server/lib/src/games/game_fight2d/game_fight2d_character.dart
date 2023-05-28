
import 'package:bleed_server/gamestream.dart';
import 'package:lemon_math/library.dart';

mixin class GameFight2DCharacter {
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
  static const strikeUpAcceleration = 7.5;
  static const fallAcceleration = 0.5;
  static const maxRunSpeed = 6.0;

  final strikeFrame = 5;

  var emitEventJump = false;
  var stateDuration = 0;
  var stateDurationTotal = 0;
  var x = 0.0;
  var y = 0.0;
  var accelerationX = 0.0;
  var accelerationY = 0.0;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var grounded = false;
  var jumpCount = 0;
  var directionRequested = 0;

  var _direction = GameFight2DDirection.Left;
  var _state = GameFight2DCharacterState.Idle;
  var _jumpingRequested = false;

  int get direction => _direction;
  int get state => _state;
  bool get jumpingRequested => _jumpingRequested;

  set direction(int value){
    if (busy) return;
    _direction = value;
  }

  set jumpingRequested(bool value){
    if (_jumpingRequested == value) return;
    _jumpingRequested = value;
    if (_jumpingRequested) {
      jump();
    }
  }

  bool get interruptable => stateDurationTotal == 0 || stateDuration > stateDurationTotal;

  int get statePriority => GameFight2DCharacterState.getPriority(_state);

  set state(int value) {

    if (GameFight2DCharacterState.getPriority(value) <= statePriority) {
      if (!interruptable) return;
      // return;
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

  bool get directionRequestedUp => directionRequested == InputDirection.Up;

  bool get maxJumpsReached => jumpCount >= Max_Jumps;

  // METHODS

  void hurt() {
    state = grounded ? GameFight2DCharacterState.Hurting : GameFight2DCharacterState.Hurting_Airborn;
  }

  void hurtAirborn() {
    state = GameFight2DCharacterState.Hurting_Airborn;
  }

  void strike() {
    switch (directionRequested){
      case InputDirection.Up:
        strikeUp();
        return;
      case InputDirection.Down:
        strikeDown();
        return;
    }

    if (!grounded){
      airbornStrike();
      return;
    }

    if (running && velocityX.abs() > 5){
      runningStrike();
      return;
    }

    state = GameFight2DCharacterState.Striking;
  }

  void airbornStrike() => state = GameFight2DCharacterState.Airborn_Strike;

  void runningStrike() => state = GameFight2DCharacterState.Running_Strike;

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
    // print("forceIdle()");
    _state = _nextState;
    stateDuration = 0;
    stateDurationTotal = 0;
  }

  void respawn() {
    x = randomBetween(0, 300);
    y = 0;
    velocityX = 0;
    velocityY = 0;
    stateDuration = 0;
    forceIdle();
  }

  void update() {

    if (y > 1000) {
      respawn();
    }

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
    x += velocityX;
    y += velocityY;
    velocityX *= friction;
    stateDuration++;
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
    GameFight2DCharacterState.Jumping: 12,
    GameFight2DCharacterState.Airborn_Strike: 30,
    GameFight2DCharacterState.Airborn_Strike_Up: 30,
    GameFight2DCharacterState.Airborn_Strike_Down: 30,
    GameFight2DCharacterState.Striking_Up: 20,
    GameFight2DCharacterState.Second_Jump: 12,
    GameFight2DCharacterState.Hurting: 30,
    GameFight2DCharacterState.Hurting_Airborn: 30,
  }[state] ?? 0;

  static int getStateDurationInterruptable(int state) => const {
    GameFight2DCharacterState.Jumping: 10,
    GameFight2DCharacterState.Second_Jump: 10,
  }[state] ?? 0;
}
