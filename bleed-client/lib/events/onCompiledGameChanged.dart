
import 'package:bleed_client/parse.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/initialized.dart';

void onCompiledGameChanged(String value){
  if (!initialized.value) {
    print("onCompiledGameChanged() aborted still initing");
    return;
  }
  parseState();
  redrawCanvas();
}