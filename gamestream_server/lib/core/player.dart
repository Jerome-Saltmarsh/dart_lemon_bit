
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:lemon_byte/byte_writer.dart';

import 'game.dart';

abstract class Player with ByteWriter {

  var mouseX = 0.0;
  var mouseY = 0.0;
  var framesSinceClientRequest = 0;
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var inputMode = InputMode.Keyboard;
  var _mouseLeftDown = false;

  Player(){
    writeGameType();
    writeFPS();
  }

  set mouseLeftDown(bool value){
     if (_mouseLeftDown != value) {
       _mouseLeftDown = value;
       if (value){
          onMouseLeftClicked();
       } else {
          onMouseLeftReleased();
       }
     } else {
       if (value){
         onMouseLeftHeld();
       }
     }
  }

  void onMouseLeftReleased(){

  }

  void onMouseLeftClicked(){

  }

  void onMouseLeftHeld(){

  }

  void writePlayerGame();

  Game get game;

  void handleRequestException(Object exception) {}

}

extension PlayerExtension on Player {

  void writeGameError(GameError gameError){
    writeByte(ServerResponse.Game_Error);
    writeByte(gameError.index);
  }

  void writeGameType(){
    writeByte(ServerResponse.Game_Type);
    writeByte(game.gameType.index);
  }

  void writeFPS() {
    writeByte(ServerResponse.FPS);
    writeUInt16(Gamestream.Frames_Per_Second);
  }
}