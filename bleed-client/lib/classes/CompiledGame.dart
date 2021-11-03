
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/classes/Sprite.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/classes/Vector2.dart';

import '../enums.dart';
import 'EnvironmentObject.dart';
import 'Item.dart';
import 'Particle.dart';

class CompiledGame {
  List<int> collectables = [];
  List<Vector2> crates = [];
  int cratesTotal = 0;
  List<EnvironmentObject> backgroundObjects = [];
  final List<EnvironmentObject> environmentObjects = [];
  List<List<Tile>> tiles = [];
  int totalColumns = 0;
  int totalRows = 0;
  List<NpcDebug> npcDebug = [];
  int time = 0;
  final List<Character> humans = [];
  final List<Zombie> zombies = [];
  final List<Character> interactableNpcs = [];
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

