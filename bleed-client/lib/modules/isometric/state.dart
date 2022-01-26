

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

class IsometricState {
  final List<EnvironmentObject> environmentObjects = [];
  final Watch<Shade> ambient = Watch(Shade.VeryDark);
  final List<List<Shade>> dynamicShading = [];
  final List<List<Shade>> bakeMap = [];
  final Watch<int> time = Watch(0);
}