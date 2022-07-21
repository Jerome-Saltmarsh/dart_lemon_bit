

import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onMouseRightClicked(){
  if (playModeEdit) return;
    // sendClientRequestAttack();
  sendClientRequestCaste();
}