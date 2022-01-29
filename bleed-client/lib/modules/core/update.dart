import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/modules.dart';

void update() {
  core.state.timeline.update();
  switch(core.state.mode.value){
    case Mode.Website:
      // TODO: Handle this case.
      break;
    case Mode.Player:
      modules.game.update.update();
      break;
    case Mode.Editor:
      editor.update();
      break;
  }
}