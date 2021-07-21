
import 'package:flutter_game_engine/game_engine/game_maths.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'multiplayer_resources.dart';
import 'state.dart';

void playShotgunAudio() {
  shotgunFireAudio.play();
}

void playPistolAudio(){
  pistolFireAudio.play();
}

double playerScreenPositionX() {
  dynamic player = getPlayerCharacter();
  return player[keyPositionX] - cameraX;
}

double playerScreenPositionY() {
  if (!playerAssigned) return null;
  dynamic player = getPlayerCharacter();
  return player[keyPositionY] - cameraY;
}

double getMouseRotation() {
  dynamic player = getPlayerCharacter();
  double playerScreenPositionX = player[keyPositionX] - cameraX;
  double playerScreenPositionY = player[keyPositionY] - cameraY;
  return getRadionsBetween(playerScreenPositionX, playerScreenPositionY, mousePosX, mousePosY);
}

dynamic getPlayerCharacter() {
  return characters.firstWhere((element) => element[keyCharacterId] == id,
      orElse: () => null);
}

bool get playerAssigned =>
    characters.any((element) => element[keyCharacterId] == id);