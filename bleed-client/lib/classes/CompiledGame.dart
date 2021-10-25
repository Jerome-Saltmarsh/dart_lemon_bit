
import 'dart:ui';

import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/classes/Sprite.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/Weapons.dart';

import '../enums.dart';
import 'EnvironmentObject.dart';
import 'Human.dart';
import 'InteractableNpc.dart';
import 'Item.dart';
import 'Particle.dart';

class CompiledGame {
  List<int> collectables = [];
  List<Offset> playerSpawnPoints = [];
  List<Vector2> crates = [];
  int cratesTotal = 0;
  List<Offset> zombieSpawnPoints = [];
  List<EnvironmentObject> backgroundObjects = [];
  List<EnvironmentObject> environmentObjects = [];
  List<EnvironmentObject> torches = [];
  List<List<Tile>> tiles = [];
  List<NpcDebug> npcDebug = [];
  final List<Human> humans = [];
  final List<Zombie> zombies = [];
  final List<InteractableNpc> interactableNpcs = [];
  int totalZombies = 0;
  int totalNpcs = 0;
  int totalHumans = 0;
  List<Vector2> bullets = [];
  List<Vector2> bulletHoles = [];
  List<Sprite> sprites = [];
  int totalSprites = 0;
  int bulletHoleIndex = 0;
  List<Particle> particles = [];
  List<ParticleEmitter> particleEmitters = [];
  List<double> grenades = [];
  int gameId = -1;
  GameType gameType;
  int totalBullets = 0;
  int playerId = -1;
  String playerUUID = "";
  double playerX = -1;
  double playerY = -1;
  Weapon playerWeapon = Weapon.Unarmed;
  int playerLives = 0;
  CharacterState playerState = CharacterState.Idle;
  List<Item> items = [];
  int totalItems = 0;

  int lives = 0;
  int wave = 1;
  int nextWave = 2;
}

