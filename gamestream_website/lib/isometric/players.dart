
import 'package:gamestream_flutter/isometric/classes/character.dart';

var totalPlayers = 0;
final players = <Character>[];

void foreachPlayer(Function(Character player) apply){
   for (var i = 0; i < totalPlayers; i++){
      apply(players[i]);
   }
}