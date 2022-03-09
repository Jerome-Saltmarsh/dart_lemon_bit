
import 'package:bleed_client/modules/game/actions.dart';
import 'package:bleed_client/modules/game/build.dart';
import 'package:bleed_client/modules/game/events.dart';
import 'package:bleed_client/modules/game/factories.dart';
import 'package:bleed_client/modules/game/map.dart';
import 'package:bleed_client/modules/game/queries.dart';
import 'package:bleed_client/modules/game/render.dart';
import 'package:bleed_client/modules/game/state.dart';
import 'package:bleed_client/modules/game/style.dart';
import 'package:bleed_client/modules/game/update.dart';

class GameModule {
  final style = GameStyle();
  final factories = GameFactories();
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