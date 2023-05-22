
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
     switch (direction) {
       case InputDirection.Right:
         player.nextState = GameFight2DCharacterState.runRight;
         break;
       case InputDirection.Up_Right:
         player.jump();
         break;
       case InputDirection.Up_Left:
         player.jump();
         break;
       case InputDirection.Left:
         player.nextState = GameFight2DCharacterState.runLeft;
         break;
       case InputDirection.Up:
         player.jump();
         break;
       case InputDirection.None:
         player.nextState = GameFight2DCharacterState.idle;
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
  var state = GameFight2DCharacterState.idle;
  var nextState = GameFight2DCharacterState.idle;
  var x = 0.0;
  var y = 0.0;
  var accelerationX = 0.0;
  var accelerationY = 0.0;
  var velocityX = 0.0;
  var velocityY = 0.0;
  var grounded = false;

  static const frictionFloor = 0.88;
  static const frictionAir = 0.95;

  void jump(){
    if (!grounded) return;
    if (velocityY < 0) return;
    nextState = GameFight2DCharacterState.jump;
  }

  void update(){
     const gravity = 0.5;
     const runAcceleration = 0.5;
     const jumpAcceleration = 10.0;

     state = nextState;
     switch (state) {
       case GameFight2DCharacterState.idle:
         break;
       case GameFight2DCharacterState.runLeft:
         accelerationX -= runAcceleration;
         break;
       case GameFight2DCharacterState.runRight:
         accelerationX += runAcceleration;
         break;
       case GameFight2DCharacterState.jump:
         accelerationY -= jumpAcceleration;
         nextState = GameFight2DCharacterState.idle;
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
      writeInt16(character.x.toInt());
      writeInt16(character.y.toInt());
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

