
import 'dart:ui';

import '../enums.dart';

class Game {
  List<int> collectables = [];
  List<Offset> playerSpawnPoints = [];
  List<Offset> zombieSpawnPoints = [];
  List<List<Tile>> tiles = [];
}
