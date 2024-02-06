
import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_skill_type.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/website/widgets/gs_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'package:lemon_watch/src.dart';
import 'ui/containers/build_container_item_hover.dart';
import 'ui/containers/build_container_player_front.dart';
import 'ui/widgets/src.dart';

class AmuletUI {
  static const itemImageSize = 64.0;
  static const margin1 = 16.0;
  static const margin2 = 130.0;
  static const margin3 = 315.0;
  static const margin4 = 560.0;
  static const barWidth = 228.0;
  static const barHeight = 16.0;

  final Amulet amulet;

  AmuletUI(this.amulet);

  Widget buildAmuletUI() {

    final basic = MouseRegion(
      cursor: SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.translucent,
    );

    final translucent = MouseRegion(
      cursor: SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.translucent,
    );

    final gestureDetector = GestureDetector(
      behavior: HitTestBehavior.translucent,
    );

    return GSFullscreen(
    child: Stack(alignment: Alignment.center, children: [
      Positioned(
        top: 0,
        left: 0,
        child: GSFullscreen(
          child: buildWatch(amulet.cursor, (cursor){
            if (cursor == SystemMouseCursors.grab){
              amulet.engine.cursorType.value = CursorType.Click;
              return gestureDetector;
            }
            if (cursor == SystemMouseCursors.basic){
              amulet.engine.cursorType.value = CursorType.Basic;
              return basic;
            }
            return translucent;
          }),
        ),
      ),
          buildWindowQuest(),
          buildDialogTalk(),
          buildPositionedWorldMap(),
          buildPositionedPlayerHealthAndWeapons(),
          buildPlayerAimTarget(),
          Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildButtonPlayerStats(),
                  width8,
                  buildButtonQuest(),
                ],
              ),
          ),
          Positioned(
              top: 8,
              left: 8,
              child:
              buildWatch(amulet.aimTargetItemType, buildWindowAmuletItemStats),
          ),
          Positioned(
              bottom: 60,
              left: 8,
              child: buildWindowPlayerStats(),
          ),
          buildPositionedMessage(),
          Positioned(
            top: margin2,
            child: Container(
              width: amulet.engine.screen.width,
              alignment: Alignment.center,
              child: buildError(),
            ),
          ),
          buildOverlayScreenColor()
        ]),
  );
  }

  Positioned buildOverlayScreenColor() {
    return Positioned(
            top: 0,
            left: 0,
            child: IgnorePointer(
              child: buildWatch(amulet.screenColor, (color) => Container(
                    width: amulet.engine.screen.width,
                    height: amulet.engine.screen.height,
                    color: color,

                  )
              ),
            )
        );
  }

  Widget buildWindowQuest() => buildWatch(amulet.windowVisibleQuests, (visible) {
      if (!visible){
        return nothing;
      }
      return Positioned(
        top: 8,
        child: GSContainer(
          width: 300,
          height: 200,
          child: Column(
            children: [
              Row(
                children: [
                  buildText('QUEST'),
                  fillSpace,
                  onPressed(
                    action: amulet.windowVisibleQuests.setFalse,
                    child: buildText('X', color: Colors.orange),
                  ),
                ],
              ),
              alignCenter(
                child: buildWatch(
                  amulet.questMain,
                  (questMain) => buildText(questMain.instructions)
                ),
              ),
            ],
          ),
        ),
      );
    });

  Positioned buildPositionedPlayerHealthAndWeapons() {
    return Positioned(
          bottom: 4,
          left: 0,
          child: Container(
            width: amulet.engine.screen.width,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildControlSkillTypeLeft(),
                width4,
                GSContainer(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      buildPlayerHealthBar(),
                      height2,
                      buildPlayerMagicBar(),
                      height2,
                      buildEquippedAmuletItems(),
                    ],
                  ),
                ),
                width4,
                buildControlSkillTypeRight(),
              ],
            ),
          ),
        );
  }

  Positioned buildPositionedWorldMap() => Positioned(
          bottom: 8,
          right: 8,
          child: Builder(
            builder: (context) {
              final small = AmuletWorldMap(amulet: amulet, size: 200);
              final large = AmuletWorldMap(amulet: amulet, size: 400);
              return onPressed(
                action: amulet.worldMapLarge.toggle,
                child: buildWatch(amulet.worldMapLarge, (bool isLarge)
                  => isLarge ? large : small
                ),
              );
            }
          ),
        );

  Positioned buildPositionedMessage() => Positioned(
      top: 0,
      left: 0,
      child: buildWatch(amulet.messageIndex, (int messageIndex) {
        if (messageIndex == -1) {
          return nothing;
        }
        final messages = amulet.messages;
        return GSFullscreen(
          alignment: Alignment.center,
          child: GSContainer(
            width: 400,
            height: 400 * goldenRatio_0618,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                        child: buildText(messages[messageIndex],
                            color: Colors.white70))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    onPressed(
                      action: amulet.messageNext,
                      child: buildText(messageIndex + 1 >= messages.length
                          ? 'Okay'
                          : 'Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }));

  Widget buildPositionedAmuletItemHover()
  => buildContainerAmuletItemHover(amulet: amulet);

  Widget buildPositionedAmuletItemInformation() {

    return Positioned(
        top: 8,
        left: 8,
        child: buildWatch(amulet.aimTargetItemTypeCurrent, (current) {
          return buildWatch(amulet.aimTargetItemType, (target) =>
            current == null ? nothing : buildContainerCompareItems(current, target));
        }
        ),
      );
  }


  Widget buildRow(String column1, Widget column2, Widget? column3) {
    const width1 = 80.0;
    const width = 130.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (column1.isEmpty)
            const SizedBox(width: width1),
          if (column1.isNotEmpty)
          Container(
              alignment: Alignment.centerLeft,
              color: Colors.black12,
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.only(right: 2),
              width: width1, child: buildText(column1, color: Colors.white70)),
          width4,
          Container(width: width, child: column2),
          if (column3 != null)
          width4,
          if (column3 != null)
          Container(width: width, child: column3),
        ],
      ),
    );
  }

  Widget buildRowInt(
      String column1,
      int? column2,
      int? column3,
      ) =>
      buildRowText(column1, column2, column3,
        column2Color: compareIntGreater(column2, column3),
        column3Color: compareIntGreater(column3, column2),
      );

  Widget buildRowIntReverse(
      String column1,
      int? column2,
      int? column3,
      ) =>
      buildRowText(column1, column2, column3,
        column2Color: compareIntGreater(column3, column2),
        column3Color: compareIntGreater(column2, column3),
      );

  Widget buildRowText(
      String column1,
      dynamic column2,
      dynamic column3,
      {
        Color column2Color = Colors.white70,
        Color column3Color = Colors.white70,
      }) {
    if (column2 == null && column3 == null){
      return nothing;
    }
    return buildRow(
          column1,
          buildText(column2, color: column2Color),
          buildText(column3, color: column3Color),
        );
  }

  Widget buildContainerCompareItems(AmuletItem current, AmuletItem? target) =>
      Container(
      color: amulet.style.containerColor,
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow('', buildText('current', color: Colors.white54, italic: true), null),
            buildRow('',  AmuletItemImage(amuletItem: current, scale: 1.0), target == null ? nothing : AmuletItemImage(amuletItem: target, scale: 1.0)),
            buildRow('',
                buildText(current.label, color: mapItemQualityToColor(current.quality)),
                target == null ? null : buildText(target.label, color: mapItemQualityToColor(target.quality)),
            ),
            buildRowText('value', current.quality.name, target?.quality.name),
            buildRowText('skill', current.skillType?.name, target?.skillType?.name),
            buildRowInt('damage', current.damage, target?.damage),
            // buildRowInt('max dmg', current.damageMax, target?.damageMax),
            buildRowInt('range', current.range?.toInt(), target?.range?.toInt()),
            buildRowInt('radius', current.radius?.toInt(), target?.radius?.toInt()),
            buildRowIntReverse('duration', current.performDuration, target?.performDuration),
          ]),
    );

  static Color compareIntGreater(int? a, int? b){
    if (a == b){
      return Colors.white;
    }

    if (a == null && b != null){
      return Colors.red;
    }

    if (a != null && b == null){
      return Colors.green;
    }

    if (a != null && b != null && a > b){
      return Colors.green;
    }

    return Colors.red;

  }

  Widget buildContainerItemType(itemType) {
        if (itemType == null){
          return Positioned(child: nothing);
        }

        final damageMin = itemType.damageMin;
        final damageMax = itemType.damageMax;

        return Positioned(
            top: margin1,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              color: amulet.style.containerColor,
              child: Column(
                children: [
                  buildText(itemType.label),
                  if (damageMin != null && damageMax != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Damage'),
                        buildText('$damageMin - $damageMax'),
                      ],
                    )
                ],
              ),
            ) ,
          );
      }

  Widget buildError() {
    final color = Colors.red.withOpacity(0.7);
    return IgnorePointer(
        child: buildWatch(
            amulet.error, (error) => buildText(error, color: color)));
  }

  Positioned buildDialogTalk() {
    const width = 296.0;
    const height = width * goldenRatio_0618;

    final npcOptions = amulet.npcOptions;
    final npcText = amulet.npcText;

    final optionsClose =
        onPressed(action: amulet.nextNpcText, child: buildText('close'));

    final optionsNext =
        onPressed(action: amulet.nextNpcText, child: buildText('next'));

    final npcNameColor = Colors.orange.withOpacity(goldenRatio_0618);
    final npcName = buildWatch(amulet.npcName, (npcName) {
      if (npcName.isEmpty) {
        return nothing;
      }
      return GSContainer(
        color: Colors.black12,
        rounded: true,
        padding: const EdgeInsets.all(8),
        child: buildText(npcName, color: npcNameColor),
      );
    });
    final options = buildWatch(amulet.npcOptionsReads, (t) {
      if (npcOptions.isEmpty) {
        return optionsClose;
      }

      return Container(
        width: width,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: npcOptions
                .map((option) => onPressed(
                    action: () =>
                        amulet.selectTalkOption(npcOptions.indexOf(option)),
                    child: buildText(option)))
                .toList(growable: false)),
      );
    });

    return Positioned(
        bottom: margin2 + 10,
        child: buildWatch(
          amulet.playerInteracting,
          (interacting) => !interacting
              ? nothing
              : buildWatch(amulet.npcTextIndex, (npcTextIndex) {
                  if (npcTextIndex < 0) {
                    return nothing;
                  }

                  if (npcTextIndex >= npcText.length) {
                    return nothing;
                  }

                  return GSContainer(
                    width: width,
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        alignLeft(child: npcName),
                        Expanded(
                            child: Center(
                                child: buildText(npcText[npcTextIndex],
                                    color: Colors.white70))),
                        if (npcTextIndex + 1 < npcText.length) optionsNext,
                        if (npcTextIndex + 1 >= npcText.length) options,
                      ],
                    ),
                  );
                }),
        ));
  }

  Widget buildPlayerAimTarget() {
    const width = 250.0;
    const height = width * goldenRatio_0381 * goldenRatio_0381;

    final healthPercentageBox = buildWatch(
        amulet.player.aimTargetHealthPercentage,
        (healthPercentage) => Container(
              width: width * healthPercentage,
              height: height,
              color: amulet.colors.red_3,
            ));

    final fiendType = Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: buildWatch(amulet.aimTargetFiendType, (fiendType) {
        final resists = fiendType?.resists;
        if (resists == null){
          return nothing;
        }
        return buildText('resists ${resists.name}', size: 15, color: Colors.white70);
      }),
    );

    final itemQuality = Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: buildWatch(amulet.aimTargetItemType, (itemType) {
        if (itemType == null){
          return nothing;
        }
        return buildText(itemType.quality.name, size: 15, color: Colors.white70);
      }),
    );

    final name = Container(
      alignment: Alignment.centerLeft,
      height: height,
      color: amulet.colors.brownDark,
      padding: const EdgeInsets.all(4),
      width: width,
      child: Stack(
        children: [
          buildWatch(amulet.player.aimTargetAction, (targetAction) {
            if (targetAction != TargetAction.Attack) return nothing;

            return healthPercentageBox;
          }),
          Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildWatch(amulet.aimTargetItemType, (amuletItem) {
                  return FittedBox(
                    child: buildWatch(amulet.player.aimTargetName,
                            (name) => buildText(name.replaceAll('_', ' '),
                              color: amuletItem == null ? Colors.white : mapItemQualityToColor(amuletItem.quality)
                            )),
                  );
                }),
                width4,
                fiendType,
                itemQuality,
              ],
            ),
          ),
        ],
      ),
    );
    return Positioned(
        top: 16,
        left: 0,
        child: IgnorePointer(
          child: Container(
            width: amulet.engine.screen.width,
            alignment: Alignment.center,
            child: buildWatch(amulet.player.aimTargetSet, (t) {
              if (!t) return nothing;
              return name;
            }),
          ),
        ));
  }

  static Widget buildItemRow(String text, dynamic value) {
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

  Widget buildInventoryContainer({required Widget child}) => Container(
        child: child,
        padding: const EdgeInsets.all(2),
      );

  Widget buildEquippedAmuletItems() =>
      Container(
        width: barWidth,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildWatchAmuletItem(amulet.equippedWeapon, SlotType.Weapon),
            width8,
            buildWatchAmuletItem(amulet.equippedHelm, SlotType.Helm),
            width8,
            buildWatchAmuletItem(amulet.equippedArmor, SlotType.Armor),
            width8,
            buildWatchAmuletItem(amulet.equippedShoes, SlotType.Shoes),
          ],
        ),
      );

  Widget buildPlayerHealthBar() {

    return IgnorePointer(
      child: buildWatch(amulet.player.healthPercentage, (healthPercentage) {
        if (healthPercentage == 0) {
          return nothing;
        }
        return Container(
          width: barWidth,
          height: barHeight,
          color: Colors.black26,
          padding: const EdgeInsets.all(2),
          alignment: Alignment.centerLeft,
          child: Container(
            width: barWidth * healthPercentage,
            height: barHeight,
            color: Color.lerp(Colors.red, Colors.green, healthPercentage),
          ),
        );
      }),
    );
  }

  Widget buildPlayerMagicBar() {
    return IgnorePointer(
      child: buildWatch(amulet.playerMagicPercentage, (percentage) =>
        Container(
          width: barWidth,
          height: barHeight,
          color: Colors.black26,
          padding: const EdgeInsets.all(2),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: barWidth * percentage,
            height: barHeight,
            color: Colors.blue,
          ),
        )),
    );
  }

  Widget buildButtonClose({required Function action}) => onPressed(
      child: Container(
          width: 80,
          height: 80 * goldenRatio_0381,
          alignment: Alignment.center,
          color: Colors.black26,
          child: buildText('x', color: Colors.white70, size: 22)),
      action: action);

  Widget buildDialogTitle(String text) =>
      buildText(text, size: 28.0, color: Colors.white70);

  // Widget buildDialogPlayerInventory() {
  //   final inventoryItems = buildInventoryItems();
  //   final dialog = GSContainer(
  //     rounded: true,
  //     width: 450,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Container(
  //                 margin: const EdgeInsets.only(left: 5),
  //                 child: buildDialogTitle('CHEST')),
  //             buildButtonClose(
  //                 action: amulet.toggleInventoryOpen),
  //           ],
  //         ),
  //         height32,
  //         inventoryItems,
  //         // height16,
  //         // Row(
  //         //   crossAxisAlignment: CrossAxisAlignment.center,
  //         //   children: [
  //         //     buildInventoryEquipped(),
  //         //     // buildInventoryPlayerFront(),
  //         //     // buildPlayerTreasures(),
  //         //   ],
  //         // )
  //       ],
  //     ),
  //   );
  //
  //   // final inventoryButton = buildInventoryButton();
  //
  //   return MouseRegion(
  //     onEnter: (_) => amulet.setInventoryOpen(true),
  //     onExit: (_) {
  //       if (amulet.dragging.value == null) {
  //         amulet.setInventoryOpen(false);
  //       }
  //     },
  //     child: buildWatch(
  //         amulet.playerInventoryOpen,
  //         (inventoryOpen) => inventoryOpen
  //             ? dialog
  //             // : inventoryButton),
  //             : nothing),
  //   );
  // }

  Widget buildInventoryPlayerFront() => Container(
        width: 180 * goldenRatio_0618,
        height: 180,
        child: buildContainerPlayerFront(
          player: amulet.player,
          height: 180,
          borderColor: Colors.transparent,
        ),
      );

  static Color mapItemQualityToColor(ItemQuality itemQuality){
    switch (itemQuality){
      case ItemQuality.Common:
        return Colors.white;
      case ItemQuality.Rare:
        return Colors.blue;
      case ItemQuality.Legendary:
        return Colors.orange;
    }
  }

  Widget buildButtonPlayerStats() =>
      buildToggle(amulet.windowVisiblePlayerStats, 'stats');

  Widget buildWindowPlayerStats() {
    final windowOpen = GSContainer(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            child: onPressed(
              action: amulet.windowVisiblePlayerStats.setFalse,
              child: buildText('x'),
            ),
            alignment: Alignment.centerRight,
          ),
          buildWatch(amulet.player.name, (t) => buildText(t, color: Colors.orange, bold: true)),
          buildContainerPlayerCharacteristics(),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildRowTitle('Health'),
              buildWatch(amulet.player.health, buildRowValue),
              width2,
              buildRowValue('/'),
              width2,
              buildWatch(amulet.player.maxHealth, buildRowValue),
            ],
          ),
          Row(
            children: [
              buildRowTitle('Magic'),
              buildWatch(amulet.playerMagic, buildRowValue),
              width2,
              buildRowValue('/'),
              width2,
              buildWatch(amulet.playerMagicMax, buildRowValue),
            ],
          ),
          Row(
            children: [
              buildRowTitle('Magic Regen'),
              buildWatch(amulet.playerRegenMagic, buildRowValue),
            ],
          ),
          Row(
            children: [
              buildRowTitle('Health Regen'),
              buildWatch(amulet.playerRegenHealth, buildRowValue),
            ],
          ),
          Row(
            children: [
              buildRowTitle('Run Speed'),
              buildWatch(amulet.playerRunSpeed, buildRowValue),
            ],
          ),
        ],
      ),
    );

    return buildWatchVisible(amulet.windowVisiblePlayerStats, windowOpen);
  }

  Container buildContainerPlayerCharacteristics() {
    return Container(
          color: Colors.black12,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText('ARCHETYPES', color: Colors.white70),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildRowTitle('Knight'),
                  buildWatch(amulet.playerCharacteristics.knight, buildRowValue),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildRowTitle('Wizard'),
                  buildWatch(amulet.playerCharacteristics.wizard, buildRowValue),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildRowTitle('Rogue'),
                  buildWatch(amulet.playerCharacteristics.rogue, buildRowValue),
                ],
              ),
            ],
          ),
        );
  }

  Widget buildRowValue(dynamic value) => buildText(value, color: Colors.white70);

  static final titleColor =  Colors.orange;

  Widget buildRowTitle(dynamic value) => Container(
      margin: const EdgeInsets.only(right: 8),
      child: buildText(value, color: titleColor),
  );

  Widget buildWatchAmuletItem(Watch<AmuletItem?> watch, SlotType slotType) {

    return buildWatch(watch, (amuletItem) {
      const size = 50.0;
      final skillType = amuletItem?.skillType;

      return onPressed(
        onEnter: () => amulet.aimTargetItemType.value = amuletItem,
        onExit: () => amulet.aimTargetItemType.value = null,
        action: amuletItem == null
            ? null
            : () => amulet.selectSlotType(slotType),
        onRightClick: amuletItem == null
            ? null
            : () => amulet.dropAmuletItem(amuletItem),
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          color: Colors.white12,
          // padding: const EdgeInsets.all(2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Builder(
                  builder: (context) {

                    return buildWatch(amulet.playerSkillRight, (playerSkillRight) {
                      return Container(
                        alignment: Alignment.center,
                        color: playerSkillRight != amuletItem?.skillType ? Colors.black12 : Colors.white24,
                        padding: const EdgeInsets.all(2),
                        child: amuletItem == null
                            ? nothing
                            : AmuletItemImage(amuletItem: amuletItem, scale: size / 32,),
                      );


                    });
                  }
                ),
              ),
              if (skillType != null)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                      color: Colors.black,
                      width: 16,
                      height: 16,
                      child: buildSkillTypeIcon(skillType),
                  )
                ),
              // Positioned(
              //   bottom: 2,
              //   right: 2,
              //   child: activeBorder,
              // ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildSkillTypeIcon(SkillType skillType){
    final src = atlasSrcSkillType[skillType];
    if (src == null){
      throw Exception('atlasSrcSkillType[$skillType] is null');
    }
    return AmuletImage(
        srcX: src[0],
        srcY: src[1],
        width: src.tryGet(2) ?? iconSizeSkillType,
        height: src.tryGet(3) ?? iconSizeSkillType,
    );
  }

  Widget buildWindowAmuletItemStats(AmuletItem? amuletItem) {
    if (amuletItem == null) {
      return nothing;
    }

    final damage = amuletItem.damage;
    final maxHealth = amuletItem.maxHealth;
    final maxMagic = amuletItem.maxMagic;
    final regenHealth = amuletItem.regenHealth;
    final regenMagic = amuletItem.regenMagic;
    final runSpeed = amuletItem.runSpeed;
    final skillType = amuletItem.skillType;
    final range = amuletItem.range;
    final radius = amuletItem.radius;
    final performDuration = amuletItem.performDuration;

    final characteristics = amuletItem.characteristics;
    final charsKnight = characteristics.knight;
    final charsWizard = characteristics.wizard;
    final charsRogue = characteristics.rogue;

    return GSContainer(
      width: 200,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmuletItemImage(amuletItem: amuletItem, scale: 1.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildText(amuletItem.quality.name, color: mapItemQualityToColor(amuletItem.quality)),
              width4,
              buildText(amuletItem.label, color: mapItemQualityToColor(amuletItem.quality)),
            ],
          ),
          if (charsKnight != 0)
            buildRowTitleValue('knight', charsKnight),
          if (charsWizard != 0)
            buildRowTitleValue('wizard', charsWizard),
          if (charsRogue != 0)
            buildRowTitleValue('rogue', charsRogue),
          if (damage != null)
            buildRowTitleValue('damage', damage),
          if (performDuration != null)
            buildRowTitleValue('duration', '${formatFramesToSeconds(performDuration)}'),
          if (range != null)
            buildRowTitleValue('range', range),
          if (radius != null)
            buildRowTitleValue('radius', radius),
          if (maxHealth != null)
            buildRowTitleValue('max health', maxHealth),
          if (maxMagic != null)
            buildRowTitleValue('max magic', maxHealth),
          if (regenHealth != null)
            buildRowTitleValue('health regen', regenHealth),
          if (regenMagic != null)
            buildRowTitleValue('magic regen', regenMagic),
          if (runSpeed != null)
            buildRowTitleValue('run speed', runSpeed),
          if (skillType != null)
            buildRowTitleValue('skill', skillType.name),
        ],
      ),
    );
  }

  Widget buildRowTitleValue(dynamic title, dynamic value) =>
    Row(
      children: [
        buildRowTitle(title), buildRowValue(value),
      ],
    );

  Widget buildControlSkillTypeRight() => onPressed(
          action: () => amulet.ui.showDialogValues(
            title: 'Skills',
            values: amulet.playerSkillTypes,
            buildItem: (skillType) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildText(skillType.name),
                width16,
                buildSkillTypeIcon(skillType),
              ],
            ),
            onSelected: (skillType) => amulet.selectSkillTypeRight(skillType),
          ),
          child: buildWatch(amulet.playerSkillRight, buildContainerSkillType),
        );

  Widget buildControlSkillTypeLeft() => onPressed(
             action: () => amulet.ui.showDialogValues(
                 title: 'Skills',
                 values: amulet.playerSkillTypes,
               buildItem: (skillType) => Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   buildText(skillType.name),
                   width16,
                   buildSkillTypeIcon(skillType),
                 ],
               ),
                 onSelected: (skillType) => amulet.selectSkillTypeLeft(skillType),
             ),
             child: buildWatch(amulet.playerSkillLeft, buildContainerSkillType),
         );

  Widget buildContainerSkillType(SkillType skillType) =>
      Container(
        width: 94,
        height: 94,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        color: amulet.style.containerColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildText(skillType.name, color: Colors.white70),
            height8,
            buildSkillTypeIcon(skillType),
          ],
        ),
      );

  Widget buildButtonQuest() =>
      buildToggle(amulet.windowVisibleQuests, 'quest');

  Widget buildToggle(WatchBool watch, String text) =>
      onPressed(
        action: watch.toggle,
        child: GSContainer(
          padding: const EdgeInsets.all(8),
          child: Builder(
              builder: (context) => buildWatch(watch,
                        (statsVisible) => buildText(text, color: statsVisible ? Colors.white : Colors.white54))
          ),
        ),
      );
}

String formatFramesToSeconds(int frames){
  const fps = 45;
  return '${(frames / fps).toStringAsFixed(2)} seconds';
}

Widget buildWatchVisible(Watch<bool> watch, Widget child, {bool condition = true}) =>
    buildWatch(watch, (t) => t == condition ? child : nothing);