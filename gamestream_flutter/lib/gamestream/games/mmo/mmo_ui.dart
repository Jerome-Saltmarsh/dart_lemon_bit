
import 'package:bleed_common/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUI on MmoGame {

  Widget buildMMOUI()=> Stack(
    alignment: Alignment.center,
    children: [
      buildNpcText(),
      buildPlayerItems()
    ],
  );

  Positioned buildNpcText() => Positioned(
      bottom: 16,
      child: buildWatch(npcText, (npcText) => npcText.isEmpty ? nothing :
      GSDialog(
        child: Container(
            width: 200,
            height: 200 * goldenRatio_0618,
            color: GS_CONTAINER_COLOR,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(child: buildText(npcText)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: onPressed(
                      action: endInteraction,
                      child: buildText('x', size: 25)),
                ),
              ],
            )),
      )),
    );

  Positioned buildPlayerItems() => Positioned(
        bottom: 16,
        left: 16,
        child: GSWindow(
        child: buildWatch(
          itemListener,
          (int reads) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(itemLength, (index) => onPressed(
              action: () => selectItem(index),
              child: buildText(
                '${GameObjectType.getName(itemTypes[index])} ${GameObjectType.getNameSubType(itemTypes[index], itemSubTypes[index])}'
              ),
            )),
          ),
        ),
      ));


}

