
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/moba/moba.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

import '../common.dart';
import 'game.dart';
import 'games/fight2d/game_fight2d.dart';
import 'games/website/website_game.dart';
import 'isometric/classes/isometric_game.dart';

class Games {
  late final GameFight2D fight2D;
  late final WebsiteGame website;
  late final IsometricGame isometricEditor;
  late final CaptureTheFlagGame captureTheFlag;
  late final Moba moba;
  late final MmoGame mmo;

  Games(Isometric isometric) {
     fight2D  = GameFight2D(isometric);
     website = WebsiteGame(isometric);
     captureTheFlag = CaptureTheFlagGame(gamestream: isometric);
     isometricEditor = IsometricGame(isometric: isometric);
     moba = Moba(isometric: isometric);
     mmo = MmoGame(isometric: isometric);
  }

  Game mapGameTypeToGame(GameType gameType) => switch (gameType) {
      GameType.Website => website,
      GameType.Fight2D => fight2D,
      GameType.Capture_The_Flag => captureTheFlag,
      GameType.Editor => isometricEditor,
      GameType.Moba => moba,
      GameType.Mmo => mmo,
      _ => throw Exception('mapGameTypeToGame($gameType)')
    };
}