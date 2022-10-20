
import 'package:gamestream_flutter/modules/game/style.dart';
import 'package:gamestream_flutter/modules/game/update.dart';

class GameModule {

  final style = GameStyle();
  late final GameUpdate update;

  GameModule(){
    update = GameUpdate();
  }
}