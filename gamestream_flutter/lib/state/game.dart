import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

final game = _Game();

class _Game {
  final gameEvents = Map<int, bool>();
  final lobby = _Lobby();
  final royal = _Royal();
  final type = Watch(GameType.None);
  final countDownFramesRemaining = Watch(0);
  final numberOfPlayersNeeded = Watch(0);
  final teamLivesWest = Watch(-1);
  final teamLivesEast = Watch(-1);
  final teamSize = Watch(0);
  final numberOfTeams = Watch(0);
  final totalZombies = Watch(0);
  final totalPlayers = Watch(0);
  final players = <Character>[];
  final zombies = <Character>[];
  final interactableNpcs = <Character>[];
  final effects = <Effect>[];
  final torches = <EnvironmentObject>[];
  final projectiles = <Projectile>[];
  final collectables = <int>[];
  final crates = <Vector2>[];
  final bulletHoles = <Vector2>[];
  final npcDebug = <NpcDebug>[];
  var customGameName = "";
  var cratesTotal = 0;
  var totalNpcs = 0;
  var totalCubes = 0;
  var bulletHoleIndex = 0;
  var id = -1;
  var totalProjectiles = 0;
  var itemsTotal = 0;
}

class _Royal {
  var radius = 0.0;
  var mapCenter = Vector2(0, 0);
}

class _Lobby {
  final playerCount = Watch(0);
  final players = <_LobbyPlayer>[];

  void add({
    required int team,
    required String name
  }) {
    if (team == 0) {
      players.insert(0, _LobbyPlayer(name, team));
    } else {
      players.add(_LobbyPlayer(name, team));
    }
  }

  List<_LobbyPlayer> getPlayersOnTeam(int team) {
    return players.where((element) => element.team == team).toList();
  }
}

class _LobbyPlayer {
  String name;
  int team;
  bool notSet = true;

  _LobbyPlayer(this.name, this.team);
}

