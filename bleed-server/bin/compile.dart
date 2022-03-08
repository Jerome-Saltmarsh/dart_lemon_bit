import 'package:bleed_server/CubeGame.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/angle.dart';

import 'bleed/zombie_health.dart';
import 'classes/Ability.dart';
import 'classes/Character.dart';
import 'classes/Crate.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Game.dart';
import 'classes/GameEvent.dart';
import 'classes/InteractableNpc.dart';
import 'classes/Item.dart';
import 'classes/Player.dart';
import 'classes/Projectile.dart';
import 'classes/Weapon.dart';
import 'common/AbilityType.dart';
import 'common/GameStatus.dart';
import 'common/ServerResponse.dart';
import 'common/Tile.dart';
import 'common/constants.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';

// constants
final _playersIndex = ServerResponse.Players.index;
final _playerIndex = ServerResponse.Player.index;
final _indexZombies = ServerResponse.Zombies.index;
final _indexNpcs = ServerResponse.Npcs.index;
final _indexBullets = ServerResponse.Bullets.index;
final _indexNpcMessage = ServerResponse.NpcMessage.index;

const _space = ' ';
const _semiColon = '; ';
const _comma = ', ';

final compile = _Compile();

class _Compile {

  final _gameBuffer = StringBuffer();

  void game(Game game) {
    _gameBuffer.clear();
    _compilePlayers(_gameBuffer, game.players);
    // _compileZombies(_gameBuffer, game.zombies);
    _compileInteractableNpcs(_gameBuffer, game.npcs);
    _compileProjectiles(_gameBuffer, game.projectiles);
    _compileGameEvents(_gameBuffer, game.gameEvents);

    _write(_gameBuffer, ServerResponse.Debug_Mode.index);
    _write(_gameBuffer, game.debugMode ? 1 : 0);

    _write(_gameBuffer, ServerResponse.Game_Time.index);
    _write(_gameBuffer, game.getTime());

    if (game.debugMode) {
      _compilePaths(_gameBuffer, game.zombies);
      _compileNpcDebug(_gameBuffer, game.npcs);
      _compileNpcDebug(_gameBuffer, game.zombies);
    }

    _write(_gameBuffer, ServerResponse.Scene_Shade_Max.index);
    _write(_gameBuffer, game.shadeMax);

    compileGameStatus(_gameBuffer, game.status);

    if (game is GameRoyal) {
      compileRoyal(_gameBuffer, game);
    }

    compileItems(_gameBuffer, game.items);
    compileCrates(_gameBuffer, game.crates);

    game.compiled = _gameBuffer.toString();
    /// GAME COMPILATION FINISHED

    game.compiledTeamText.clear();

    for (final player in game.players) {
      if (!game.compiledTeamText.containsKey(player.team)) {
        final buffer = StringBuffer();
        buffer.write(ServerResponse.Player_Text.index);
        buffer.write(_space);
        game.compiledTeamText[player.team] = buffer;
        buffer.write(_space);
      }
      game.compiledTeamText[player.team]?.write(player.x.toInt());
      _gameBuffer.write(_space);
      game.compiledTeamText[player.team]?.write(player.y.toInt());
      _gameBuffer.write(_space);
      game.compiledTeamText[player.team]?.write(player.text);
      _gameBuffer.write(_space);
      game.compiledTeamText[player.team]?.write(_comma);
      _gameBuffer.write(_space);
    }
  }
}

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
  // _write(buffer, player.weapons.length);
  // for (final weapon in player.weapons) {
  //   compileWeapon(buffer, weapon);
  // }
}

void compileWeapon(StringBuffer buffer, Weapon weapon) {
  _write(buffer, weapon.type.index);
  _write(buffer, weapon.rounds);
  _write(buffer, weapon.capacity);
  _write(buffer, weapon.damage);
}

void _compileAbility(StringBuffer buffer, Ability ability) {
  _write(buffer, ability.type.index);
  _write(buffer, ability.level);
  _write(buffer, ability.cooldown);
  _write(buffer, ability.cooldownRemaining);
  _write(buffer, ability.cost);
}

void compilePlayer(StringBuffer buffer, Player player) {
  _write(buffer, _playerIndex);
  _writeInt(buffer, player.x);
  _writeInt(buffer, player.y);
  _write(buffer, player.health);
  _write(buffer, player.maxHealth);
  _write(buffer, player.state.index);
  _write(buffer, player.experience);
  _write(buffer, player.level);
  _write(buffer, player.abilityPoints);
  final experienceRequired = levelExperience[player.level];
  _write(buffer, experienceRequired);
  final perc = player.experience / experienceRequired * 100;
  _writeInt(buffer, perc); // todo make sure player is not max level
  _write(buffer, player.type.index);
  _writeInt(buffer, player.abilityTarget.x);
  _writeInt(buffer, player.abilityTarget.y);
  _write(buffer, player.magic);
  _write(buffer, player.maxMagic);
  _writeInt(buffer, player.attackRange);
  _write(buffer, player.team);
  _write(buffer, player.weapon.index);
  _write(buffer, player.slots.armour.index);
  _write(buffer, player.slots.helm.index);


  final aimTarget = player.aimTarget;
  if (aimTarget != null && aimTarget.alive) {
    _write(buffer, ServerResponse.Player_Attack_Target.index);
    _writeInt(buffer, aimTarget.x);
    _writeInt(buffer, aimTarget.y);
  } else {
    _write(buffer, ServerResponse.Player_Attack_Target.index);
    _writeInt(buffer, 0);
    _writeInt(buffer, 0);
  }

  compilePlayerOrbs(buffer, player);
  compilePlayerSlotTypes(buffer, player);
  _compilePlayerAbility(buffer, player);
  _compilePlayerEvents(buffer, player);

  if (player.gemSpawns.isNotEmpty) {
     _write(buffer, ServerResponse.Gem_Spawns.index);
     _write(buffer, player.gemSpawns.length);
     for(final gemSpawn in player.gemSpawns){
       _write(buffer, gemSpawn.type.index);
       _write(buffer, gemSpawn.x.toInt());
       _write(buffer, gemSpawn.y.toInt());
     }
     player.gemSpawns.clear();
  }
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

void _compilePlayerAbility(StringBuffer buffer, Player player){
  _write(buffer, ServerResponse.Player_Ability.index);
  final ability = player.ability;
  if (ability != null) {
    _write(buffer, ability.type.index);
    _write(buffer, ability.range);
    _write(buffer, ability.radius);
  } else {
    _write(buffer, AbilityType.None.index);
    _write(buffer, 0);
    _write(buffer, 0);
  }
}

void compilePlayerWeaponValues(StringBuffer buffer, Player player){
  _write(buffer, ServerResponse.Player_Weapon.index);
  // _write(buffer, player.weapon.type.index);
  // _write(buffer, player.weapon.rounds);
  // _write(buffer, player.weapon.capacity);
}

void _compilePlayerEvents(StringBuffer buffer, Player player) {
  if (player.events.isEmpty) return;
  _write(buffer, ServerResponse.Player_Events.index);
  _write(buffer, player.events.length);
  for (final event in player.events) {
    _write(buffer, event.index);
  }
  player.events.clear();
}

void compileScore(StringBuffer buffer, List<Player> players) {
  _write(buffer, ServerResponse.Score.index);
  for (final player in players) {
    _write(buffer, player.name);
    _write(buffer, player.pointsRecord);
  }
  _write(buffer, _semiColon);
}

void _compileGameEvents(StringBuffer buffer, List<GameEvent> gameEvents) {
  _write(buffer, ServerResponse.Game_Events.index);
  for (final gameEvent in gameEvents) {
    if (gameEvent.frameDuration <= 0) continue;
    _write(buffer, gameEvent.id);
    _write(buffer, gameEvent.type.index);
    _writeInt(buffer, gameEvent.x);
    _writeInt(buffer, gameEvent.y);
    _write(buffer, gameEvent.angle.toStringAsFixed(1));
  }
  buffer.write(_semiColon);
}

void _compilePaths(StringBuffer buffer, List<Character> characters) {
  _write(buffer, ServerResponse.Paths.index);
  for (final character in characters) {
    final ai = character.ai;
    if (ai == null) continue;
    if (ai.pathIndex < 0) continue;
    for (int i = ai.pathIndex; i >= 0; i--) {
      _writeInt(buffer, ai.pathX[i]);
      _writeInt(buffer, ai.pathY[i]);
    }
    _write(buffer, _comma);
  }
  buffer.write(_semiColon);
}

void _compileNpcDebug(StringBuffer buffer, List<Character> characters) {
  _write(buffer, ServerResponse.NpcsDebug.index);
  for (final character in characters) {
    final ai = character.ai;
    if (ai == null) continue;
    final target = ai.target;
    if (target == null) continue;
    _writeInt(buffer, character.x);
    _writeInt(buffer, character.y);
    _writeInt(buffer, target.x);
    _writeInt(buffer, target.y);
  }
  buffer.write(_semiColon);
}

void _compilePlayers(StringBuffer buffer, List<Player> players) {
  _write(buffer, _playersIndex);
  _write(buffer, players.length);
  for (final player in players) {
    _compilePlayer(buffer, player);
  }
}

void _compileZombies(StringBuffer buffer, List<Character> characters) {
  _write(buffer, _indexZombies);
  var total = 0;
  for (final character in characters) {
    if (character.active) total++;
  }
  _write(buffer, total);
  for (final character in characters) {
    if (!character.active) continue;
    _compileNpc(buffer, character);
  }
}

void _compileInteractableNpcs(StringBuffer buffer, List<InteractableNpc> npcs) {
  _write(buffer, _indexNpcs);
  for (final npc in npcs) {
    if (!npc.active) continue;
    _compileInteractableNpc(buffer, npc);
  }
  buffer.write(_semiColon);
}

void _compileProjectiles(StringBuffer buffer, List<Projectile> projectiles) {
  _write(buffer, _indexBullets);
  for (final projectile in projectiles) {
    if (!projectile.active) continue;
    _compileProjectile(buffer, projectile);
  }
  buffer.write(_semiColon);
}

void _compileProjectile(StringBuffer buffer, Projectile projectile) {
  _write(buffer, projectile.x.toInt());
  _write(buffer, projectile.y.toInt());
  _write(buffer, projectile.type.index);
  final degrees = angle(projectile.xv, projectile.yv) * radiansToDegrees;
  _write(buffer, degrees.toInt());
}

void _compilePlayer(StringBuffer buffer, Player player) {
  _write(buffer, player.type.index);
  _write(buffer, player.state.index);
  _write(buffer, player.direction);
  _writeInt(buffer, player.x);
  _writeInt(buffer, player.y);
  _write(buffer, player.animationFrame);
  _write(buffer, player.team);
  _write(buffer, player.name);
  _writeInt(buffer, (player.health / player.maxHealth) * 100);
  _writeInt(buffer, (player.magic / player.maxMagic) * 100);
  _write(buffer, player.weapon.index);
  _write(buffer, player.slots.armour.index);
  _write(buffer, player.slots.helm.index);
}

void _compileNpc(StringBuffer buffer, Character character) {
  _write(buffer, character.state.index);
  _write(buffer, character.direction);
  _writeInt(buffer, character.x);
  _writeInt(buffer, character.y);
  _write(buffer, character.animationFrame);
  _writeInt(buffer, (character.health / character.maxHealth) * 100);
  _write(buffer, character.team);
}

void _compileInteractableNpc(StringBuffer buffer, InteractableNpc npc) {
  _write(buffer, npc.state.index);
  _write(buffer, npc.direction);
  _writeInt(buffer, npc.x);
  _writeInt(buffer, npc.y);
  _write(buffer, npc.animationFrame);
  _write(buffer, npc.weapon.index);
  _write(buffer, npc.name);
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

