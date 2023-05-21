
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


class GameTypeColumn extends StatelessWidget {

  static const gameTypes = [
    GameType.Combat,
    GameType.Fight2D,
  ];

  @override
  Widget build(BuildContext context) {
    return WatchBuilder(ServerState.gameType, (activeGameType) =>
        Column(children: gameTypes
          .map((gameType) => onPressed(
            action: () => GameNetwork.connectToGame(gameType),
            child: text(GameType.getName(gameType), size: 20))
        )
          .toList()
        )
    );
  }
}