import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/GameStatus.dart';
import 'common/ServerResponse.dart';

final _indexNpcMessage = ServerResponse.NpcMessage;
const _space = ' ';
const _semiColon = '; ';

void compileGameStatus(StringBuffer buffer, GameStatus gameStatus) {
  _write(buffer, ServerResponse.Game_Status);
  _write(buffer, gameStatus.index);
}

void compileCountDownFramesRemaining(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Lobby_CountDown);
  _write(buffer, game.countDownFramesRemaining);
}


// String compileEnvironmentObjects(List<EnvironmentObject> environmentObjects) {
//   final buffer = StringBuffer();
//   _write(buffer, ServerResponse.EnvironmentObjects);
//   for (final environmentObject in environmentObjects) {
//     if (environmentObject.type == ObjectType.Flag) continue;
//     _writeInt(buffer, environmentObject.x);
//     _writeInt(buffer, environmentObject.y);
//     _writeInt(buffer, environmentObject.radius);
//     _write(buffer, environmentObject.type.index);
//   }
//   _writeSemiColon(buffer);
//   return buffer.toString();
// }

// String compileTiles(List<List<int>> tiles) {
//   final buffer = StringBuffer();
//   buffer.write(ServerResponse.Tiles);
//   buffer.write(_space);
//   buffer.write(tiles.length);
//   buffer.write(_space);
//   buffer.write(tiles[0].length);
//   buffer.write(_space);
//   for (var x = 0; x < tiles.length; x++) {
//     for (var y = 0; y < tiles[0].length; y++) {
//       buffer.write(tiles[x][y]);
//       buffer.write(_space);
//     }
//   }
//   buffer.write(_semiColon);
//   return buffer.toString();
// }

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

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}

void compilePlayersRemaining(StringBuffer buffer, int remaining) {
  _write(buffer, ServerResponse.Waiting_For_More_Players);
  _write(buffer, remaining);
}

