import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';


final _timeline = core.state.timeline;
final _mode = core.state.mode;
final _game = modules.game;

void update() {
  _timeline.update();
  switch(_mode.value){
    case Mode.Website:
      break;
    case Mode.Player:
      _game.update.update();
      break;
    case Mode.Editor:
      editor.update();
      break;
  }
}