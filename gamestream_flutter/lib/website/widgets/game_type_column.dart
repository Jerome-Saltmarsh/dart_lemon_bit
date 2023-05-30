
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
        (activeGameType) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: gameTypes
                .map((gameType) => onPressed(
                  action: () => gamestream.startGameType(gameType),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        SizedBox(
                            width: 256,
                            child: GameTypeImage(gameType: gameType)),
                        text(gameType.name, size: 25),
                      ],
                    ),
                  ),
                ))
                .toList()));
  }
}

class GameTypeImage extends StatelessWidget {
   final GameType gameType;

  const GameTypeImage({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Image.asset(mapGameTypeToImageAsset(gameType), fit: BoxFit.fitWidth,);
  }

  static String mapGameTypeToImageAsset(GameType gameType){
     return const {
       GameType.Fight2D: 'images/website/game-fight2d.png',
       GameType.Combat: 'images/website/game-isometric.png',
     }[gameType] ?? '';
  }
}