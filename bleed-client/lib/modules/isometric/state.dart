

import 'dart:typed_data';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

class IsometricState {
  bool eventsRegistered = false;
  List<List<Tile>> tiles = [];
  late Float32List tilesDst;
  late Float32List tilesSrc;
  final List<EnvironmentObject> environmentObjects = [];
  final List<List<Shade>> dynamicShading = [];
  final List<List<Shade>> bakeMap = [];
  final Watch<int> totalColumns = Watch(0);
  final Watch<int> totalRows = Watch(0);
  final Watch<int> hour = Watch(0);
  final Watch<int> time = Watch(0);
  final Watch<Shade> ambient = Watch(Shade.Bright);
  final Watch<Shade> maxAmbientBrightness = Watch(Shade.Bright);
}