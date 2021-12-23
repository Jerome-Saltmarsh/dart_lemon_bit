import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/constants/getServerTypeName.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/functions/refreshPage.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/golden_ratio.dart';

import '../../audio.dart';
import '../../title.dart';
import '../state/flutter_constants.dart';

Widget buildConnecting() {
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

Widget _buildServerTypeButton(ServerType server) {
  double height = 50;
  return Container(
    child: mouseOver(
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
              ),
              width: height * (goldenRatio * 2),
              child: text(
                  toString(server), fontWeight: hovering ? FontWeight.bold : FontWeight.normal,
                  fontSize: hovering ? 20 : 18
              ),
              alignment: Alignment.center));
    }),
    margin: EdgeInsets.only(bottom: height * goldenRatioInverseB),
  );
}

Widget buildSelectServerType() {
  return center(
    SingleChildScrollView(
      child: Column(crossAxisAlignment: cross.center, children: [
        text(title, fontSize: 45),
        height32,
        ...selectableServerTypes.map(_buildServerTypeButton)
      ]),
    ),
  );
}
