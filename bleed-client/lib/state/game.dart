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
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

final _Game game = _Game();

class _Game {
  final List<Explosion> explosions = [];
  final _Settings settings = _Settings();
  final _Player player = _Player();
  int serverVersion;
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
}

class _Player {
  int id = -1;
  String uuid = "";
  double x = -1;
  double y = -1;
  final Watch<WeaponType> weapon = Watch(WeaponType.Unarmed);
  final List<Weapon> weapons = [];
  final Watch<int> equippedRounds = Watch(0);
  final Watch<int> equippedCapacity = Watch(0);
  Vector2 abilityTarget = Vector2(0, 0);
  double abilityRange = 0;
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  int squad = -1;
  Watch<double> health = Watch(0.0);
  double maxHealth = 0;
  Tile tile = Tile.Grass;
  Watch<int> experience = Watch(0);
  Watch<int> level = Watch(1);
  Watch<int> skillPoints = Watch(1);
  Watch<int> nextLevelExperience = Watch(1);
  Watch<int> experiencePercentage = Watch(1);
  int grenades = 0;
  Watch<String> message = Watch("");
  Watch<CharacterState> state = Watch(CharacterState.Idle);
  Watch<bool> alive = Watch(true);
  final _Unlocked unlocked = _Unlocked();
  final Watch<AbilityType> ability = Watch(AbilityType.None);

  final Watch<int> magic = Watch(0);
  final Watch<int> maxMagic = Watch(0);

  Ability ability1 = Ability();
  Ability ability2 = Ability();
  Ability ability3 = Ability();
  Ability ability4 = Ability();

  bool get dead => !alive.value;

  // bool get canPurchase => tile == Tile.PlayerSpawn;
  bool get canPurchase => false;

  double attackRange = 0;

  Vector2 attackTarget = Vector2(0, 0);
}

class _Unlocked {
  bool get handgun => game.player.weaponUnlocked(WeaponType.HandGun);

  bool get shotgun => game.player.weaponUnlocked(WeaponType.Shotgun);

  bool get firebolt => game.player.weaponUnlocked(WeaponType.Firebolt);
}

// Skill Tree
// Handguns do 10% more damage
// Handguns are 10% more accurate
// Handguns are 10% more accurate

// Wizard
// Firebolt

// Bowman
// Magic Arrow

//

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

void toggleAudio() {
  game.settings.audioMuted.value = !game.settings.audioMuted.value;
}

class _Settings {
  Watch<bool> audioMuted = Watch(false);
  double cameraFollowSpeed = 0.04;
  double zoomFollowSpeed = 0.1;
  double zoomSpeed = 0.0005;
  double maxZoom = 0.1;
  bool developMode = true;
  bool compilePaths = false;
  int floatingTextDuration = 100;
  int maxBulletHoles = 50;
  int maxParticlesMinusOne = 299;
  double interactRadius = 60;
  double manRenderSize = 40.0;
}
