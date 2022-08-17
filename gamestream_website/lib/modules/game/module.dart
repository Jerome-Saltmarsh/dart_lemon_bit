
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/build.dart';
import 'package:gamestream_flutter/modules/game/events.dart';
import 'package:gamestream_flutter/modules/game/map.dart';
import 'package:gamestream_flutter/modules/game/queries.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/game/style.dart';
import 'package:gamestream_flutter/modules/game/update.dart';

class GameModule {

  final style = GameStyle();
  late final GameBuild build;
  late final GameState state;
  late final GameActions actions;
  late final GameRender render;
  late final GameEvents events;
  late final GameUpdate update;
  late final GameMap map;
  late final GameQueries queries;

  GameModule(){
    state = GameState();
    actions = GameActions(state);
    queries = GameQueries(state);
    render = GameRender(state, style, queries);
    events = GameEvents(actions, state);
    update = GameUpdate(state);
    map = GameMap(state, actions);
    build = GameBuild(state, actions);
  }
}