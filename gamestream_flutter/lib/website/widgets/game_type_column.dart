
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';



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
       GameType.Capture_The_Flag: 'images/website/game-isometric.png',
     }[gameType] ?? '';
  }
}