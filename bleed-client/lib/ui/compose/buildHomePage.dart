import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
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
          child: text("LEMON ARCADE", fontSize: 30)),
      button("MOBA", (){
        game.type.value = GameType.Moba;
      }),
      height8,
      button("Open World", (){
        game.type.value = GameType.Open_World;
      }),
      button(game.serverType.value, (){
        game.serverType.value = ServerType.None;
      })
    ],
  );
}


