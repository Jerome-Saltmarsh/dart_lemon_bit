
import 'package:bleed_client/parse.dart';
import 'package:lemon_engine/game.dart';

void onCompiledGameChanged(String value){
  parseState();
  redrawCanvas();
}