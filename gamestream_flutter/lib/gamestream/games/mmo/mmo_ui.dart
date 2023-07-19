
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_actions.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:golden_ratio/constants.dart';

import 'ui/src.dart';

extension MMOUI on MmoGame {

  static const itemImageSize = 64.0;
  static const margin1 = 16.0;
  static const margin2 = 130.0;

  Widget buildMMOUI()=> Stack(
    alignment: Alignment.center,
    children: [
      buildNpcText(),
      buildPlayerWeapons(),
      Positioned(
        top: margin1,
        left: margin1,
        child: buildPlayerTreasures(),
      ),
      Positioned(
        bottom: margin2,
        left: margin1,
        child: buildInventoryButton(),
      ),
      Positioned(
        left: margin2,
        top: margin2,
        child: buildPlayerItems(),
      ),
      buildPlayerAimTarget(),
      buildItemHoverDialog(),
      Positioned(
          top: margin2,
          left: margin1,
          child: buildPlayerEquipped(),
      ),
      Positioned(
          top: margin2,
          left: margin2,
          child: buildPlayerTalentsDialog()
      ),
      Positioned(
          bottom: margin1,
          right: margin1,
          child: buildPlayerStatsRow(),
      ),
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
      bottom: margin1,
      child:
      buildWatch(playerInteracting, (interacting) => !interacting ? nothing :
      buildWatch(npcText, (npcText) => npcText.isEmpty ? nothing :
      GSContainer(
        width: width,
        height: height,
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
        ),
      )),
    )
    );
  }

  Positioned buildPlayerWeapons() => Positioned(
        bottom: margin1,
        left: margin1,
        child: GSContainer(
        child: buildWatch(
          weaponsChangedNotifier,
          (int reads) => Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weapons.length, buildWeaponImageAtIndex),
          ),
        ),
      ));

  Widget buildPlayerTreasures() => buildInventory(
    child: GSContainer(
    child: buildWatch(
      treasuresChangedNotifier,
      (int reads) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(treasures.length, (index) => onPressed(
            action: () => selectTreasure(index),
            onRightClick: () => dropTreasure(index),
            child: MMOItemImage(item: treasures[index], size: 64))),
      ),
    ),
        ),
  );

  buildPlayerAimTarget() {
    final name = Container(
      alignment: Alignment.center,
      width: 120,
      child: FittedBox(
        child: GSContainer(
            child: buildWatch(player.playerAimTargetName, buildText)),
      ),
    );
    return Positioned(
        top: 16,
        left: 0,
        child: Container(
          width: gamestream.engine.screen.width,
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
        child: MMOItemImage(item: item, size: itemImageSize),
    );
  }

  buildItemHoverDialog({double edgePadding = 150}) => buildWatch(
      itemHover,
      (item) => item == null
          ? Positioned(child: nothing, top: 0, left: 0,)
          : Positioned(
              left: gamestream.engine.mousePositionX < gamestream.engine.screenCenterX ? edgePadding : null,
              right: gamestream.engine.mousePositionX > gamestream.engine.screenCenterX ? edgePadding : null,
              top: gamestream.engine.mousePositionY < gamestream.engine.screenCenterY ? edgePadding : null,
              bottom: gamestream.engine.mousePositionY > gamestream.engine.screenCenterY ? edgePadding : null,
            child: GSContainer(
                width: 270,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildText(item.name.replaceAll('_', ' '), size: 26, color: Colors.white.withOpacity(0.8)),
                        width8,
                        MMOItemImage(item: item, size: 64),
                      ],
                    ),
                  ),
                  height16,
                  buildItemRow('damage', item.damage),
                  buildItemRow('cooldown', item.cooldown),
                  buildItemRow('range', item.range),
                  buildItemRow('health', item.health),
                  buildItemRow('movement', item.movement * 10),
                  if (item.attackType != null)
                    buildItemRow('attack type', item.attackType!.name),
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

  Widget buildPlayerItems() => buildInventory(
    child: buildWatch(
        itemsChangedNotifier,
        (_) => GSContainer(
            child: Row(
              children: [
                Column(
                    children: List.generate(
                        items.length ~/ 2, (index) => buildItemImageAtIndex(index),
                        growable: false)
                ),
                width8,
                Column(
                    children: List.generate(
                        items.length ~/ 2, (index) => buildItemImageAtIndex(index + (items.length ~/ 2)),
                        growable: false)
                ),
              ],
            ))
    ),
  );

  Widget buildInventory({required Widget child}) =>
      buildWatch(
        playerInventoryOpen,
        (inventoryOpen) => inventoryOpen ? child : nothing,
      );

  Widget buildPlayerEquipped() => buildInventory(
    child: GSContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildWatch(equippedHead, (equipped) => onPressed(
              onRightClick: equipped == null ? null : dropEquippedHead,
              action: equipped == null ? null : null,
              child: MMOItemImage(item: equipped, size: 64))),
          buildWatch(equippedBody, (equipped) => onPressed(
              onRightClick: equipped == null ? null : dropEquippedBody,
              child: MMOItemImage(item: equipped, size: 64))),
          buildWatch(equippedLegs, (equipped) => onPressed(
              onRightClick: equipped == null ? null : dropEquippedLegs,
              child: MMOItemImage(item: equipped, size: 64))),
      ],),
    ),
  );

  Widget buildSkillPointsRemaining() => buildWatch(playerSkillPoints, (skillPoints) {
       if (skillPoints == 0)
         return nothing;

       return onPressed(
           action: toggleTalentsDialog,
           child: GSContainer(child: buildText('Skills: $skillPoints')));
    });

  Widget buildPlayerHealthBar(){
    const width = 200.0;
    const height = 40.0;
     return Tooltip(
       message: 'Health',
       child: buildWatch(player.maxHealth, (maxHealth) {
         if (maxHealth == 0) return nothing;
         return buildWatch(player.health, (health) {
           return Container(
             width: width,
             height: height,
             child: Stack(
               children: [
                 Container(
                   width: width,
                   height: height,
                   color: Colors.white,
                 ),
                 Container(
                   width: width * (health / maxHealth),
                   height: height,
                   color: Colors.green,
                 ),
                 Container(
                     width: width,
                     height: height,
                     alignment: Alignment.center,
                     child: buildText('$health / $maxHealth', color: GameStyle.Container_Color),
                 ),
               ],
             ),
           );
         });
       }),
     );
  }

  Widget buildPlayerLevel({double size = 50}) =>
      Tooltip(
        message: 'Level',
        child: GSContainer(
          width: size,
          height: size,
          rounded: true,
          child: buildWatch(playerLevel, (level) => buildText(level))
        ),
      );

  Widget buildPlayerExperienceBar({double width = 150, double height = 30}) => Tooltip(
    message: 'Experience',
    child: buildBorder(
          width: 2,
          color: Colors.white,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.centerLeft,
            child: Container(
              color: Colors.transparent,
              child: buildWatch(
                      playerExperienceRequired,
                      (experienceRequired) =>
                          buildWatch(playerExperience, (experience) {
                            if (experienceRequired <= 0) return nothing;

                            final percentage =
                                clamp(experience / experienceRequired, 0, 1);
                            return Container(
                                color: Colors.white,
                                width: width * percentage, height: height);
                          })))
        )
        ),
  );

  Widget buildPlayerTalentsDialog() => buildWatch(
      playerTalentsChangedNotifier,
      (_) => buildWatch(
          playerSkillsDialogOpen,
          (playersDialogOpen) => !playersDialogOpen
              ? nothing
              : GSContainer(
                  width: 500,
                  height: gamestream.engine.screen.height - 250,
                  alignment: Alignment.topLeft,
                  child: GridView.count(
                      crossAxisCount: 3,
                      children: MMOTalentType.rootValues
                          .map((talentType) => GSContainer(
                                  child: Column(
                                children: talentType.children
                                    .map(buildTalent)
                                    .toList(growable: false),
                              )))
                          .toList(growable: false)))));

  Widget buildTalent(MMOTalentType talent){

    if (talentUnlocked(talent)){
      return Tooltip(
          message: '(UNLOCKED)\n${talent.description}',
          child: buildText(talent.name, color: Colors.green));
    }

    if (talentCanBeUnlocked(talent)) {
      return Tooltip(
        message: talent.description,
        child: onPressed(
            action: () => unlockTalent(talent),
            child: buildText(talent.name, color: Colors.grey)
            ),
      );
    }

    return Tooltip(
        message: talent.description,
        child: buildText(talent.name, color: Colors.grey));
  }

  Widget buildPlayerInventory() {
    return Column(children: [
      buildPlayerEquipped(),
      // buildPlayerTalentsDialog()
    ],);
  }

  Widget buildPlayerStatsRow() => Row(
      children: [
        buildSkillPointsRemaining(),
        width8,
        buildPlayerLevel(),
        width8,
        buildPlayerExperienceBar(),
        width8,
        buildPlayerHealthBar(),
      ],
    );

  Widget buildInventoryButton() => onPressed(
        action: toggleInventoryOpen,
        child: GSContainer(child: buildText('INV')));

}

