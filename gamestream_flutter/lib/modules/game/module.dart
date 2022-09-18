
import 'package:gamestream_flutter/modules/game/events.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/game/style.dart';
import 'package:gamestream_flutter/modules/game/update.dart';

class GameModule {

  final style = GameStyle();
  late final GameState state;
  late final GameRender render;
  late final GameEvents events;
  late final GameUpdate update;

  GameModule(){
    state = GameState();
    render = GameRender(state, style);
    events = GameEvents(state);
    update = GameUpdate(state);
  }
}