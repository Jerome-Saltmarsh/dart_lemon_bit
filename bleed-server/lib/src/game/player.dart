
import 'package:bleed_server/common/src/enums/input_mode.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import 'game.dart';

abstract class Player with ByteWriter {
  Game get game;
  var framesSinceClientRequest = 0;
  final mouse = Vector2(0, 0);
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var inputMode = InputMode.Keyboard;

  void writePlayerGame();

  Player(){
    writeGameType();
  }
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
}