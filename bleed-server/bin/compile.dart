import 'classes.dart';
import 'classes/Block.dart';
import 'classes/Game.dart';
import 'enums.dart';
import 'enums/ServerResponse.dart';
import 'settings.dart';

const String _space = ' ';
const String _semiColon = '; ';

void compileState(Game game) {
  game.buffer.clear();
  _compileGameId(game.buffer, game);
  _compilePlayers(game.buffer, game.players);
  _compileNpcs(game.buffer, game.npcs);
  _compileBullets(game.buffer, game.bullets);
  _compileGameEvents(game.buffer, game.gameEvents);
  _compileGrenades(game.buffer, game.grenades);
  _compileObjects(game.buffer, game.objects);
  game.compiled = game.buffer.toString();
}

void _compileGameEvents(StringBuffer buffer, List<GameEvent> gameEvents) {
  buffer.write(ServerResponse.Game_Events.index);
  buffer.write(_space);
  for (GameEvent gameEvent in gameEvents) {
    _write(buffer, gameEvent.id);
    _write(buffer, gameEvent.type.index);
    _write(buffer, gameEvent.x.toInt());
    _write(buffer, gameEvent.y.toInt());
    _write(buffer, gameEvent.xv.toStringAsFixed(1));
    _write(buffer, gameEvent.yv.toStringAsFixed(1));
  }
  buffer.write(_semiColon);
}

void compileBlocks(StringBuffer buffer, List<Block> blocks){
  buffer.write(ServerResponse.Blocks.index);
  buffer.write(_space);
  for(Block block in blocks){
    _write(buffer, block.x.toInt());
    _write(buffer, block.y.toInt());
    _write(buffer, block.width.toInt());
    _write(buffer, block.height.toInt());
  }
  buffer.write(_semiColon);
}

void _compileGrenades(StringBuffer buffer, List<Grenade> grenades){
  buffer.write(ServerResponse.Grenades.index);
  buffer.write(_space);
  for(Grenade grenade in grenades){
    _write(buffer, grenade.x.toInt());
    _write(buffer, grenade.y.toInt());
    _write(buffer, grenade.z.toStringAsFixed(1));
  }
  buffer.write(_semiColon);
}

void _compileObjects(StringBuffer buffer, List<GameObject> objects){
  buffer.write(ServerResponse.Objects.index);
  buffer.write(_space);
  for(GameObject object in objects){
    _write(buffer, object.x.toInt());
    _write(buffer, object.y.toInt());
  }
  buffer.write(_semiColon);
}

String compileTiles(StringBuffer buffer, List<List<Tile>> tiles) {
  buffer.write(ServerResponse.Tiles.index);
  buffer.write(_space);
  buffer.write(tiles.length);
  buffer.write(_space);
  buffer.write(tiles[0].length);
  buffer.write(_space);
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      buffer.write(tiles[x][y].index);
      buffer.write(_space);
    }
  }
  buffer.write(_semiColon);
  return buffer.toString();
}

void compilePlayer(StringBuffer buffer, Player player) {
  buffer.write(ServerResponse.Player.index);
  buffer.write(_space);
  buffer.write(player.x.toStringAsFixed(1));
  buffer.write(_space);
  buffer.write(player.y.toStringAsFixed(1));
  buffer.write(_space);
  buffer.write(player.weapon.index);
  buffer.write(_space);
  buffer.write(player.health.toStringAsFixed(2));
  buffer.write(_space);
  buffer.write(player.maxHealth.toStringAsFixed(2));
  buffer.write(_space);
  buffer.write(player.stamina);
  buffer.write(_space);
  buffer.write(player.maxStamina);
  buffer.write(_space);
  buffer.write(player.handgunAmmunition.clips);
  buffer.write(_space);
  buffer.write(player.handgunAmmunition.clipSize);
  buffer.write(_space);
  buffer.write(player.handgunAmmunition.maxClips);
  buffer.write(_space);
  buffer.write(player.handgunAmmunition.rounds);
  buffer.write(_space);
  buffer.write(_semiColon);
}

void _compilePlayers(StringBuffer buffer, List<Player> players) {
  buffer.write(ServerResponse.Players.index);
  buffer.write(_space);
  players.forEach((player) => _compileCharacter(buffer, player));
  buffer.write(_semiColon);
}

void _compileGameId(StringBuffer buffer, Game game){
  _write(game.buffer, '${ServerResponse.Game_Id.index} ${game.id} ;');
}

void _compileNpcs(StringBuffer buffer, List<Npc> npcs) {
  buffer.write(ServerResponse.Npcs.index);
  buffer.write(_space);
  npcs.forEach((npc) => _compileNpc(buffer, npc));
  buffer.write(_semiColon);
}

void _compileBullets(StringBuffer buffer, List<Bullet> bullets) {
  buffer.write(ServerResponse.Bullets.index);
  buffer.write(_space);
  bullets.forEach((bullet) => _compileBullet(buffer, bullet));
  buffer.write(_semiColon);
}

void _compileBullet(StringBuffer buffer, Bullet bullet) {
  _write(buffer, bullet.id);
  _write(buffer, bullet.x);
  _write(buffer, bullet.y);
}

void _compileCharacter(StringBuffer buffer, Character character) {
  _write(buffer, character.state.index);
  _write(buffer, character.direction.index);
  _write(buffer, character.x.toInt());
  _write(buffer, character.y.toInt());
  _write(buffer, character.id);
  _write(buffer, character.weapon.index);
}

void _compileNpc(StringBuffer buffer, Npc npc) {
  _write(buffer, npc.state.index);
  _write(buffer, npc.direction.index);
  _write(buffer, npc.x.toStringAsFixed(compilePositionDecimals));
  _write(buffer, npc.y.toStringAsFixed(compilePositionDecimals));
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}
