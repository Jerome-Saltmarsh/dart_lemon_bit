
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


class GameTypeColumn extends StatelessWidget {

  static const gameTypes = [
    GameType.Combat,
    GameType.Fight2D,
  ];

  @override
  Widget build(BuildContext context) {
    return WatchBuilder(gsEngine.gameType, (activeGameType) =>
        Column(children: gameTypes
          .map((gameType) => onPressed(
            action: () => GameNetwork.connectToGame(gameType),
            child: text(gameType.name, size: 20))
        )
          .toList()
        )
    );
  }
}