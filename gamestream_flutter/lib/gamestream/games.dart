
import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/Mmo.dart';
import 'package:gamestream_flutter/gamestream/games/moba/moba.dart';
import 'package:gamestream_flutter/gamestream/games/survival/survival_game.dart';

import 'game.dart';
import 'games/combat/combat_game.dart';
import 'games/game_cube3d.dart';
import 'games/fight2d/game_fight2d.dart';
import 'games/website/website_game.dart';
import 'isometric/classes/isometric_game.dart';
import 'gamestream.dart';

class Games {
  late final fight2D = GameFight2D();
  late final cube3D = GameCube3D();
  late final website = WebsiteGame();
  late final IsometricGame isometricEditor;
  late final CaptureTheFlagGame captureTheFlag;
  late final Moba moba;
  late final SurvivalGame survival;
  late final CombatGame combat;
  late final Mmo mmo;

  Games(Gamestream gamestream) {
     captureTheFlag = CaptureTheFlagGame(gamestream: gamestream);
     isometricEditor = IsometricGame(isometric: gamestream.isometric);
     survival = SurvivalGame(isometric: gamestream.isometric);
     moba = Moba(isometric: gamestream.isometric);
     combat = CombatGame(isometric: gamestream.isometric);
     mmo = Mmo(isometric: gamestream.isometric);
  }

  Game mapGameTypeToGame(GameType gameType) => switch (gameType) {
      GameType.Website => website,
      GameType.Fight2D => fight2D,
      GameType.Combat  => combat,
      GameType.Cube3D  => cube3D,
      GameType.Capture_The_Flag => captureTheFlag,
      GameType.Editor => isometricEditor,
      GameType.Moba => moba,
      GameType.Mmo => mmo,
      _ => throw Exception('mapGameTypeToGame($gameType)')
    };
}