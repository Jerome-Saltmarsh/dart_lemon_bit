
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';

import 'common/GameType.dart';

final _Logic logic = _Logic();

class _Logic {

  void connectToSelectedGame(){
    connectToWebSocketServer(game.region.value, game.type.value);
  }

  void deselectGameType(){
    game.type.value = GameType.None;
  }

  void deselectRegion(){
    game.region.value = Region.None;
  }

  void toggleAudio() {
    game.settings.audioMuted.value = !game.settings.audioMuted.value;
  }

  void toggleEditMode() {
    game.mode.value = game.mode.value == Mode.Play ? Mode.Edit : Mode.Play;
  }

  void openEditor(){
    newScene(rows: 40, columns: 40);
    game.mode.value = Mode.Edit;

  }

  void exit(){
    print("logic.exit()");
    game.type.value = GameType.None;
    clearSession();
    webSocket.disconnect();
  }

  // functions
  void leaveLobby() {
    server.leaveLobby();
    exit();
  }

  void clearSession(){
    print("logic.clearSession()");
    game.player.uuid.value = "";
  }
}