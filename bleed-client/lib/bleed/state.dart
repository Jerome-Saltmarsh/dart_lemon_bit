import 'dart:ui';

List<dynamic> players = [];
List<dynamic> npcs = [];
List<dynamic> bullets = [];
int drawFrame = 0;
Canvas canvas;
int id = idNotConnected;
const idNotConnected = -1;

get playerCharacter {
  return players.firstWhere((element) => element[4] == id, orElse: (){
    return null;
  });
}