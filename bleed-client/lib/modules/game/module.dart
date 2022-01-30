
import 'package:bleed_client/modules/game/actions.dart';
import 'package:bleed_client/modules/game/build.dart';
import 'package:bleed_client/modules/game/events.dart';
import 'package:bleed_client/modules/game/factories.dart';
import 'package:bleed_client/modules/game/properties.dart';
import 'package:bleed_client/modules/game/render.dart';
import 'package:bleed_client/modules/game/state.dart';
import 'package:bleed_client/modules/game/style.dart';
import 'package:bleed_client/modules/game/update.dart';

class GameModule {
  final build = GameBuild();
  final properties = GameProperties();
  final style = GameStyle();
  final factories = GameFactories();
  late final GameState state;
  late final GameActions actions;
  late final GameRender render;
  late final GameEvents events;
  late final GameUpdate update;

  GameModule(){
    state = GameState();
    actions = GameActions(state);
    render = GameRender(style);
    events = GameEvents(actions);
    update = GameUpdate(state);
  }
}