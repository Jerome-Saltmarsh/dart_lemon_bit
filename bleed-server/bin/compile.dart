import 'package:bleed_server/CubeGame.dart';

import 'classes/EnvironmentObject.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/GameStatus.dart';
import 'common/ServerResponse.dart';
import 'common/ObjectType.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';

final _indexNpcMessage = ServerResponse.NpcMessage;
const _space = ' ';
const _semiColon = '; ';

void compileTeamLivesRemaining(StringBuffer buffer, GameMoba moba) {
  _write(buffer, ServerResponse.Team_Lives_Remaining);
  _write(buffer, moba.teamLivesWest);
  _write(buffer, moba.teamLivesEast);
}

void compileGameStatus(StringBuffer buffer, GameStatus gameStatus) {
  _write(buffer, ServerResponse.Game_Status);
  _write(buffer, gameStatus.index);
}

void compileRoyal(StringBuffer buffer, GameRoyal royal){
  _write(buffer, ServerResponse.Game_Royal);
  _write(buffer, royal.boundaryCenter.x.toInt());
  _write(buffer, royal.boundaryCenter.y.toInt());
  _write(buffer, royal.boundaryRadius.toInt());
}

void compileCountDownFramesRemaining(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Lobby_CountDown);
  _write(buffer, game.countDownFramesRemaining);
}

void compileGameMeta(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Game_Meta);
  _write(buffer, game.teamSize);
  _write(buffer, game.numberOfTeams);
}

void compileLobby(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Lobby);
  _write(buffer, game.players.length);
  for (Player player in game.players) {
    _write(buffer, player.name);
    _write(buffer, player.team);
  }
}

String compileEnvironmentObjects(List<EnvironmentObject> environmentObjects) {
  final buffer = StringBuffer();
  _write(buffer, ServerResponse.EnvironmentObjects);
  for (final environmentObject in environmentObjects) {
    if (environmentObject.type == ObjectType.Flag) continue;
    _writeInt(buffer, environmentObject.x);
    _writeInt(buffer, environmentObject.y);
    _writeInt(buffer, environmentObject.radius);
    _write(buffer, environmentObject.type.index);
  }
  _writeSemiColon(buffer);
  return buffer.toString();
}

String compileTiles(List<List<int>> tiles) {
  final buffer = StringBuffer();
  buffer.write(ServerResponse.Tiles);
  buffer.write(_space);
  buffer.write(tiles.length);
  buffer.write(_space);
  buffer.write(tiles[0].length);
  buffer.write(_space);
  for (var x = 0; x < tiles.length; x++) {
    for (var y = 0; y < tiles[0].length; y++) {
      buffer.write(tiles[x][y]);
      buffer.write(_space);
    }
  }
  buffer.write(_semiColon);
  return buffer.toString();
}

void compilePlayerWeapons(StringBuffer buffer, Player player) {
  _write(buffer, ServerResponse.Weapons);
}

void compilePlayerWeaponValues(StringBuffer buffer, Player player){
  _write(buffer, ServerResponse.Player_Weapon);
}

void compileScore(StringBuffer buffer, List<Player> players) {
  _write(buffer, ServerResponse.Score);
  for (final player in players) {
    _write(buffer, player.name);
    _write(buffer, player.pointsRecord);
  }
  _write(buffer, _semiColon);
}

void compilePlayerMessage(StringBuffer buffer, String message) {
  _write(buffer, _indexNpcMessage);
  _write(buffer, message);
  _writeSemiColon(buffer);
}

void _writeSemiColon(StringBuffer buffer) {
  _write(buffer, _semiColon);
}

void _writeInt(StringBuffer buffer, double value) {
  _write(buffer, value.toInt());
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}

void compilePlayersRemaining(StringBuffer buffer, int remaining) {
  _write(buffer, ServerResponse.Waiting_For_More_Players);
  _write(buffer, remaining);
}

void compileCubePlayers(StringBuffer buffer, List<CubePlayer> cubePlayers) {
  _write(buffer, ServerResponse.Cube_Players);
  _write(buffer, cubePlayers.length);
  for (CubePlayer player in cubePlayers) {
    writeVector3(buffer, player.position);
    writeVector3(buffer, player.rotation);
  }
}

void writeVector3(StringBuffer buffer, Vector3 value) {
  _writeInt(buffer, value.x);
  _writeInt(buffer, value.y);
  _writeInt(buffer, value.z);
}

