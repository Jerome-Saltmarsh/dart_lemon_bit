import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/update.dart';

void update() {
  core.state.timeline.update();
  switch(core.state.mode.value){
    case Mode.Website:
      // TODO: Handle this case.
      break;
    case Mode.Player:
      updatePlayMode();
      break;
    case Mode.Editor:
      editor.update();
      break;
  }
}