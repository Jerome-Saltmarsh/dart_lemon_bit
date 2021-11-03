
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/parser/state/response.dart';
import 'package:bleed_client/state.dart';

void onEvent(_response){
  lag = framesSinceEvent;
  framesSinceEvent = 0;
  DateTime now = DateTime.now();
  ping = now.difference(previousEvent);
  previousEvent = now;
  event = _response;
  parseState();
  redrawCanvas();
}