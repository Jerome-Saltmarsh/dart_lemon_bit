
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUI on MmoGame {

  Widget buildMMOUI()=> buildWatch(npcText, (npcText) => npcText.isEmpty ? nothing :
    GSDialog(
      child: GSContainer(
          width: 200,
          height: 200 * goldenRatio_0618,
          child: Stack(
            alignment: Alignment.center,
            children: [
              buildText(npcText),
              Positioned(
                bottom: 8,
                right: 8,
                child: onPressed(
                    action: endInteraction,
                    child: buildText("close")),
              ),
            ],
          )),
    ));
}