
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:lemon_math/functions/random_between.dart';

class GameFight2D extends Game<GameFight2DPlayer> {
  final List<GameFight2DCharacter> characters = [];

  GameFight2D() : super(gameType: GameType.Fight2D);

  @override
  GameFight2DPlayer createPlayer() {
    final player = GameFight2DPlayer(this);
    player.x = randomBetween(-100, 100);
    player.y = randomBetween(-100, 100);
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
     switch (direction){
       case InputDirection.Right:
         player.nextState = GameFight2DCharacterState.runRight;
         break;
       case InputDirection.Left:
         player.nextState = GameFight2DCharacterState.runLeft;
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
  var applyGravity = false;

  static const frictionFloor = 0.9;

  void update(){
     const gravity = 0.1;
     const runAcceleration = 0.5;
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

     }
     if (applyGravity) {
       accelerationY += gravity;
     }

     velocityX += accelerationX;
     velocityY += accelerationY;
     accelerationX = 0;
     accelerationY = 0;
     x += velocityX;
     y += velocityY;
     velocityX *= frictionFloor;
  }
}

class GameFight2DPlayer extends Player with GameFight2DCharacter {

  late GameFight2D game;

  GameFight2DPlayer(this.game);

  @override
  void writePlayerGame() {
    writeCharacters();
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
}