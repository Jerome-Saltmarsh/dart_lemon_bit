
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/instances/engine.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:golden_ratio/constants.dart';

import 'ui/src.dart';

extension MMOUI on MmoGame {

  Widget buildMMOUI()=> Stack(
    alignment: Alignment.center,
    children: [
      buildNpcText(),
      buildPlayerItems(),
      buildPlayerAimTarget(),
      buildItemHoverDialog(),
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
          weaponsChangedNotifier,
          (int reads) => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weapons.length, buildItemImageAtIndex),
          ),
        ),
      ));

  buildPlayerAimTarget() {
    final name = Container(
      alignment: Alignment.center,
      width: 120,
      child: FittedBox(
        child: GSWindow(
            child: buildWatch(player.playerAimTargetName, buildText)),
      ),
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

  Widget buildItemImageAtIndex(int index) {
    final item = weapons[index];
    return MouseRegion(
        onEnter: (_){
          itemHover.value = item;
        },
        onExit: (_){
           if (itemHover.value != item)
             return;
           itemHover.value = null;
        },
        child: onPressed(
            onRightClick: item == null ? null : () => dropItem(index),
            action: item == null ? null : () => selectItem(index),
            child: buildWatch(equippedWeaponIndex, (equippedWeaponIndex) => buildBorder(
                  width: 2,
                  color: equippedWeaponIndex == index ? Colors.white : GS_CONTAINER_COLOR,
                  child: MMOItemImage(item: item, size: 64),
              )),
        ),
    );
  }

  buildItemHoverDialog() => Positioned(
      left: 16,
      bottom: 130,
      child: buildWatch(
          itemHover,
          (item) => item == null
              ? nothing
              : GSWindow(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildText(item.name.replaceAll('_', ' ')),
                    buildText('damage ${item.damage}'),
                    buildText('cooldown ${item.cooldown}'),
                    buildText('range ${item.range.toInt()}'),
                  ],
                ))));
}
