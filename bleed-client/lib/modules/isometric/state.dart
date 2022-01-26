

import 'dart:typed_data';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class IsometricState {
  final Watch<int> hour = Watch(0);
  final List<EnvironmentObject> environmentObjects = [];
  final Watch<Shade> ambient = Watch(Shade.VeryDark);
  final List<List<Shade>> dynamicShading = [];
  final List<List<Shade>> bakeMap = [];
  final Watch<int> time = Watch(0);
  final Watch<Phase> phase = Watch(Phase.Day);
  late Float32List tilesDst;
  late Float32List tilesSrc;
  /// Used by caves and inside to control ambient light
  final Watch<Shade> maxAmbientBrightness = Watch(Shade.Bright);
}