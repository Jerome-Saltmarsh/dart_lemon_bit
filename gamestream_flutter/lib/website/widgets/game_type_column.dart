
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

import '../../engine/instances.dart';


class GameTypeColumn extends StatelessWidget {

  static const gameTypes = [
    GameType.Combat,
    GameType.Fight2D,
    GameType.Cube3D,
  ];

  @override
  Widget build(BuildContext context) {
    return WatchBuilder(
        gsEngine.gameType,
        (activeGameType) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: gameTypes
                .map((gameType) => onPressed(
                    action: () => gsEngine.startGameType(gameType),
                    child: text(gameType.name, size: 25)))
                .toList()));
  }
}