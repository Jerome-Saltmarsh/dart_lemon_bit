
import 'dart:ui';

import 'package:bleed_client/classes/Vector2.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/Weapons.dart';

import '../enums.dart';
import 'Item.dart';
import 'Particle.dart';

class CompiledGame {
  List<int> collectables = [];
  List<Offset> playerSpawnPoints = [];
  List<Offset> crates = [];
  List<Offset> zombieSpawnPoints = [];
  List<List<Tile>> tiles = [];
  List<List<dynamic>> players = [];
  List<List<dynamic>> npcs = [];
  int totalNpcs = 0;
  int totalPlayers = 0;
  List<Vector2> bullets = [];
  List<Vector2> bulletHoles = [];
  int bulletHoleIndex = 0;
  List<Particle> particles = [];
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

