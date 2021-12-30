import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:lemon_watch/watch.dart';

final _Game game = _Game();

_Player get player => game.player;

class _Game {
  final Watch<Mode> mode = Watch(Mode.Play);
  final Watch<Region> region = Watch(Region.None);
  final Watch<int> numberOfPlayersNeeded = Watch(0);
  final List<Effect> effects = [];
  final _Settings settings = _Settings();
  final _Player player = _Player();
  final Watch<int> teamLivesWest = Watch(-1);
  final Watch<int> teamLivesEast = Watch(-1);
  final Watch<GameType> type = Watch(GameType.None);
  final Watch<GameStatus> status = Watch(GameStatus.Awaiting_Players);
  final _Lobby lobby = _Lobby();
  final Watch<int> teamSize = Watch(0);
  final Watch<int> numberOfTeams = Watch(0);
  List<int> collectables = [];
  List<Vector2> crates = [];
  int cratesTotal = 0;
  List<EnvironmentObject> environmentObjects = [];
  List<EnvironmentObject> torches = [];
  List<List<Tile>> tiles = [];
  int totalColumns = 0;
  int totalRows = 0;
  List<NpcDebug> npcDebug = [];
  final Watch<Shade> shadeMax = Watch(Shade.Bright);
  final List<Character> humans = [];
  final List<Zombie> zombies = [];
  final List<Character> interactableNpcs = [];
  final Watch<int> totalZombies = Watch(0);
  int totalNpcs = 0;
  int totalHumans = 0;
  int totalCubes = 0;
  List<Projectile> projectiles = [];
  List<Vector2> bulletHoles = [];
  int totalSprites = 0;
  int bulletHoleIndex = 0;
  List<Particle> particles = [];
  List<ParticleEmitter> particleEmitters = [];
  List<double> grenades = [];
  int id = -1;
  int totalProjectiles = 0;
  List<Item> items = [];
  int totalItems = 0;

  final _Royal royal = _Royal();

  // properties
  String get session => player.uuid.value;
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

class _Player {
  int id = -1;
  double x = -1;
  double y = -1;
  final Watch<String> uuid = Watch("");
  final Watch<WeaponType> weaponType = Watch(WeaponType.Unarmed);
  final List<Weapon> weapons = [];
  final Watch<int> weaponRounds = Watch(0);
  final Watch<int> equippedCapacity = Watch(0);
  Vector2 abilityTarget = Vector2(0, 0);
  double abilityRange = 0;
  double abilityRadius = 0;
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  int squad = -1;
  Watch<double> health = Watch(0.0);
  double maxHealth = 0;
  Tile tile = Tile.Grass;
  Watch<int> experience = Watch(0);
  Watch<int> level = Watch(1);
  Watch<int> skillPoints = Watch(1);
  Watch<int> nextLevelExperience = Watch(1);
  Watch<double> experiencePercentage = Watch(0);
  Watch<String> message = Watch("");
  Watch<CharacterState> state = Watch(CharacterState.Idle);
  Watch<bool> alive = Watch(true);
  final _Unlocked unlocked = _Unlocked();
  final Watch<AbilityType> ability = Watch(AbilityType.None);

  final Watch<double> magic = Watch(0);
  final Watch<double> maxMagic = Watch(0);

  final Ability ability1 = Ability(1);
  final Ability ability2 = Ability(2);
  final Ability ability3 = Ability(3);
  final Ability ability4 = Ability(4);

  _Player() {
    magic.onChanged((double value) {
      ability1.canAfford.value = value >= ability1.magicCost.value;
      ability2.canAfford.value = value >= ability2.magicCost.value;
      ability3.canAfford.value = value >= ability3.magicCost.value;
      ability4.canAfford.value = value >= ability4.magicCost.value;
    });

    ability.onChanged((AbilityType abilityType) {
      ability1.selected.value = ability1.type.value == abilityType;
      ability2.selected.value = ability2.type.value == abilityType;
      ability3.selected.value = ability3.type.value == abilityType;
      ability4.selected.value = ability4.type.value == abilityType;
    });
  }

  bool get dead => !alive.value;

  // bool get canPurchase => tile == Tile.PlayerSpawn;
  bool get canPurchase => false;

  double attackRange = 0;
  int team = 0;
  bool get isHuman => characterType.value == CharacterType.Human;
  Vector2 attackTarget = Vector2(0, 0);
}

class _Unlocked {
  bool get handgun => game.player.weaponUnlocked(WeaponType.HandGun);

  bool get shotgun => game.player.weaponUnlocked(WeaponType.Shotgun);
}

extension PlayerExtentions on _Player {
  bool weaponUnlocked(WeaponType weaponType) {
    for (Weapon weapon in weapons) {
      if (weapon.type == weaponType) return true;
    }
    return false;
  }

  bool get shotgunUnlocked {
    for (Weapon weapon in weapons) {
      if (weapon.type == WeaponType.Shotgun) return true;
    }
    return false;
  }
}



class _Settings {
  Watch<bool> audioMuted = Watch(false);
  double cameraFollowSpeed = 0.04;
  double zoomFollowSpeed = 0.1;
  double zoomSpeed = 0.0005;
  double maxZoom = 0.1;
  bool compilePaths = false;
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