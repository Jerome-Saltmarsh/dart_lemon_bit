
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onChangedGameDialog(GameDialog? value){
  if (value == GameDialog.Scene_Load){
    sendClientRequestCustomGameNames();
  }
}