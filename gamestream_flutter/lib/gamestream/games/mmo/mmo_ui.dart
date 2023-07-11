
import 'package:bleed_common/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/instances/engine.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUI on MmoGame {

  Widget buildMMOUI()=> Stack(
    alignment: Alignment.center,
    children: [
      buildNpcText(),
      buildPlayerItems(),
      buildPlayerAimTarget(),

    ],
  );

  Positioned buildNpcText() {

    const width = 200.0;
    const height = width * goldenRatio_0618;

    final options = buildWatch(npcOptionsReads, (t) =>
        Container(
          width: width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: npcOptions.map((option)=> onPressed(
                action: () => selectTalkOption(npcOptions.indexOf(option)),
                child: buildText(option))).toList(growable: false)),
        ));

    return Positioned(
      bottom: 16,
      child: buildWatch(npcText, (npcText) => npcText.isEmpty ? nothing :
      GSDialog(
        child: Container(
            width: width,
            height: height,
            color: GS_CONTAINER_COLOR,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(child: buildText(npcText)),
                Positioned(
                  bottom: 8,
                  child: options),
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
  }

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
              child: buildText(itemTypes[index] == 0 ? '-' :
                '${GameObjectType.getName(itemTypes[index])} ${GameObjectType.getNameSubType(itemTypes[index], itemSubTypes[index])}'
              ),
            )),
          ),
        ),
      ));

  buildPlayerAimTarget() {
    final name = Container(
      alignment: Alignment.center,
      width: 120,
      child: GSWindow(
          child: buildWatch(player.playerAimTargetName, buildText)),
    );
    return Positioned(
        top: 16,
        left: 0,
        child: Container(
          width: engine.screen.width,
          alignment: Alignment.center,
          child: buildWatch(player.playerAimTargetSet, (t) {
            if (!t) return nothing;
            return name;
          }),
        ));
  }
}

