
import 'dart:ui';

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/Weapons.dart';

import '../enums.dart';
import 'Particle.dart';

class CompiledGame {
  List<int> collectables = [];
  List<Offset> playerSpawnPoints = [];
  List<Offset> zombieSpawnPoints = [];
  List<List<Tile>> tiles = [];
  List<List<dynamic>> players = [];
  List<List<dynamic>> npcs = [];
  int totalNpcs = 0;
  List<double> bullets = List.filled(1000, 0);
  List<double> bulletHoles = [];
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
  int playerGrenades = 0;
  int playerMeds = 0;
  int playerLives = 0;

  int lives = 0;
  int wave = 1;
  int nextWave = 2;
}

