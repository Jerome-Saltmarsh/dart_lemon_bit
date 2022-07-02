

import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onMouseRightClicked(){
  if (playModePlay) {
    sendClientRequestAttack();
  }
}