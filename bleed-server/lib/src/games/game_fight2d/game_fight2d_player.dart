import 'game_fight2d.dart';
import 'game_fight2d_character.dart';

import 'package:bleed_server/common/src/fight2d/game_fight2d_events.dart';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/player.dart';

class GameFight2DPlayer extends Player with GameFight2DCharacter {

  late GameFight2D game;
  var editMode = false;

  /// constructor
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
    state = grounded
        ? GameFight2DCharacterState.Crouching
        : GameFight2DCharacterState.Fall_Fast;
  }

  void writeEventJump(int x, int y){
    writeEvent(event: GameFight2DEvents.Jump, x: x, y: y);
  }

  void writeEventPunch(int x, int y){
    writeEvent(event: GameFight2DEvents.Punch, x: x, y: y);
  }

  void writeEvent({required int event, required int x, required int y}){
    writeByte(ServerResponse.Fight2D);
    writeByte(Fight2DResponse.Event);
    writeByte(event);
    writeInt16(x);
    writeInt16(y);
  }
}