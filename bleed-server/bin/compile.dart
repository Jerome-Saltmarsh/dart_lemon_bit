import 'package:bleed_server/CubeGame.dart';
import 'package:lemon_math/Vector2.dart';

import 'classes/Crate.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Game.dart';
import 'classes/Item.dart';
import 'classes/Player.dart';
import 'classes/Weapon.dart';
import 'common/GameStatus.dart';
import 'common/ServerResponse.dart';
import 'common/Tile.dart';
import 'common/enums/ObjectType.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';

final _indexNpcMessage = ServerResponse.NpcMessage.index;
const _space = ' ';
const _semiColon = '; ';

void compilePlayerJoined(StringBuffer buffer, Player player) {
  _write(buffer,
      '${ServerResponse.Game_Joined.index} ${player.id} ${player.uuid} ${player
          .x.toInt()} ${player.y.toInt()} ${player.game.id} ${player.team} ');
}

void compileCrates(StringBuffer buffer, List<Crate> crates) {
  _write(buffer, ServerResponse.Crates.index);
  _write(buffer, crates.length);
  for (Crate crate in crates) {
    _writeVector2Int(buffer, crate);
  }
}

void compileItems(StringBuffer buffer, List<Item> items) {
  _write(buffer, ServerResponse.Items.index);
  _write(buffer, items.length);
  for (final item in items) {
    _write(buffer, item.type.index);
    _writeVector2Int(buffer, item);
  }
}

void compileTeamLivesRemaining(StringBuffer buffer, GameMoba moba) {
  _write(buffer, ServerResponse.Team_Lives_Remaining.index);
  _write(buffer, moba.teamLivesWest);
  _write(buffer, moba.teamLivesEast);
}

void compileGameStatus(StringBuffer buffer, GameStatus gameStatus) {
  _write(buffer, ServerResponse.Game_Status.index);
  _write(buffer, gameStatus.index);
}

void compileRoyal(StringBuffer buffer, GameRoyal royal){
  _write(buffer, ServerResponse.Game_Royal.index);
  _write(buffer, royal.boundaryCenter.x.toInt());
  _write(buffer, royal.boundaryCenter.y.toInt());
  _write(buffer, royal.boundaryRadius.toInt());
}

void compileCountDownFramesRemaining(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Lobby_CountDown.index);
  _write(buffer, game.countDownFramesRemaining);
}

void compileGameMeta(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Game_Meta.index);
  _write(buffer, game.teamSize);
  _write(buffer, game.numberOfTeams);
}

void compileLobby(StringBuffer buffer, Game game) {
  _write(buffer, ServerResponse.Lobby.index);
  _write(buffer, game.players.length);
  for (Player player in game.players) {
    _write(buffer, player.name);
    _write(buffer, player.team);
  }
}

String compileEnvironmentObjects(List<EnvironmentObject> environmentObjects) {
  final buffer = StringBuffer();
  _write(buffer, ServerResponse.EnvironmentObjects.index);
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

String compileTiles(List<List<Tile>> tiles) {
  final buffer = StringBuffer();
  buffer.write(ServerResponse.Tiles.index);
  buffer.write(_space);
  buffer.write(tiles.length);
  buffer.write(_space);
  buffer.write(tiles[0].length);
  buffer.write(_space);
  for (var x = 0; x < tiles.length; x++) {
    for (var y = 0; y < tiles[0].length; y++) {
      buffer.write(tiles[x][y].index);
      buffer.write(_space);
    }
  }
  buffer.write(_semiColon);
  return buffer.toString();
}

void compilePlayerWeapons(StringBuffer buffer, Player player) {
  _write(buffer, ServerResponse.Weapons.index);
}

void compileWeapon(StringBuffer buffer, Weapon weapon) {
  _write(buffer, weapon.type.index);
  _write(buffer, weapon.rounds);
  _write(buffer, weapon.capacity);
  _write(buffer, weapon.damage);
}

void compilePlayerOrbs(StringBuffer buffer, Player player) {
  _write(buffer, ServerResponse.Player_Orbs.index);
  _write(buffer, player.orbs.ruby);
  _write(buffer, player.orbs.topaz);
  _write(buffer, player.orbs.emerald);
}

void compilePlayerSlotTypes(StringBuffer buffer, Player player) {
  _write(buffer, ServerResponse.Player_Slot_Types.index);
  final slots = player.slots;
  _write(buffer, slots.slot1.index);
  _write(buffer, slots.slot2.index);
  _write(buffer, slots.slot3.index);
  _write(buffer, slots.slot4.index);
  _write(buffer, slots.slot5.index);
  _write(buffer, slots.slot6.index);
}

void compilePlayerWeaponValues(StringBuffer buffer, Player player){
  _write(buffer, ServerResponse.Player_Weapon.index);
}

void compileScore(StringBuffer buffer, List<Player> players) {
  _write(buffer, ServerResponse.Score.index);
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

void _writeVector2Int(StringBuffer buffer, Vector2 vector2){
  _writeInt(buffer, vector2.x);
  _writeInt(buffer, vector2.y);
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}

void compilePlayersRemaining(StringBuffer buffer, int remaining) {
  _write(buffer, ServerResponse.Waiting_For_More_Players.index);
  _write(buffer, remaining);
}

void compileCubePlayers(StringBuffer buffer, List<CubePlayer> cubePlayers) {
  _write(buffer, ServerResponse.Cube_Players.index);
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

