
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
      buildPlayerWeapons(),
      buildPlayerItems(),
      buildPlayerAimTarget(),
      buildItemHoverDialog(),
      buildPlayerEquipped(),
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

  Positioned buildPlayerWeapons() => Positioned(
        bottom: 16,
        left: 16,
        child: GSWindow(
        child: buildWatch(
          weaponsChangedNotifier,
          (int reads) => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weapons.length, buildWeaponImageAtIndex),
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

  Widget buildWeaponImageAtIndex(int index) {
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
            onRightClick: item == null ? null : () => dropWeapon(index),
            action: item == null ? null : () => selectWeapon(index),
            child: buildWatch(equippedWeaponIndex, (equippedWeaponIndex) => buildBorder(
                  width: 2,
                  color: equippedWeaponIndex == index ? Colors.white : GS_CONTAINER_COLOR,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(child: MMOItemImage(item: item, size: 64)),
                      Positioned(
                          top: 8,
                          left: 8,
                          child: buildText(const['Q', 'W', 'E', 'R'][index], color: Colors.white70)
                      ),
                    ],
                  ),
              )),
        ),
    );
  }

  Widget buildItemImageAtIndex(int index) {
    final item = items[index];
    return onPressed(
        onRightClick: item == null ? null : () => dropItem(index),
        action: item == null ? null : () => selectItem(index),
        child: MMOItemImage(item: item, size: 64),
    );
  }

  buildItemHoverDialog({double edgePadding = 150}) => buildWatch(
      itemHover,
      (item) => item == null
          ? Positioned(child: nothing, top: 0, left: 0,)
          : Positioned(
              left: engine.mousePositionX < engine.screenCenterX ? edgePadding : null,
              right: engine.mousePositionX > engine.screenCenterX ? edgePadding : null,
              top: engine.mousePositionY < engine.screenCenterY ? edgePadding : null,
              bottom: engine.mousePositionY > engine.screenCenterY ? edgePadding : null,
            child: GSWindow(
                width: 200,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: buildText(item.name.replaceAll('_', ' '), size: 26, color: Colors.white.withOpacity(0.8))),
                  height16,
                  if (item.quality != null)
                     buildItemRow('quality', item.quality!.name),
                  buildItemRow('damage', item.damage),
                  buildItemRow('cooldown', item.cooldown),
                  buildItemRow('range', item.range),
                  buildItemRow('health', item.health),
                ],
              )),
          ));

  static Widget buildItemRow(String text, dynamic value){
     if (value == null || value == 0) return nothing;
     if (value is double) {
       value = value.toInt();
     }
     final textColor = Colors.white.withOpacity(0.8);
     final textSize = 22;
     return Container(
       margin: const EdgeInsets.only(bottom: 4),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           buildText(text, color: textColor, size: textSize),
           Container(
               width: 70,
               alignment: Alignment.centerRight,
               color: Colors.white12,
               padding: const EdgeInsets.all(4),
               child: buildText(value, color: textColor, size: textSize)),
         ],
       ),
     );
  }

  Widget buildPlayerItems() => Positioned(
      left: 16,
      bottom: 130,
      child: buildWatch(
          itemsChangedNotifier,
          (_) => GSWindow(
              child: Column(
                  children: List.generate(
                      items.length, (index) => buildItemImageAtIndex(index),
                      growable: false)))
      )
  );

  Widget buildPlayerEquipped() => Positioned(
        bottom: 16,
        right: 16,
        child: GSWindow(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            buildWatch(equippedHead, (equipped) => MMOItemImage(item: equipped, size: 64)),
            buildWatch(equippedBody, (equipped) => MMOItemImage(item: equipped, size: 64)),
            buildWatch(equippedLegs, (equipped) => MMOItemImage(item: equipped, size: 64)),
          ],),
        ));
}
