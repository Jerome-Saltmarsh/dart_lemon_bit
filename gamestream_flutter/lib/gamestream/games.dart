
import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/moba/moba.dart';

import 'game.dart';
import 'games/fight2d/game_fight2d.dart';
import 'games/website/website_game.dart';
import 'isometric/classes/isometric_game.dart';
import 'gamestream.dart';

class Games {
  late final fight2D = GameFight2D();
  late final website = WebsiteGame();
  late final IsometricGame isometricEditor;
  late final CaptureTheFlagGame captureTheFlag;
  late final Moba moba;
  late final MmoGame mmo;

  Games(Gamestream gamestream) {
     captureTheFlag = CaptureTheFlagGame(gamestream: gamestream);
     isometricEditor = IsometricGame(isometric: gamestream.isometric);
     moba = Moba(isometric: gamestream.isometric);
     mmo = MmoGame(isometric: gamestream.isometric);
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