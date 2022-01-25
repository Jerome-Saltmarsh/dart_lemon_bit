


import 'package:bleed_client/modules/game/events.dart';
import 'package:bleed_client/modules/game/state.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:lemon_engine/typedefs/DrawCanvas.dart';

class GameModule {
  final state = GameState();
  final events = GameEvents();
  DrawCanvas render = renderGame;
}