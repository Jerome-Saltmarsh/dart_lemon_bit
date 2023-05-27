
import 'package:bleed_server/gamestream.dart';

mixin class GameFight2DCharacter {
  static const frictionFloor = 0.88;
  static const frictionFloorSliding = 0.92;
  static const frictionAir = 0.95;
  static const Jump_Acceleration_Horizontal = 4.0;
  static const Jump_Frame = 4;
  static const Max_Jumps = 2;

  var emitEventJump = false;
  var direction = GameFight2DDirection.Left;
  var stateDuration = 0;
  var stateDurationInterruptable = 0;
  var stateDurationTotal = 0;
  var state = GameFight2DCharacterState.Idle;
  var _nextState = GameFight2DCharacterState.Idle;
  var x = 0.0;
  var y = 0.0;
  var accelerationX = 0.0;
  var accelerationY = 0.0;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var grounded = false;
  var jumpCount = 0;
  var directionRequested = 0;

  var _jumpingRequested = false;

  bool get jumpingRequested => _jumpingRequested;

  static int getStateDurationTotal(int state) => const {
    GameFight2DCharacterState.Striking: 30,
    GameFight2DCharacterState.Crouching_Strike: 30,
    GameFight2DCharacterState.Jumping: 12,
    GameFight2DCharacterState.Airborn_Strike: 30,
    GameFight2DCharacterState.Airborn_Strike_Up: 30,
    GameFight2DCharacterState.Striking_Up: 30,
    GameFight2DCharacterState.Second_Jump: 12,
    GameFight2DCharacterState.Running_Strike: 20,
    GameFight2DCharacterState.Hurting: 30,
    GameFight2DCharacterState.Hurting_Airborn: 30,
  }[state] ?? 0;

  static int getStateDurationInterruptable(int state) => const {
    GameFight2DCharacterState.Jumping: 10,
    GameFight2DCharacterState.Second_Jump: 10,
  }[state] ?? 0;

  set jumpingRequested(bool value){
    if (_jumpingRequested == value) return;
    _jumpingRequested = value;
    if (_jumpingRequested) {
      jump();
    }
  }

  int get nextState => _nextState;

  set nextState(int value) {
    assert (!busy);
    if (busy) return;
    if (value == _nextState) return;

    assert((){
      print("next state changed from: ${GameFight2DCharacterState.getName(_nextState)} to: ${GameFight2DCharacterState.getName(value)}");
      return true;
    }());

    _nextState = value;
    stateDurationTotal = getStateDurationTotal(_nextState);
    stateDurationInterruptable = getStateDurationInterruptable(_nextState);
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
          state == GameFight2DCharacterState.Hurting_Airborn  ||
          nextState == GameFight2DCharacterState.Hurting      ||
          nextState == GameFight2DCharacterState.Hurting_Airborn ;

  bool get busy {
    if (stateDurationInterruptable > 0){
      return stateDuration < stateDurationInterruptable;
    }
    if (stateDurationTotal > 0){
      return stateDuration < stateDurationTotal;
    }
    return false;
  }

  bool get striking =>
      state == GameFight2DCharacterState.Striking ||
          nextState == GameFight2DCharacterState.Striking ||
          state == GameFight2DCharacterState.Airborn_Strike ||
          nextState == GameFight2DCharacterState.Airborn_Strike ||
          state == GameFight2DCharacterState.Running_Strike ||
          nextState == GameFight2DCharacterState.Running_Strike ||
          state == GameFight2DCharacterState.Striking_Up ||
          nextState == GameFight2DCharacterState.Striking_Up;

  bool get falling => velocityY > 0;

  // METHODS

  void hurt() {
    if (!grounded){
      hurtAirborn();
      return;
    }
    forceIdle();
    nextState = GameFight2DCharacterState.Hurting;
  }

  void hurtAirborn() {
    forceIdle();
    nextState = GameFight2DCharacterState.Hurting_Airborn;
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

    if (busy) return;

    if (!grounded){
      airbornStrike();
      return;
    }

    if (running && velocityX.abs() > 5){
      runningStrike();
      return;
    }

    nextState = GameFight2DCharacterState.Striking;
  }

  void airbornStrike() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Airborn_Strike;
  }

  void runningStrike() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Running_Strike;
  }

  void runLeft() {
    if (busy) return;
    faceLeft();
    run();
  }

  void runRight() {
    if (busy) return;
    faceRight();
    run();
  }

  void run(){
    if (grounded) {
      nextState = GameFight2DCharacterState.Running;
    } else {
      nextState = GameFight2DCharacterState.Airborn_Movement;
    }
    stateDurationTotal = 0;
  }

  void faceLeft() {
    if (busy) return;
    direction = GameFight2DDirection.Left;
  }

  void faceRight() {
    if (busy) return;
    direction = GameFight2DDirection.Right;
  }

  bool get canStrikeUpOrDown => (jumping && stateDuration < Jump_Frame) || !busy;

  void strikeUp() {
    if (!canStrikeUpOrDown) return;
    forceIdle();
    if (grounded){
      nextState = GameFight2DCharacterState.Striking_Up;
    } else {
      nextState = GameFight2DCharacterState.Airborn_Strike_Up;
    }
  }

  void strikeDown() {
    if (!canStrikeUpOrDown) return;
    forceIdle(); // cancel the current jump action
    if (grounded) {
      nextState = GameFight2DCharacterState.Crouching_Strike;
    } else {
      nextState = GameFight2DCharacterState.Airborn_Strike_Down;
    }
  }

  void airbornStrikeUp() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Airborn_Strike_Up;
  }

  bool get directionRequestedUp => directionRequested == InputDirection.Up;

  bool get maxJumpsReached => jumpCount >= Max_Jumps;

  void jump() {

    if (striking && canStrikeUpOrDown) {
      strikeUp();
      return;
    }

    if (maxJumpsReached) return;

    if (busy) return;

    if (!grounded) {
      nextState = GameFight2DCharacterState.Second_Jump;
      return;
    }
    if (velocityY < 0) return;
    nextState = GameFight2DCharacterState.Jumping;
  }

  void idle() {
    if (busy) return;
    forceIdle();
  }

  void fallDown(){
    if (busy) return;
    nextState = GameFight2DCharacterState.Idle_Airborn;
  }

  void forceIdle() {
    setStateDurationZero();
    _nextState = grounded
        ? GameFight2DCharacterState.Idle
        : GameFight2DCharacterState.Idle_Airborn;
    stateDurationTotal = 0;
    stateDurationInterruptable = 0;
  }

  void respawn() {
    x = 100;
    y = 0;
    velocityX = 0;
    velocityY = 0;
    setStateDurationZero();
    forceIdle();
  }

  void update() {
    const gravity = 1.00;
    const runAcceleration = 1.0;
    const airAcceleration = 0.25;
    const jumpAcceleration = 15.0;
    const strikeUpAcceleration = 7.5;
    const fallAcceleration = 0.5;
    const maxRunSpeed = 6.0;

    if (y > 1000){
      respawn();
    }

    if (state != nextState) {
      if (state == GameFight2DCharacterState.Running && nextState == GameFight2DCharacterState.Jumping){
        if (facingLeft){
          accelerationX -= Jump_Acceleration_Horizontal;
        } else {
          accelerationX += Jump_Acceleration_Horizontal;
        }
      }

      state = nextState;
      setStateDurationZero();
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

  void setStateDurationZero() {
    stateDuration = 0;

    if (nextState == GameFight2DCharacterState.Second_Jump && maxJumpsReached){
      print("error");
    }
  }

  void applyJumpAcceleration(double jumpAcceleration) {
    // assert (!maxJumpsReached);
    if (maxJumpsReached) return;
    accelerationY -= jumpAcceleration;
    jumpCount++;
    emitEventJump = true;
  }

  double get friction {
    if (grounded) {
      if (state == GameFight2DCharacterState.Running_Strike) {
        return frictionFloorSliding;
      }
      return frictionFloor;
    }

    return frictionAir;
  }

}
