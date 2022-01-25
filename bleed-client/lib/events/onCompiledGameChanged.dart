
import 'package:bleed_client/parse.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';

void onCompiledGameChanged(String value){
  if (!engine.state.initialized.value) {
    print("onCompiledGameChanged() aborted still initing");
    return;
  }
  parseState();
  redrawCanvas();
}