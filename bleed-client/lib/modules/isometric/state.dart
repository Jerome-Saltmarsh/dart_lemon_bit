

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

class IsometricState {
  final Watch<Shade> ambientLight = Watch(Shade.VeryDark);
  final List<List<Shade>> dynamicShading = [];
  final List<List<Shade>> bakeMap = [];
  final Watch<int> time = Watch(0);
}