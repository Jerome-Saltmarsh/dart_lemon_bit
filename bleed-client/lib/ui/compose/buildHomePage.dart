import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/cupertino.dart';

Widget buildHomePage(){
  return Column(
    children: [
      Container(
          alignment: Alignment.center,
          height: 80,
          child: text("QUEST-ARCADE", fontSize: 30)),
      button("MOBA", (){
        game.type.value = GameType.Moba;
      }),
      height8,
      button("Open World", (){
        game.type.value = GameType.Open_World;
      }),
    ],
  );
}


