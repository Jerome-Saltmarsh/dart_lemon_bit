
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/state/game.dart';

final _Logic logic = _Logic();

class _Logic {
  void deselectRegion(){
    game.region.value = Region.None;
  }

  void toggleAudio() {
    game.settings.audioMuted.value = !game.settings.audioMuted.value;
  }
}