
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
  final state = GameState();
  final build = GameBuild();
  final properties = GameProperties();
  final update = GameUpdate();
  final style = GameStyle();
  final actions = GameActions();
  final factories = GameFactories();
  late final render;
  late final events;

  GameModule(){
    render = GameRender(style);
    events = GameEvents(actions);
  }
}