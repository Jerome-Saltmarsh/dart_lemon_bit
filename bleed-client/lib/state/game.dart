import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

final _Game game = _Game();

class _Game {
  int lag = 0;
  final Map<int, bool> gameEvents = Map();
  final Watch<int> countDownFramesRemaining = Watch(0);
  final Watch<int> numberOfPlayersNeeded = Watch(0);
  final List<Effect> effects = [];
  final _Settings settings = _Settings();
  final Watch<int> teamLivesWest = Watch(-1);
  final Watch<int> teamLivesEast = Watch(-1);
  final Watch<GameType> type = Watch(GameType.None);
  String? customGameName = "";
  final _Lobby lobby = _Lobby();
  final Watch<int> teamSize = Watch(0);
  final Watch<int> numberOfTeams = Watch(0);
  List<int> collectables = [];
  List<Vector2> crates = [];
  int cratesTotal = 0;
  List<EnvironmentObject> torches = [];
  List<NpcDebug> npcDebug = [];
  final List<Character> humans = [];
  final List<Character> zombies = [];
  final List<Character> interactableNpcs = [];
  final Watch<int> totalZombies = Watch(0);
  int totalNpcs = 0;
  int totalHumans = 0;
  int totalCubes = 0;
  List<Projectile> projectiles = [];
  List<Vector2> bulletHoles = [];
  int bulletHoleIndex = 0;
  List<double> grenades = [];
  int id = -1;
  int totalProjectiles = 0;
  int itemsTotal = 0;

  final _Royal royal = _Royal();

  // properties
  String get session => modules.game.state.player.uuid.value;
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
  int maxBulletHoles = 50;
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

