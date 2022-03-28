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
  final type = Watch(GameType.None);
  final lobby = _Lobby();
  final countDownFramesRemaining = Watch(0);
  final numberOfPlayersNeeded = Watch(0);
  final teamLivesWest = Watch(-1);
  final teamLivesEast = Watch(-1);
  final teamSize = Watch(0);
  final numberOfTeams = Watch(0);
  final totalZombies = Watch(0);
  final totalPlayers = Watch(0);
  final royal = _Royal();
  final players = <Character>[];
  final zombies = <Character>[];
  final interactableNpcs = <Character>[];
  final effects = <Effect>[];
  var torches = <EnvironmentObject>[];
  var projectiles = <Projectile>[];
  var collectables = <int>[];
  var crates = <Vector2>[];
  var customGameName = "";
  var cratesTotal = 0;
  var npcDebug = <NpcDebug>[];
  var totalNpcs = 0;
  var totalCubes = 0;
  var bulletHoles = <Vector2>[];
  var bulletHoleIndex = 0;
  var id = -1;
  var totalProjectiles = 0;
  var itemsTotal = 0;
}

class _Royal {
  double radius = 0;
  Vector2 mapCenter = Vector2(0, 0);
}

class _Lobby {
  final Watch<int> playerCount = Watch(0);
  final List<_LobbyPlayer> players = [];

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

