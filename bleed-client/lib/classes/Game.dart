
import 'dart:ui';

import '../enums.dart';
import 'Particle.dart';

class Game {
  List<int> collectables = [];
  List<Offset> playerSpawnPoints = [];
  List<Offset> zombieSpawnPoints = [];
  List<List<Tile>> tiles = [];
  List<List<dynamic>> players = [];
  List<List<dynamic>> npcs = [];
  List<List<dynamic>> bullets = [];
  List<double> bulletHoles = [];
  List<Particle> particles = [];
  List<double> grenades = [];

  int playerId = -1;
  String playerUUID = "";
  double playerX = -1;
  double playerY = -1;
}
