import 'package:bleed_server/common/src/fight2d/game_fight2d_events.dart';
import 'package:bleed_server/common/src/fight2d/game_fight2d_response.dart';
import 'package:bleed_server/common/src/server_response.dart';

import 'game_fight2d.dart';
import 'game_fight2d_bot.dart';
import 'game_fight2d_character.dart';

import 'package:bleed_server/src/game/player.dart';



class GameFight2DPlayer extends Player with GameFight2DCharacter {

  late GameFight2D game;
  var _edit = false;

  /// constructor
  GameFight2DPlayer(this.game);

  bool get edit => _edit;

  set edit(bool value){
    if (_edit == value) return;
    _edit = value;
    writePlayerEdit();
  }

  @override
  void writePlayerGame() {
    writeCharacters();
    writePlayer();
  }

  void writePlayer() {
    writeByte(ServerResponse.Fight2D);
    writeByte(GameFight2DResponse.Player);
    writeCharacter(this);
  }

  void writePlayerEdit() {
    writeByte(ServerResponse.Fight2D);
    writeByte(GameFight2DResponse.Player_Edit);
    writeBool(edit);
  }

  void writeCharacters() {
    writeByte(ServerResponse.Fight2D);
    writeByte(GameFight2DResponse.Characters);
    writeUInt16(game.characters.length);
    for (final character in game.characters) {
      writeByte(character.state);
      writeByte(character.direction);
      writeBool(character is GameFight2DBot);
      writeUInt16(character.damage);
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
    writeByte(GameFight2DResponse.Scene);
    writeUInt16(scene.width);
    writeUInt16(scene.height);
    writeBytes(scene.tiles);
  }

  void crouch() {
    state = grounded
        ? GameFight2DCharacterState.Crouching
        : GameFight2DCharacterState.Fall_Fast;
  }

  void rollLeft(){
    if (!grounded) return;
    faceLeft();
    state = GameFight2DCharacterState.Rolling;
  }

  void rollRight(){
    if (!grounded) return;
    faceRight();
    state = GameFight2DCharacterState.Rolling;
  }

  void writeEventJump(int x, int y){
    writeEvent(event: GameFight2DEvents.Jump, x: x, y: y);
  }

  void writeEventPunch(int x, int y){
    writeEvent(event: GameFight2DEvents.Punch, x: x, y: y);
  }

  void writeEvent({required int event, required int x, required int y}){
    writeByte(ServerResponse.Fight2D);
    writeByte(GameFight2DResponse.Event);
    writeByte(event);
    writeInt16(x);
    writeInt16(y);
  }
}