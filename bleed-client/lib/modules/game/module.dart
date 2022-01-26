


import 'package:bleed_client/modules/game/build.dart';
import 'package:bleed_client/modules/game/events.dart';
import 'package:bleed_client/modules/game/properties.dart';
import 'package:bleed_client/modules/game/state.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';

class GameModule {
  final state = GameState();
  final events = GameEvents();
  final build = GameBuild();
  final properties = GameProperties();
  final render = renderGame;
}