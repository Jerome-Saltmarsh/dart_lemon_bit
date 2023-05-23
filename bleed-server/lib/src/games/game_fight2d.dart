
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
    }

    for (final character in characters) {
       var tileType = scene.getTileTypeAtXY(character.x, character.y + 50.0);
       if (tileType == Fight2DNodeType.Grass) {
         character.grounded = true;
         while (scene.getTileTypeAtXY(character.x, character.y + 50.0) == Fight2DNodeType.Grass){
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

class GameFight2DCharacter {
  var direction = GameFight2DDirection.Left;
  var stateDuration = 0;
  var state = GameFight2DCharacterState.Idle;
  var _nextState = GameFight2DCharacterState.Idle;
  var x = 0.0;
  var y = 0.0;
  var accelerationX = 0.0;
  var accelerationY = 0.0;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var grounded = false;
  var falling = false;

  int get nextState => _nextState;

  set nextState(int value) {
    if (_nextState == value) return;
    // print("next state changed from: ${GameFight2DCharacterState.getName(_nextState)} to: ${GameFight2DCharacterState.getName(value)}");
    _nextState = value;
  }

  static const frictionFloor = 0.88;
  static const frictionAir = 0.95;

  // PROPERTIES

  bool get facingLeft => direction == GameFight2DDirection.Left;

  bool get running =>
      state == GameFight2DCharacterState.Running;

  bool get striking =>
      state == GameFight2DCharacterState.Striking            ||
      nextState == GameFight2DCharacterState.Striking        ||
      state == GameFight2DCharacterState.Running_Strike      ||
      nextState == GameFight2DCharacterState.Running_Strike  ;


  // METHODS

  void strike() {
    if (striking) return;
    nextState = running
        ? GameFight2DCharacterState.Running_Strike
        : GameFight2DCharacterState.Striking;
  }

  void printStateChange() =>
      print("state: ${GameFight2DCharacterState.getName(state)}, nextState: ${GameFight2DCharacterState.getName(nextState)}");

  void runLeft(){
    if (striking) return;
    faceLeft();
    nextState = GameFight2DCharacterState.Running;
  }

  void runRight(){
    if (striking) return;
    faceRight();
    nextState = GameFight2DCharacterState.Running;
  }

  void faceLeft() {
    direction = GameFight2DDirection.Left;
  }

  void faceRight() {
    direction = GameFight2DDirection.Right;
  }


  void jump() {
    if (striking) return;
    if (!grounded) return;
    if (velocityY < 0) return;

    if (facingLeft) {
      nextState = GameFight2DCharacterState.Jumping;
    } else {
      nextState = GameFight2DCharacterState.Jumping;
    }
  }

  void idle() {
    if (striking) return;
    forceIdle();
  }

  void forceIdle() {
      nextState = GameFight2DCharacterState.Idle;
  }

  void respawn() {
    x = 100;
    y = 0;
    velocityX = 0;
    velocityY = 0;
  }

  void update(){
     const gravity = 0.5;
     const runAcceleration = 0.5;
     const jumpAcceleration = 10.0;

     if (y > 1000){
       respawn();
     }

     if (state != nextState) {
       print("state changed from: ${GameFight2DCharacterState.getName(state)} to: ${GameFight2DCharacterState.getName(nextState)}");
       state = nextState;
       stateDuration = 0;
     } else {
       stateDuration++;
     }

     switch (state) {
       case GameFight2DCharacterState.Idle:
         break;
       case GameFight2DCharacterState.Striking:
         if (stateDuration > 16){
           forceIdle();
         }
         break;
       case GameFight2DCharacterState.Running_Strike:
         if (stateDuration > 16){
           forceIdle();
         }
         break;
       case GameFight2DCharacterState.Running:
         if (facingLeft) {
           accelerationX -= runAcceleration;
         } else {
           accelerationX += runAcceleration;
         }
         break;
       case GameFight2DCharacterState.Jumping:
         accelerationY -= jumpAcceleration;
         idle();
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
}

