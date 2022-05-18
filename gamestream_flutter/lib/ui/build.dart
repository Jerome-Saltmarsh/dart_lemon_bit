import 'package:bleed_common/GameType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/assets.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:lemon_watch/watch_builder.dart';

final build = _Build();

const selectableGameTypes = [
  GameType.RANDOM,
  // GameType.SURVIVORS,
];

class _Build {

  Widget timeZone(){
    return text(DateTime.now().timeZoneName);
  }

  Widget totalZombies(){
    return WatchBuilder(byteStreamParser.totalZombies, (int zombies){
      return text("Zombies: $zombies");
    });
  }

  // Widget buildPageSelectGame(){
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         buildTitle(),
  //         height32,
  //         ...selectableGameTypes.map((gameType) {
  //         return Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: mouseOver(
  //               builder: (BuildContext context, bool mouseOver) {
  //                 final gameName = gameTypeNames[gameType];
  //
  //                 if (mouseOver){
  //                   return loadingText(gameName!, (){
  //                     // core.actions.connectToGame(gameType);
  //                   });
  //                 }
  //                 return text(mouseOver ? '-$gameName-' : gameName, color: mouseOver ? colours.white : colours.white85, onPressed: (){
  //                   core.actions.connectToGame(gameType);
  //                 }, size: FontSize.Large, bold: true);
  //               },
  //           ),
  //         );
  //       }
  //       ),
  //
  //         height(120),
  //        ].toList(),
  //     ),
  //   );
  // }
}


Region detectRegion(){
  print("detectRegion()");
  final timeZoneName = DateTime.now().timeZoneName.toLowerCase();

  if (timeZoneName.contains('australia')){
    print('australia detected');
    return Region.Australia;
  }
  if (timeZoneName.contains('new zealand')){
    print('australia detected');
    return Region.Australia;
  }
  if (timeZoneName.contains('european')){
    return Region.Germany;
  }

  return Region.Australia;
}


Widget buildTitle(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      text("GAME",
          size: 60,
          color: Colors.white,
          family: Fonts.LibreBarcode39Text
      ),
      text("STREAM",
        size: 60,
        color: colours.red,
        family: Fonts.LibreBarcode39Text,
      ),
    ],
  );
}
