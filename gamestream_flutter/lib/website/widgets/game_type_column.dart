
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


class SelectGameTypeColumn extends StatelessWidget {

  static const gameTypes = [
    GameType.Combat,
    GameType.Fight2D,
    // GameType.Cube3D,
    // GameType.Aeon,
  ];

  @override
  Widget build(BuildContext context) {
    return WatchBuilder(
        gamestream.gameType,
        (activeGameType) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: gameTypes
                .map((gameType) => onPressed(
                    action: () => gamestream.startGameType(gameType),
                    child: text(gameType.name, size: 25)))
                .toList()));
  }
}