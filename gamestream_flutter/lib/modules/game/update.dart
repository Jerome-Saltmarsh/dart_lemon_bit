import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/update.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

import 'state.dart';

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {
    updateIsometric();
    readPlayerInput();
    sendClientRequestUpdate();

    if (framesSinceUpdateReceived.value == 0){
      saveInterpolation();
    }
    if (framesSinceUpdateReceived.value == 1){
      interpolatePlayer();
    }
    if (framesSinceUpdateReceived.value > 1){
      print('frames ${framesSinceUpdateReceived.value}');
    }

    updateCameraMode();
    framesSinceUpdateReceived.value++;
  }

  void saveInterpolation(){
    previousPlayerPositionX = player.x;
    previousPlayerPositionY = player.y;
  }

  /// Render the player in the same relative position to the camera
  void interpolatePlayer(){
     final playerCharacter = getPlayerCharacter();
     if (playerCharacter == null) return;

     var currentX = player.x;
     var currentY = player.y;

     var diffX = previousPlayerPositionX - currentX;
     var diffY = previousPlayerPositionY - currentY;

     const interpolation = 1;
     playerCharacter.x -= (diffX * interpolation);
     playerCharacter.y -= (diffY * interpolation);
  }
}

var previousPlayerPositionX = 0.0;
var previousPlayerPositionY = 0.0;

Character? getPlayerCharacter(){
   for (var i = 0; i < totalCharacters; i++){
      if (characters[i].x != player.x) continue;
      if (characters[i].y != player.y) continue;
      return characters[i];
   }
   return null;
}
