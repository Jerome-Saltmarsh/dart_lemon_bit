import 'package:bleed_client/editor/functions/registerEditorKeyboardListener.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_watch/watch.dart';

Watch<Mode> mode = Watch(Mode.Play, onChanged: (value){
  print("onChanged($value)");
  if (value == Mode.Edit) {
    removeGeneratedEnvironmentObjects();
    deregisterPlayKeyboardHandler();
    registerEditorKeyboardListener();
    game.totalZombies.value = 0;
    game.totalProjectiles = 0;
    game.totalNpcs = 0;
    game.totalHumans = 0;
    game.zombies.clear();
    game.projectiles.clear();
    game.interactableNpcs.clear();
    game.humans.clear();
    game.particles.clear();
    timeInSeconds.value = 60 * 60 * 10;
  }
  redrawCanvas();
});

bool get playMode => mode.value == Mode.Play;
bool get editMode => mode.value == Mode.Edit;