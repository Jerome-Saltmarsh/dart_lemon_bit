import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/constants/getServerTypeName.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/functions/refreshPage.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/golden_ratio.dart';

import '../../audio.dart';
import '../state/flutter_constants.dart';

Widget buildViewConnecting() {
  return center(
      Column(
        mainAxisAlignment: main.center,
        children: [
          Container(
            height: 80,
            child: AnimatedTextKit(repeatForever: true, animatedTexts: [
              RotateAnimatedText("Connecting to server: ${game.serverType.value}",
                  textStyle: TextStyle(color: Colors.white, fontSize: 30)),
            ]),
          ),
          height32,
          onPressed(child: text("Cancel"), callback: (){
            sharedPreferences.remove('server');
            refreshPage();
          }),
        ],
      )
  );
}

Widget _buildServer(ServerType server) {
  double height = 50;
  return Container(
    child: mouseOver(
        onEnter: playAudioButtonHover,
        builder: (BuildContext context, bool hovering) {
      return onPressed(
          callback: () {
            game.serverType.value = server;
          },
          child: Container(
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: hovering ? 4 : 2),
                borderRadius: borderRadius4,
                // color: hovering ? Colors.white30 : null
              ),
              width: height * (goldenRatio * 2),
              child: text(
                  getServerName(server), fontWeight: hovering ? FontWeight.bold : FontWeight.normal,
                  fontSize: hovering ? 20 : 18
              ),
              alignment: Alignment.center));
    }),
    margin: EdgeInsets.only(bottom: height * goldenRatioInverseB),
  );
}

Widget buildSelectServer() {
  return center(
    SingleChildScrollView(
      child: Column(crossAxisAlignment: cross.center, children: [
        height(50 * goldenRatioInverse),
        text(game.type.value, fontSize: 120),
        height(50 * goldenRatioInverse),
        text("Select a server to connect to"),
        height(50 * goldenRatioInverseB),
        ...ServerType.values.map(_buildServer)
      ]),
    ),
  );
}
