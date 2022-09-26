
import 'package:gamestream_flutter/modules/game/events.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:gamestream_flutter/modules/game/style.dart';
import 'package:gamestream_flutter/modules/game/update.dart';

class GameModule {

  final style = GameStyle();
  late final GameRender render;
  late final GameEvents events;
  late final GameUpdate update;

  GameModule(){
    render = GameRender(style);
    events = GameEvents();
    update = GameUpdate();
  }
}