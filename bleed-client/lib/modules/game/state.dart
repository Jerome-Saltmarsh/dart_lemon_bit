

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_watch/watch.dart';

class GameState {
  final Watch<Shade> ambientLight = Watch(Shade.VeryDark);
  /// In seconds
  final Watch<int> timeInSeconds = Watch(0);
}