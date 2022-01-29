
import 'dart:ui';

import 'package:lemon_math/Vector2.dart';
import 'dart:typed_data';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

class IsometricState {
  late Image image;
  List<List<Vector2>> paths = [];
  List<FloatingText> floatingText = [];
  bool eventsRegistered = false;
  List<List<Tile>> tiles = [];
  Float32List tilesDst = Float32List(0);
  Float32List tilesSrc = Float32List(0);
  List<Particle> particles = [];
  final List<EnvironmentObject> environmentObjects = [];
  final List<List<int>> dynamicShading = [];
  final List<List<int>> bakeMap = [];
  final Watch<int> totalColumns = Watch(0);
  final Watch<int> totalRows = Watch(0);
  int totalColumnsInt = 0;
  int totalRowsInt = 0;
  final Watch<int> hour = Watch(0);
  final Watch<int> time = Watch(0);
  final Watch<int> ambient = Watch(Shade_Bright);
  final Watch<int> maxAmbientBrightness = Watch(Shade_Bright);
}