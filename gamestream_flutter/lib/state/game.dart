import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:bleed_common/GameType.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

final game = _Game();

class _Game {
  final Map<int, bool> gameEvents = Map();
  final settings = _Settings();
  final type = Watch<GameType>(GameType.None);
  final lobby = _Lobby();
  final countDownFramesRemaining = Watch<int>(0);
  final numberOfPlayersNeeded = Watch<int>(0);
  final teamLivesWest = Watch<int>(-1);
  final teamLivesEast = Watch<int>(-1);
  final teamSize = Watch<int>(0);
  final numberOfTeams = Watch<int>(0);
  final totalZombies = Watch<int>(0);
  final royal = _Royal();
  final List<Character> players = [];
  final List<Character> zombies = [];
  final List<Character> interactableNpcs = [];
  final List<Effect> effects = [];
  int lag = 0;
  String? customGameName = "";
  List<int> collectables = [];
  List<Vector2> crates = [];
  int cratesTotal = 0;
  List<EnvironmentObject> torches = [];
  List<NpcDebug> npcDebug = [];
  int totalNpcs = 0;
  int totalPlayers = 0;
  int totalCubes = 0;
  List<Projectile> projectiles = [];
  List<Vector2> bulletHoles = [];
  int bulletHoleIndex = 0;
  List<double> grenades = [];
  int id = -1;
  int totalProjectiles = 0;
  int itemsTotal = 0;
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

class _Settings {
  double zoomFollowSpeed = 0.1;
  double zoomSpeed = 0.0005;
  double maxZoom = 0.1;
  int floatingTextDuration = 100;
  final maxBulletHoles = 50;
  int maxParticlesMinusOne = 299;
  double interactRadius = 60;
  double manRenderSize = 40.0;
}

class _LobbyPlayer {
  String name;
  int team;
  bool notSet = true;

  _LobbyPlayer(this.name, this.team);
}

mixin Position {
  double x = 0;
  double y = 0;
}

