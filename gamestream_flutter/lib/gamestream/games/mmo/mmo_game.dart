
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/library.dart';

class MmoGame extends IsometricGame {

  final npcText = Watch("");

  MmoGame({required super.isometric});

  @override
  Widget customBuildUI(BuildContext context) => buildMMOUI();
}