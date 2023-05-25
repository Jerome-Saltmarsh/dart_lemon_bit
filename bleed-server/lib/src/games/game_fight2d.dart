
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:lemon_math/functions/random_between.dart';

class GameFight2DScene {
  static const tileSize = 32.0;

  int width;
  int height;
  /// width * nodeSIze
  late double widthLength;
  /// height * nodeSize
  late double heightLength;

  late Uint8List tiles;

  GameFight2DScene({required this.width, required this.height}) {
     tiles = Uint8List(width * height);
     this.widthLength = width * tileSize;
     this.heightLength = height * tileSize;

     var index = 0;
     for (var x = 0; x < width; x++){
        for (var y = 0; y < height; y++){
          tiles[index] = y > height - 3 ? Fight2DNodeType.Grass : Fight2DNodeType.Empty;
          index++;
        }
     }
  }

  int getTileTypeAtXY(double x, double y) {
    if (x < 0 || y < 0) {
      return Fight2DNodeType.Out_Of_Bounds;
    }
    if (x > widthLength || y > heightLength) {
      return Fight2DNodeType.Out_Of_Bounds;
    }

    final nodeX = x ~/ tileSize;
    final nodeY = y ~/ tileSize;
    return tiles[nodeX * height + nodeY];
  }
}

class GameFight2D extends Game<GameFight2DPlayer> {

  final List<GameFight2DCharacter> characters = [];
  final scene = GameFight2DScene(width: 20, height: 20);

  GameFight2D() : super(gameType: GameType.Fight2D);

  @override
  GameFight2DPlayer createPlayer() {
    final player = GameFight2DPlayer(this);
    player.writeScene();
    player.x = randomBetween(0, scene.widthLength);
    player.y = 0;
    characters.add(player);
    return player;
  }

  @override
  void onPlayerUpdateRequestReceived({
    required GameFight2DPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {
     if (keySpaceDown) {
        player.strike();
     }
     if (mouseLeftDown){
       player.strike();
     }
     player.jumpingRequested = mouseRightDown || keySpaceDown;
     player.directionRequested = direction;

     switch (direction) {
       case InputDirection.Right:
         player.runRight();
         break;
       case InputDirection.Up_Right:
         player.jump();
         break;
       case InputDirection.Up_Left:
         player.jump();
         break;
       case InputDirection.Left:
         player.runLeft();
         break;
       case InputDirection.Up:
         player.jump();
         break;
       case InputDirection.Down:
         player.crouch();
         break;
       case InputDirection.None:
         player.idle();
         break;
     }
  }

  @override
  void removePlayer(GameFight2DPlayer player) {
    characters.remove(player);
  }

  @override
  void update() {
    for (final character in characters) {
      character.update();
      if (character.striking && character.stateDuration == 5) {
         for (final otherCharacter in characters){
            if (otherCharacter == character) continue;
            final xDiff = character.x - otherCharacter.x;
            const range = 100.0;
            const force = 10.0;
            if (character.facingLeft){
              if (xDiff > 0 && xDiff < range) {
                if (character.state == GameFight2DCharacterState.Running_Strike){
                  otherCharacter.hurtAirborn();
                  otherCharacter.accelerationY -= force;
                } else {
                  otherCharacter.hurt();
                }
                otherCharacter.accelerationX -= force;
              }
            } else {
              if (xDiff < range) {
                if (character.state == GameFight2DCharacterState.Running_Strike){
                  otherCharacter.hurtAirborn();
                  otherCharacter.accelerationY -= force;
                } else {
                  otherCharacter.hurt();
                }
                otherCharacter.accelerationX += force;
              }
            }
         }
      }
    }

    for (final character in characters) {
       var tileType = scene.getTileTypeAtXY(character.x, character.y + 50.0);
       if (tileType == Fight2DNodeType.Grass) {

         if (!character.grounded) {
           // on landed
           character.grounded = true;
           character.jumpCount = 0;
           character.forceIdle();
           // if (
           //    character.jumping ||
           //    character.striking ||
           //    character.hurtingAirborn ||
           //    character.stateFalling
           // ) {
           //
           // }
         }

         while (scene.getTileTypeAtXY(character.x, character.y + 49.0) == Fight2DNodeType.Grass){
            character.y--;
         }
         if (character.velocityY > 0) {
           character.velocityY = 0;
         }
       } else {
         character.grounded = false;
       }
    }
  }
}

mixin class GameFight2DCharacter {

  static const frictionFloor = 0.88;
  static const frictionAir = 0.95;
  static const Jump_Acceleration_Horizontal = 4.0;
  static const Jump_Frame = 4;

  var direction = GameFight2DDirection.Left;
  var stateDuration = 0;
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

  set jumpingRequested(bool value){
     if (_jumpingRequested == value) return;
     _jumpingRequested = value;
     if (_jumpingRequested) {
       jump();
     }
  }

  int get nextState => _nextState;

  set nextState(int value) {
    if (value == _nextState) return;
    print("next state changed from: ${GameFight2DCharacterState.getName(_nextState)} to: ${GameFight2DCharacterState.getName(value)}");
    _nextState = value;
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

  bool get stateFalling =>
      state == GameFight2DCharacterState.Airborn_Movement          ||
      state == GameFight2DCharacterState.Idle_Airborn     ||
      nextState == GameFight2DCharacterState.Airborn_Movement      ||
      nextState == GameFight2DCharacterState.Idle_Airborn ;

  bool get hurtingAirborn {
    return state == GameFight2DCharacterState.Hurting_Airborn;
  }

  bool get busy => stateDurationTotal > 0 || hurting;

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
    nextState = GameFight2DCharacterState.Hurting;
    stateDurationTotal = 15;
  }

  void hurtAirborn() {
    nextState = GameFight2DCharacterState.Hurting_Airborn;
  }



  void strike() {
    if (busy) return;

    if (!grounded){
      if (directionRequested == InputDirection.Down){
        airbornStrikeDown();
        return;
      }
      if (directionRequested == InputDirection.Up){
        airbornStrikeUp();
        return;
      }
      airbornStrike();
      return;
    }
    if (running && velocityX.abs() > 5){
      runningStrike();
      return;
    }
    if (jumping && stateDuration < 3){
      strikeUp();
      return;
    }

    nextState = GameFight2DCharacterState.Striking;
    stateDurationTotal = 30;
  }

  void airbornStrike() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Airborn_Strike;
    stateDurationTotal = 30;
  }

  void runningStrike() {
     if (busy) return;
     nextState = GameFight2DCharacterState.Running_Strike;
     stateDurationTotal = 30;
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

  void strikeUp() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Striking_Up;
    stateDurationTotal = 30;
  }

  void airbornStrikeDown() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Airborn_Strike_Down;
    stateDurationTotal = 30;
  }

  void airbornStrikeUp() {
    if (busy) return;
    nextState = GameFight2DCharacterState.Airborn_Strike_Up;
    stateDurationTotal = 30;
  }

  void jump() {
    if (jumpCount >= 2) return;

    if (striking && stateDuration < 4) {
      strikeUp();
      return;
    }

    if (busy) return;

    if (!grounded) {
      nextState = GameFight2DCharacterState.Second_Jump;
      stateDurationTotal = 12;
      jumpCount++;
      return;
    }
    if (velocityY < 0) return;
    nextState = GameFight2DCharacterState.Jumping;
    stateDurationTotal = 12;
    jumpCount++;
  }

  void idle() {
    if (busy) return;
    forceIdle();
  }

  void fallDown(){
    if (striking) return;
    if (jumping) return;
    if (hurting) return;
    nextState = GameFight2DCharacterState.Idle_Airborn;
  }

  void forceIdle() {
    if (grounded) {
      nextState = GameFight2DCharacterState.Idle;
    } else {
      nextState = GameFight2DCharacterState.Idle_Airborn;
    }
    stateDurationTotal = 0;
  }

  void respawn() {
    x = 100;
    y = 0;
    velocityX = 0;
    velocityY = 0;
    stateDuration = 0;
    stateDurationTotal = 0;
    forceIdle();
  }

  void update() {
     const gravity = 1.00;
     const runAcceleration = 1.0;
     const airAcceleration = 0.25;
     const jumpAcceleration = 15.0;
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
       stateDuration = 0;
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
           accelerationY -= jumpAcceleration;
         }
         if (falling) {
           forceIdle();
         }
         break;
       case GameFight2DCharacterState.Second_Jump:
         if (stateDuration == 0) {
           accelerationY -= jumpAcceleration;
           break;
         }
         break;
       case GameFight2DCharacterState.Fall_Fast:
         accelerationY += fallAcceleration;
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
     if (grounded) {
       velocityX *= frictionFloor;
     } else {
       velocityX *= frictionAir;
     }
     stateDuration++;

  }

}

class GameFight2DPlayer extends Player with GameFight2DCharacter {

  late GameFight2D game;

  GameFight2DPlayer(this.game);

  @override
  void writePlayerGame() {
    writeCharacters();
    writePlayer();
  }

  void writePlayer(){
    writeByte(ServerResponse.Fight2D);
    writeByte(Fight2DResponse.Player);
    writeCharacter(this);
  }

  void writeCharacters() {
    writeByte(ServerResponse.Fight2D);
    writeByte(Fight2DResponse.Characters);
    writeUInt16(game.characters.length);
    for (final character in game.characters) {
      writeByte(character.state);
      writeByte(character.direction);
      writeInt16(character.x.toInt());
      writeInt16(character.y.toInt());
      writeByte(character.stateDuration % 255);
    }
  }

  void writeCharacter(GameFight2DCharacter character){
    writeByte(character.state);
    writeInt16(character.x.toInt());
    writeInt16(character.y.toInt());
  }

  void writeScene() {
    final scene = game.scene;
    writeByte(ServerResponse.Fight2D);
    writeByte(Fight2DResponse.Scene);
    writeUInt16(scene.width);
    writeUInt16(scene.height);
    writeBytes(scene.tiles);
  }

  void crouch() {
    if (busy) return;
    if (grounded) {
      nextState = GameFight2DCharacterState.Crouching;
    } else {
      nextState = GameFight2DCharacterState.Fall_Fast;
    }
  }
}