
import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/classes/skill_type_stats.dart';
import 'package:amulet_flutter/amulet/ui/enums/quantify_tab.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_skill_type.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/website/widgets/gs_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'getters/get_src_caste_type.dart';
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
          // buildPositionedPlayerHealthAndWeapons(),
          Positioned(
              bottom: 8,
              child: buildPlayerSkillSlots(),
          ),
          Positioned(
            top: 8,
             child: buildPlayerAimNode(),
          ),
          buildPlayerAimTarget(),
          Positioned(
              top: 8,
              left: 8,
              child: buildWindowFlask()
          ),
          Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildToggleEquipment(),
                  width8,
                  buildTogglePlayerStats(),
                  width8,
                  buildTogglePlayerSkills(),
                  width8,
                  buildTogglePlayerQuest(),
                ],
              ),
          ),
          Positioned(
              top: 8,
              left: 8,
              child:
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildWatch(amulet.aimTargetItemTypeComparison, buildWindowAmuletItemStats),
                  width8,
                  buildWatch(amulet.aimTargetItemType, buildWindowAmuletItemStats),
                ],
              ),
          ),
          Positioned(
              bottom: 64,
              left: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildWindowPlayerEquipped(),
                  buildWatchVisible(
                      amulet.windowVisiblePlayerStats,
                      buildWindowPlayerStats(),
                  ),
                  buildWindowPlayerSkills()
                ],
              ),
          ),
          buildPositionedMessage(),
          buildOverlayScreenColor(),
          Positioned(
            top: margin2,
            child: Container(
              width: amulet.engine.screen.width,
              alignment: Alignment.center,
              child: buildError(),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child:
            buildWatch(amulet.windowVisibleQuantify, (visible){
              return visible ? buildWindowQuantify() : nothing;
            }),
          ),
          Positioned(
              top: 50,
              child: buildWatch(amulet.windowVisibleHelp, (t) => t ? buildWindowHelp() : nothing)
          )
        ]),
  );
  }

  Widget buildWindowFlask() =>
      onPressed(
        hint: 'Drink Flask (Space)',
        action: amulet.useFlask,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black26,
              child: AmuletImage(
                srcX: 133,
                srcY: 163,
                width: 22,
                height: 26,
              ),
            ),
            buildWatchBar(
              watch: amulet.flaskPercentage,
              color: amulet.colors.aqua_2,
              barWidth: 100,
              barHeight: 20,
            ),
          ],
        ),
      );

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

  Widget buildWindowBorder({required Widget child}) {
    return buildBorder(
        width: 4,
        color: Palette.brownDarkX,
        child: child,
    );
  }

  Widget buildWindowQuest() => buildWatch(amulet.windowVisibleQuests, (visible) {
      if (!visible){
        return nothing;
      }
      return Positioned(
        top: 8,
        child: buildWindowBorder(
          child: GSContainer(
            width: 300,
            height: 200,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Tooltip(
                        message: 'Quest',
                        child: buildIconQuest(),
                    ),
                    buildButtonClose(amulet.windowVisibleQuests),
                  ],
                ),
                alignCenter(
                  child: buildWatch(
                    amulet.questMain,
                    (questMain) => buildText(questMain.instructions, color: Colors.white70)
                  ),
                ),
              ],
            ),
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
              crossAxisAlignment: CrossAxisAlignment.end,
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
                      // height2,
                      // buildPlayerSkillSlots(),
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
      Column(
        children: [
          buildWatchAmuletItem(amulet.equippedWeapon, SlotType.Weapon),
          height8,
          buildWatchAmuletItem(amulet.equippedHelm, SlotType.Helm),
          height8,
          buildWatchAmuletItem(amulet.equippedArmor, SlotType.Armor),
          height8,
          buildWatchAmuletItem(amulet.equippedShoes, SlotType.Shoes),
        ],
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

  Widget buildWatchBar({
    required Watch<double> watch,
    required Color color,
    required double barWidth,
    required double barHeight
  }) =>
      IgnorePointer(
      child: buildWatch(watch, (percentage) =>
        Container(
          width: barWidth,
          height: barHeight,
          color: Colors.black26,
          padding: const EdgeInsets.all(4),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: barWidth * percentage,
            height: barHeight,
            color: color,
          ),
        )),
    );

  Widget buildButtonClose(WatchBool watchBool) => onPressed(
      child: buildText('X', color: Colors.orange),
      action: watchBool.setFalse);

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
      case ItemQuality.Unique:
        return Colors.blue;
      // case ItemQuality.Rare:
      //   return Colors.deepOrange;
      // case ItemQuality.Legendary:
      //   return Colors.yellow;
    }
  }

  Widget buildIconItems() => AmuletImage(srcX: 725, srcY: 99, width: 22, height: 25);

  Widget buildIconItemsGrey() => AmuletImage(srcX: 693, srcY: 99, width: 22, height: 25);

  Widget buildToggleEquipment() {

    final active = buildToggleContainer(
      child: buildIconItems(),
      active: true,
    );

    final notActive = buildToggleContainer(
      child: buildIconItemsGrey(),
      active: false,
    );
    return onPressed(
      hint: 'Items (Q)',
      action: amulet.windowVisibleEquipment.toggle,
      child: buildWatch(
          amulet.windowVisibleEquipment,
              (windowVisibleEquipment) =>
          windowVisibleEquipment ? active : notActive),
    );
  }


  Widget buildIconPlayerStats() =>
      AmuletImage(srcX: 723, srcY: 131, width: 26, height: 26);

  Widget buildIconPlayerStatsGrey() =>
      AmuletImage(srcX: 691, srcY: 131, width: 26, height: 26);

  Widget buildTogglePlayerStats() {

    final active = buildToggleContainer(
      child: buildIconPlayerStats(),
      active: true,
    );

    final notActive = buildToggleContainer(
      child: buildIconPlayerStatsGrey(),
      active: false,
    );
    return onPressed(
      hint: 'Stats (W)',
      action: amulet.windowVisiblePlayerStats.toggle,
      child: buildWatch(
          amulet.windowVisiblePlayerStats,
              (windowVisibleEquipment) =>
          windowVisibleEquipment ? active : notActive),
    );
  }


  // Widget buildTogglePlayerStats() {
  //
  //   final active = AmuletImage(srcX: 723, srcY: 131, width: 26, height: 26);
  //   final notActive = buildIconPlayerStatsGrey();
  //
  //   return onPressed(
  //     hint: 'Stats (W)',
  //     action: amulet.windowVisiblePlayerStats.toggle,
  //     child: buildWatch(
  //         amulet.windowVisiblePlayerStats,
  //         (windowVisibleEquipment) =>
  //             windowVisibleEquipment ? active : notActive),
  //   );
  // }

  Widget buildIconSkills() => AmuletImage(srcX: 723, srcY: 39, width: 26, height: 20);

  Widget buildIconSkillsGrey({double scale = 1.0}) =>
      AmuletImage(
        srcX: 691,
        srcY: 39,
        width: 26,
        height: 20,
        scale: scale,
      );

  Widget buildTogglePlayerSkills() {

    final active = buildToggleContainer(
      child: buildIconSkills(),
      active: true,
    );

    final notActive = buildToggleContainer(
      child: buildIconSkillsGrey(),
      active: false,
    );

    return onPressed(
      hint: 'Skills (E)',
      action: amulet.windowVisiblePlayerSkills.toggle,
      child: buildWatch(
          amulet.windowVisiblePlayerSkills,
              (windowVisibleEquipment) =>
          windowVisibleEquipment ? active : notActive),
    );
  }

  Widget buildIconQuestGrey() =>
      AmuletImage(srcX: 691, srcY: 3, width: 26, height: 25);

  Widget buildIconQuest() =>
      AmuletImage(srcX: 723, srcY: 3, width: 26, height: 25);


  Widget buildToggleContainer({required Widget child, required bool active}){
    const size = 50.0;
    return Container(
      alignment: Alignment.center,
      width: size,
      height: size,
      child: child,
      color: active ? Palette.brownDark : Palette.brownDark.withOpacity(0.3),
    );
  }

  Widget buildTogglePlayerQuest() {

    final active = buildToggleContainer(
        child: buildIconQuest(),
        active: true,
    );

    final notActive = buildToggleContainer(
      child: buildIconQuestGrey(),
      active: false,
    );
    return onPressed(
      hint: 'Quests (R)',
      action: amulet.windowVisibleQuests.toggle,
      child: buildWatch(
          amulet.windowVisibleQuests,
          (windowVisibleEquipment) =>
              windowVisibleEquipment ? active : notActive),
    );
  }

  Widget buildWindowHelp() => GSContainer(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildDialogTitle('HELP'),
          onPressed(
              action: amulet.windowVisibleHelp.setFalse,
              child: buildText('X', color: Colors.orange)
          ),
        ],
      ),
      height16,
      buildSafeContainer(child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            buildText('CONTROLS', color: Colors.white70),
            buildText('Left Click: Run / Attack / Talk'),
            buildText('Right Click: Use Secondary Skill'),
            buildText('Left Shift: Stop'),
            buildText('Left Shift + Left Click: Attack'),
            buildText('Space: Drink Flask'),
        ],
      )),
    ],
  ));

  Widget buildSafeContainer({
    required Widget child,
  }) =>
      Container(
        constraints: BoxConstraints(maxHeight: amulet.engine.screen.height - 100),
        child: SingleChildScrollView(
          child: child,
        )
      );

  Widget buildWindowPlayerEquipped() =>
      buildWatchVisible(
          amulet.windowVisibleEquipment,
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: GSContainer(
                width: 100,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Items',
                          child: buildIconItems(),
                        ),
                        buildButtonClose(amulet.windowVisibleEquipment)
                      ],
                    ),
                    height16,
                    buildEquippedAmuletItems(),
                  ],
                )),
          ),
      );

  Widget buildWindowPlayerSkills(){
     return buildWatchVisible(amulet.windowVisiblePlayerSkills, buildWindowPlayerSkillStats());
  }

  Widget buildWindowPlayerStats() {
    return GSContainer(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                  message: 'Stats',
                  child: buildIconPlayerStats()),
              buildButtonClose(amulet.windowVisiblePlayerStats)
            ],
          ),
          height16,
          buildTextHeader('BONUSES'),
          buildWatch(amulet.playerHealthSteal, (healthSteal) {
            if (healthSteal <= 0){
              return nothing;
            }
            return Tooltip(
                message: 'Health Steal',
                child: buildRow(buildIconHealthSteal(), healthSteal));
          }),
          buildWatch(amulet.playerMagicSteal, (magicSteal) {
            if (magicSteal <= 0){
              return nothing;
            }
            return Tooltip(
                message: 'Magic Steal',
                child: buildRow(buildIconMagicSteal(), magicSteal));
          }),
          height16,
          buildContainerPlayerMastery(),
          height16,
          buildTextHeader('STATS'),
          Tooltip(
            message: 'Health',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildIconHealth(),
                width8,
                buildWatch(amulet.player.health, buildRowValue),
                width2,
                buildRowValue('/'),
                width2,
                buildWatch(amulet.player.maxHealth, buildRowValue),
              ],
            ),
          ),
          Tooltip(
            message: 'Magic',
            child: Row(
              children: [
                buildIconMagic(),
                width8,
                buildWatch(amulet.playerMagic, buildRowValue),
                width2,
                buildRowValue('/'),
                width2,
                buildWatch(amulet.playerMagicMax, buildRowValue),
              ],
            ),
          ),
          Tooltip(
            message: 'Health Regen',
            child: Row(
              children: [
                buildIconHealthRegen(),
                width8,
                buildWatch(amulet.playerRegenHealth, buildRowValue),
              ],
            ),
          ),
          Tooltip(
            message: 'Magic Regen',
            child: Row(
              children: [
                buildIconMagicRegen(),
                width8,
                buildWatch(amulet.playerRegenMagic, buildRowValue),
              ],
            ),
          ),
          Tooltip(
            message: 'Agility',
            child: Row(
              children: [
                buildIconAgility(),
                width8,
                buildWatch(amulet.playerAgility, buildRowValue),
              ],
            ),
          ),
          Tooltip(
            message: 'Critical Hit Points',
            child: Row(
              children: [
                buildIconCriticalHitPoints(),
                width8,
                buildWatch(amulet.playerCriticalHitPoints, buildRowValue),
              ],
            ),
          ),
          if (amulet.options.developMode)
          Tooltip(
            message: 'Player Perform Frame Velocity',
            child: Row(
              children: [
                buildText('FV'),
                width8,
                buildWatch(amulet.playerPerformFrameVelocity, buildRowValue),
              ],
            ),
          ),
          height16,
          buildText('WEAPON', color: Colors.white70),
          Tooltip(
            message: 'Range',
            child: buildWatch(amulet.playerWeaponRange, buildBarsRange),
          ),
          buildWatch(amulet.playerWeaponAttackSpeed, (attackSpeed){
            return Tooltip(
              message: attackSpeed == null ? 'Attack Speed' : 'Attack Speed: ${AttackSpeed.values[attackSpeed].name.replaceAll('_', ' ')}',
              child: Row(
                children: [
                  buildIconAttackSpeed(),
                  width8,
                  buildAttackSpeedValue(attackSpeed ?? -1),
                ],
              ),
            );
          }),
          buildWatch(amulet.playerWeaponAreaDamage, buildBarsAreaDamage),
          // height16,
          // buildEquippedAmuletItems(),
        ],
      ),
    );
  }

  Widget buildBarsRange(int? weaponRange) => Row(
        children: [
          buildIconRange(),
          width8,
          buildBars(
            total: 4,
            value: weaponRange ?? -1,
          )
        ],
      );

  Widget buildBarsAttackSpeed(int? value) => Row(
        children: [
          buildIconAttackSpeed(),
          width8,
          buildBars(
            total: 4,
            value: value ?? 0,
          )
        ],
      );

  Widget buildBarsAreaDamage(AreaDamage? value) => Tooltip(
    message: 'Area Damage',
    child: Row(
          children: [
            buildIconAreaDamage(),
            width8,
            buildBars(
              total: 4,
              value: value?.index ?? -1,
            )
          ],
        ),
  );

  Widget buildAttackSpeedValue(int value){
    return Row(children: List.generate(AttackSpeed.values.length, (index) {
       return Container(
         width: 4,
         height: 4 * goldenRatio_1618,
         margin: const EdgeInsets.only(right: 4),
         color: value >= index ? Colors.white70 : Colors.white24,
       );
    }));
  }

  Widget buildBars({required int total, required int value}) =>
      Row(children: List.generate(total, (index) => Container(
         width: 4,
         height: 4 * goldenRatio_1618,
         margin: const EdgeInsets.only(right: 4),
         color: value >= index ? Colors.white70 : Colors.white24,
       )));

  Widget buildIconAgility() =>
      AmuletImage(srcX: 768, srcY: 64, width: 16, height: 16);

  Widget buildIconMagicRegen() =>
      AmuletImage(srcX: 768, srcY: 48, width: 16, height: 16);

  Widget buildIconHealth() =>
      AmuletImage(srcX: 768, srcY: 0, width: 16, height: 16);

  Widget buildIconHealAmount() =>
      AmuletImage(srcX: 768, srcY: 320, width: 16, height: 16);



  // Widget buildIconDuration() =>
  //     AmuletImage(srcX: 769, srcY: 65, width: 16, height: 16);

  Widget buildIconMagic() =>
      AmuletImage(srcX: 768, srcY: 16, width: 16, height: 16);

  Widget buildIconHealthRegen() =>
      AmuletImage(srcX: 768, srcY: 32, width: 16, height: 16);

  Widget buildWindowPlayerSkillStats() =>
      buildWatch(amulet.playerSkillTypeStatsNotifier, (t) => Container(
        padding: const EdgeInsets.all(8),
        width: 170,
        color: amulet.style.containerColor,
        child: buildSafeContainer(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                      message: 'Skills',
                      child: buildIconSkills()),
                  buildButtonClose(amulet.windowVisiblePlayerSkills)
                ],
              ),
              ...amulet.playerSkillTypeStats.map((skillTypeStats) =>
              skillTypeStats.unlocked && skillTypeStats.skillType != SkillType.None
                  ? buildContainerSkillTypeStats(skillTypeStats)
                  : nothing).toList(growable: false)
            ],
          ),
        )
      ),
      );

  Widget buildContainerPlayerMastery() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildText('MASTERY', color: Colors.white70),
      Tooltip(
        message: 'Sword',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildIconCasteType(CasteType.Sword),
            width8,
            buildWatch(
                amulet.playerMastery.sword, buildRowValue),
          ],
        ),
      ),
      height4,
      Tooltip(
        message: 'Staff',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildIconCasteType(CasteType.Staff),
            width8,
            buildWatch(
                amulet.playerMastery.staff,
                buildRowValue,
            ),
          ],
        ),
      ),
      height4,
      Tooltip(
        message: 'Bow',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildIconCasteType(CasteType.Bow),
            width8,
            buildWatch(
                amulet.playerMastery.bow, buildRowValue,
            ),
          ],
        ),
      ),
      height4,
      Tooltip(
        message: 'Caste',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildIconCasteType(CasteType.Caste),
            width8,
            buildWatch(
              amulet.playerMastery.caste,
              buildRowValue,
            ),
          ],
        ),
      ),
    ],
  );

  Widget buildRowValue(dynamic value) => buildText(value, color: Colors.white70);

  static final titleColor =  Colors.orange;

  Widget buildRowTitle(dynamic value) => Container(
      margin: const EdgeInsets.only(right: 8),
      child: buildText(value, color: titleColor),
  );

  Widget buildWatchAmuletItem(Watch<AmuletItem?> watch, SlotType slotType) {

    return buildWatch(watch, (amuletItem) {
      const size = 50.0;
      if (amuletItem == null){
        return Container(
          width: size,
          height: size,
          color: Colors.black12,
        );
      }

      final skillType = amuletItem.skillType;

      return onPressed(
        onEnter: () {
          return amulet.aimTargetItemType.value = amuletItem;
        },
        onExit: () => amulet.aimTargetItemType.value = null,
        // action: amuletItem == null
        //     ? null
        //     : () => amulet.selectSlotType(slotType),
        action: () => amulet.dropAmuletItem(amuletItem),
        onRightClick: () => amulet.dropAmuletItem(amuletItem),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: Colors.black12,
          // padding: const EdgeInsets.all(2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: AmuletItemImage(amuletItem: amuletItem, scale: size / 32,),
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

  Widget buildIconHealthCost() =>
      AmuletImage(
        srcX: 768,
        srcY: 208,
        width: 16,
        height: 16,
      );

  Widget buildIconMagicCost() =>
      AmuletImage(
        srcX: 768,
        srcY: 224,
        width: 16,
        height: 16,
      );

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

    final healthSteal = amuletItem.healthSteal;
    final magicSteal = amuletItem.magicSteal;
    final damage = amuletItem.damage;
    final maxHealth = amuletItem.maxHealth;
    final maxMagic = amuletItem.maxMagic;
    final regenHealth = amuletItem.regenHealth;
    final regenMagic = amuletItem.regenMagic;
    final agility = amuletItem.agility;
    final skillType = amuletItem.skillType;
    final range = amuletItem.range;
    final areaDamage = amuletItem.areaDamage;
    final attackSpeed = amuletItem.attackSpeed;
    final slotType = amuletItem.slotType;
    final masterySword = amuletItem.masterySword;
    final masteryStaff = amuletItem.masteryStaff;
    final masteryBow = amuletItem.masteryBow;
    final masteryCaste = amuletItem.masteryCaste;
    final criticalHitPoints = amuletItem.criticalHitPoints;
    final equippedItemType = amulet.getEquippedItemType(slotType);

    return GSContainer(
      width: 170,
      // height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AmuletItemImage(amuletItem: amuletItem, scale: 1.0),
              Row(
                children: [
                  // buildText(amuletItem.quality.name),
                  // width8,
                  buildText(slotType.name),
                ],
              ),
            ],
          ),
          buildText(amuletItem.label, color: mapItemQualityToColor(amuletItem.quality)),
          Row(children: [
            if (masterySword != 0)
              buildRow(buildIconCasteType(CasteType.Sword), masterySword),
            width8,
            if (masteryStaff != 0)
              buildRow(buildIconCasteType(CasteType.Staff), masteryStaff),
          ],),
          Row(children: [
            if (masteryBow != 0)
              buildRow(buildIconCasteType(CasteType.Bow), masteryBow),
            width8,
            if (masteryCaste != 0)
              buildRow(buildIconCasteType(CasteType.Caste), masteryCaste),
          ],),

          if (damage != null)
            buildRow(buildIconDamage(), damage),
          if (range != null)
            buildBarsRange(range.index),
          if (attackSpeed != null)
            buildBarsAttackSpeed(attackSpeed.index),
          if (areaDamage != null)
            buildBarsAreaDamage(areaDamage),
          if (maxHealth != null && maxHealth > 0)
            buildRow(buildIconHealth(), maxHealth),
          if (maxMagic != null && maxMagic > 0)
            buildRow(buildIconMagic(), maxMagic),
          if (regenHealth != null && regenHealth > 0)
            buildRow(buildIconHealthRegen(), regenHealth),
          if (regenMagic != null && regenMagic > 0)
            buildRow(buildIconMagicRegen(), regenMagic),
          if (agility != null)
            buildRow(buildIconAgility(), agility),
          if (skillType != null)
            buildRow(buildSkillTypeIcon(skillType), skillType.name.replaceAll('_', ' ')),
          if (healthSteal > 0)
            buildRow(buildIconHealthSteal(), healthSteal),
          if (magicSteal > 0)
            buildRow(buildIconMagicSteal(), magicSteal),
          if (criticalHitPoints > 0)
            buildRow(buildIconCriticalHitPoints(), criticalHitPoints),
          if (equippedItemType == amuletItem)
            alignRight(
              child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: buildText('EQUIPPED', color: Colors.green),
              ),
            ),
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

  Widget buildIconDamage() => AmuletImage(
        srcX: 768,
        srcY: 208,
        width: 16,
        height: 16,
    );

  Widget buildIconCasteType(CasteType casteType) =>
      AmuletImageSrc(src: getSrcCasteType(casteType));

  Widget buildContainerSkillTypeStats(SkillTypeStats skillTypeStats) {
    final skillType = skillTypeStats.skillType;
    return Container(
      color: Colors.white12,
      alignment: Alignment.center,
      width: 150,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildIconCasteType(skillType.casteType),
            ],
          ),
          Tooltip(
            message: 'Skill Name',
            child: buildRow(
                buildSkillTypeIcon(skillType),
                skillType.name.replaceAll('_', ' '),
            ),
          ),
          if (skillTypeStats.damageMin > 0 || skillTypeStats.damageMax > 0)
            Tooltip(
              message: 'Damage',
              child: buildRow(
                  buildIconDamage(),
                  '${skillTypeStats.damageMin} - ${skillTypeStats.damageMax}',
              ),
            ),
          if (skillTypeStats.magicCost > 0)
            Tooltip(
                message: 'Magic Cost',
                child: buildRow(
                    buildIconMagicCost(),
                    skillTypeStats.magicCost,
                )),
          // if (skillTypeStats.range > 0)
          //   Tooltip(
          //       message: 'Range',
          //       child: buildRow(buildIconRange(), skillTypeStats.range)
          //   ),
          if (skillTypeStats.amount > 0)
            Tooltip(
                message: getSkillTypeAmountToolTip(skillType),
                child: buildRow(
                    buildIconSkillTypeAmount(skillType),
                    skillTypeStats.amount,
                )
            ),
        ],
      ),
    );
  }


  Widget buildControlSkillTypeLeft() {
    final control = buildExpandableSkillType(
      onSelected: amulet.selectSkillTypeLeft,
      watch: amulet.playerSkillLeft,
      menuOpen: amulet.windowVisibleSkillLeft,
    );

    return control;

    // final bordered = buildBorder(child: control);
    //
    // return buildWatch(amulet.playerSkillActiveLeft, (playerSkillActiveLeft){
    //  return playerSkillActiveLeft ? bordered : control;
    // });

  }

  Widget buildControlSkillTypeRight() {
    final control = buildExpandableSkillType(
      onSelected: amulet.selectSkillTypeRight,
      watch: amulet.playerSkillRight,
      menuOpen: amulet.windowVisibleSkillRight,
    );
    return control;
    // final bordered = buildBorder(child: control);
    // return buildWatch(amulet.playerSkillActiveLeft, (playerSkillActiveLeft){
    //   return !playerSkillActiveLeft ? bordered : control;
    // });
  }

  static const containerSkillTypeWidth = 94.0;

  Widget buildContainerSkillType(SkillType skillType) =>
      Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        color: amulet.style.containerColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // buildText(skillType.name.replaceAll('_', ' '), color: Colors.white70),
            // height8,
            buildSkillTypeIcon(skillType),
          ],
        ),
      );

  Widget buildToggleHelp() =>
      buildToggle(amulet.windowVisibleHelp, 'help', hint: 'h');

  Widget buildExpandableSkillType({
    required void onSelected(SkillType SkillType),
    required Watch<SkillType> watch,
    required WatchBool menuOpen,
  }) {
    return MouseRegion(
      onExit: (_) => menuOpen.setFalse(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildWatch(menuOpen, (bool visible) {
            if (!visible) return nothing;
            return Column(
              children: amulet.playerSkillTypeStats
                  .where((e) => e.unlocked)
                  .toList(growable: false)
                  .map((e) => onPressed(
                        action: () {
                          onSelected(e.skillType);
                          menuOpen.setFalse();
                        },
                        child: MouseOver(builder: (mouseOver) {
                          return Container(
                              width: containerSkillTypeWidth,
                              padding: const EdgeInsets.all(8),
                              color: mouseOver
                                  ? amulet.style.containerColorDark
                                  : amulet.style.containerColor,
                              child: Column(
                                children: [
                                  buildWatch(watch, (t) {
                                    return FittedBox(
                                        child: buildText(
                                      e.skillType.name.replaceAll('_', ' '),
                                      color: t == e.skillType
                                          ? Colors.white
                                          : Colors.white70,
                                      bold: t == e.skillType,
                                    ));
                                  }),
                                  height8,
                                  buildSkillTypeIcon(e.skillType),
                                ],
                              ));
                        }),
                      ))
                  .toList(growable: false),
            );
          }),
          onPressed(
            onEnter: menuOpen.setTrue,
            action: menuOpen.toggle,
            child: buildWatch(watch, buildContainerSkillType),
          ),
        ],
      ),
    );
  }

  Widget buildWindowQuantify(){
     return GSContainer(
       child: buildWatch(amulet.windowQuantifyTab, (activeQuantifyTab) {
         return Column(
           children: [
              Row(
                children: QuantifyTab.values.map((e) {
                  return Container(
                    width: 120,
                    height: 50,
                    color: e == activeQuantifyTab ? Colors.black38 : Colors.black12,
                    alignment: Alignment.center,
                    child: onPressed(
                        action: () => amulet.windowQuantifyTab.value = e,
                        child: buildText(e.name),
                    ),
                  );
                }).toList(growable: false),
              ),
             Container(
               constraints: BoxConstraints(maxHeight: amulet.engine.screen.height - 150),
               child: SingleChildScrollView(
                 child: Column(
                   children: buildChildrenQuantifyTab(activeQuantifyTab),
                 ),
               ),
             )
           ],
         );
       }),
     );
  }

  List<Widget> buildChildrenQuantifyTab(QuantifyTab quantifyTab) =>
      switch (quantifyTab) {
        QuantifyTab.Amulet_Items => AmuletItem.sortedValues
            .map(buildAmuletItemElement)
            .toList(growable: false),
        QuantifyTab.Fiend_Types => FiendType.sortedValues
            .map(buildElementFiendType)
            .toList(growable: false)
      };

  Widget buildAmuletItemElement(AmuletItem amuletItem) => Container(
    margin: const EdgeInsets.only(top: 8),
    child: Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white12,
      child: Row(
          children: [
            Container(
                alignment: Alignment.centerLeft,
                width: 300,
                child: buildText(amuletItem.name),
            ),
            buildText(amuletItem.quantify),
          ],
        ),
    ),
  );

  Widget buildElementFiendType(FiendType fiendType) => Container(
    margin: const EdgeInsets.only(top: 8),
    child: Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white12,
      child: Row(
          children: [
            Container(
                alignment: Alignment.centerLeft,
                width: 300,
                child: buildText(fiendType.name),
            ),
            buildText('quantify: ${fiendType.quantify}'),
            width16,
            buildText('lvl: ${fiendType.level}'),
          ],
        ),
    ),
  );

  Widget buildIconRange() => AmuletImage(
        srcX: 768,
        srcY: 112,
        width: 16,
        height: 16,
    );

  Widget buildRow(Widget key, dynamic value) =>
      Row(
        children: [
          key,
          width8,
          buildText(value),
        ],
  );

  Widget buildIconSkillTypeAmount(SkillType skillType) =>
      switch (skillType) {
        SkillType.Heal => buildIconHealAmount(),
        SkillType.Split_Shot => AmuletImage(
              srcX: 768,
              srcY: 240,
              width: 16,
              height: 16,
          ),
        _ => buildText('Amount')
      };

  String? getSkillTypeAmountToolTip(SkillType skillType){
    switch (skillType){
      case SkillType.Split_Shot:
        return 'Total Arrows';
      case SkillType.Heal:
        return 'Heal Amount';
      default:
        return 'Amount';
    }
  }

  Widget buildIconHealthSteal() =>
      AmuletImage(srcX: 768, srcY: 256, width: 16, height: 16);

  Widget buildIconMagicSteal() =>
      AmuletImage(srcX: 768, srcY: 272, width: 16, height: 16);

  Widget buildIconAttackSpeed() =>
      AmuletImage(srcX: 768, srcY: 288, width: 16, height: 16);

  Widget buildIconAreaDamage() =>
      AmuletImage(srcX: 768, srcY: 304, width: 16, height: 16);

  Widget buildIconCriticalHitPoints() =>
      AmuletImage(srcX: 768, srcY: 336, width: 16, height: 16);

  String getAimNodeText(int index){
     final nodeType = amulet.scene.nodeTypes[index];
     final variation = amulet.scene.nodeVariations[index];

     switch (nodeType){
       case NodeType.Portal:
         return AmuletScene.values.tryGet(variation)?.name.replaceAll('_', ' ') ?? 'invalid AmuletScene index: $variation';
       case NodeType.Shrine:
         return 'Shrine';
       default:
         return '';
     }
  }

  Widget buildPlayerAimNode() {
    return buildWatch(amulet.player.aimNodeIndex, (aimNodeIndex) {
       if (aimNodeIndex == null) {
         return nothing;
       }
       return IgnorePointer(
           child: GSContainer(
               child: buildText(getAimNodeText(aimNodeIndex))
           )
       );
    });
  }

  Widget buildPlayerSkillSlots() => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildSkillSlot(amulet.skillSlot0, amulet.windowVisibleSkillSlot0),
          width8,
          buildSkillSlot(amulet.skillSlot1, amulet.windowVisibleSkillSlot1),
          width8,
          buildSkillSlot(amulet.skillSlot2, amulet.windowVisibleSkillSlot2),
          width8,
          buildSkillSlot(amulet.skillSlot3, amulet.windowVisibleSkillSlot3),
        ],
      );

  Widget buildSkillSlot(Watch<SkillType> watch, WatchBool menuOpen){

    final index = amulet.getSkillSlotIndex(watch);
    final icon = buildWatch(watch, buildSkillTypeIcon);
    const size = 50.0;

    final containerActive = Container(
      child: icon,
      color: Colors.white24,
      width: size,
      height: size,
      alignment: Alignment.center,
    );

    final containerInactive = Container(
      child: icon,
      color: Colors.black26,
      width: size,
      height: size,
      alignment: Alignment.center,
    );

    final changeButton = onPressed(
        action: () {
          amulet.ui.showDialogValues(
            title: 'Assign Skill',
            values: amulet.playerSkills,
            buildItem: (skillType) {
              return buildText(skillType.name);
            },
            onSelected: (skillType){
              amulet.setSkillSlotValue(
                index: index,
                skillType: skillType,
              );
            },
          );
        },
        child: Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
              color: Palette.brownDark.withOpacity(0.6),
              shape: BoxShape.circle
          ),

        ));

    final key = Positioned(
        bottom: 4,
        right: 4,
        child: buildText(const['A', 'S', 'D', 'F',].tryGet(index), size: 20));

    return MouseOver(
      builder: (mouseOver) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // if (mouseOver)
            // Container(
            //     margin: const EdgeInsets.only(bottom: 6),
            //     child: changeButton,
            // ),
            Stack(
              alignment: Alignment.center,
              children: [
                onPressed(
                  // hint: const['A', 'S', 'D', 'F'].tryGet(index),
                  action: () => amulet.setSkillSlotIndex(index),
                  child: buildWatch(amulet.playerSkillSlotIndex, (selectedIndex) =>
                  selectedIndex == index ? containerActive : containerInactive),
                ),
                if (mouseOver)
                  key,
              ],
            ),
          ],
        );
      }
    );
  }

  Widget buildToggle(WatchBool watch, String text, {String? hint}) => onPressed(
    hint: hint,
    action: watch.toggle,
    child: GSContainer(
      padding: const EdgeInsets.all(8),
      child: Builder(
          builder: (context) => buildWatch(
              watch,
                  (statsVisible) => buildText(text,
                  color: statsVisible ? Colors.white : Colors.white54))),
    ),
  );

  Widget buildTextHeader(String value) => buildText(value, color: Colors.white70);
}

String formatFramesToSeconds(int frames){
  const fps = 45;
  return '${(frames / fps).toStringAsFixed(2)} sec';
}

Widget buildWatchVisible(Watch<bool> watch, Widget child, {bool condition = true}) =>
    buildWatch(watch, (t) => t == condition ? child : nothing);