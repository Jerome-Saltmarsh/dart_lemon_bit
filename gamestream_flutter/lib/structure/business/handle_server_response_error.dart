
import 'package:gamestream_flutter/library.dart';


void handleServerResponseGameError(GameError gameError){
  print("handleServerResponseGameError($gameError)");
  ClientActions.playAudioError();

  switch (gameError) {
    case GameError.Unable_To_Join_Game:
      WebsiteState.error.value = 'unable to join game';
      GameNetwork.disconnect();
      break;
    default:
      ServerState.error.value = gameError.name;
      break;
  }
}