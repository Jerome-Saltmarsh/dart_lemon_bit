
import 'package:flutter/services.dart';
import 'package:flutter_game_engine/game_engine/game_input.dart';


bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);
bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);
bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);