
import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/src.dart';
import 'package:amulet_flutter/amulet/ui/enums/quantify_tab.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/website/widgets/gs_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'ui/containers/build_container_player_front.dart';

class AmuletUI {
  static const itemImageSize = 64.0;
  static const margin1 = 16.0;
  static const margin2 = 130.0;
  static const margin3 = 315.0;
  static const margin4 = 560.0;
  static const barWidth = 136.0;
  static const barHeight = 10.0;

  final Amulet amulet;
  final filterSkillTypes = WatchBool(false);
  final iconCheckBoxTrue = AmuletImage(srcX: 560, srcY: 0, width: 16, height: 16);
  final iconCheckBoxFalse = AmuletImage(srcX: 560, srcY: 16, width: 16, height: 16);

  late final iconMagic = buildIconMagic();
  late final iconHealth = buildIconHealth();

  var visibleRightClickedToClear = true;
  var visibleRightClickedToDrop = true;

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
          buildDialogTalk(),
          buildPositionedWorldMap(),
          Positioned(
            top: 8,
             child: buildPlayerAimNode(),
          ),
          buildPlayerAimTarget(),
          Positioned(
              top: 8,
              left: 8,
              child: buildHudTopLeft(),
          ),
          Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildToggleEquipment(),
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
                  buildWatch(amulet.aimTargetItemType, buildCardAmuletItem),
                ],
              ),
          ),
          Positioned(
              bottom: 64,
              left: 8,
              child: buildHudBottomLeft(),
          ),


      Positioned(
          bottom: 100,
          child: buildWatchVisible(
            amulet.windowVisiblePlayerSkills,
            buildWindowPlayerSkills(),
          )
      ),
      Positioned(
        bottom: 8,
        child: buildWindowPlayerSkillSlots(),
      ),
          buildPositionedMessage(),
          buildWindowQuest(),
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

  Widget buildHudBottomLeft() =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildWatchVisible(
            amulet.windowVisibleEquipment,
            buildWindowPlayerEquipped(),
          ),
          // buildWatchVisible(
          //   amulet.windowVisiblePlayerStats,
          //   buildWindowPlayerStats(),
          // ),
        ],
      );

  Widget buildWindowPotions() =>
      Row(
        children: amulet.consumableSlots
            .map(buildSlotConsumable)
            .toList(growable: false),
      );

  Widget buildSlotConsumable(Watch<AmuletItem?> itemSlot) {
    const size = 30.0;

    final control = Positioned(
      child: buildWatch(itemSlot, (t) =>
          buildBorder(
            color: Colors.black26,
            width: 2,
            radius: BorderRadius.zero,
            child: onPressed(
              onRightClick: t == null ? null : () => amulet.dropConsumableSlot(itemSlot),
              action: t == null ? null : () => amulet.useConsumableSlot(itemSlot),
              child: Container(
                child: t == null ? nothing : AmuletItemImage(amuletItem: t, scale: 1),
                width: size,
                height: size,
                alignment: Alignment.center,
                color: Colors.black12,
              ),
            ),
          )
      ),
    );

    final shortKey = Positioned(
        bottom: 2,
        right: 2,
        child: IgnorePointer(
          child: Container(
              width: 16,
              height: 16,
              color: Palette.brownDark,
              alignment: Alignment.center,
              child: buildText(amulet.getConsumeSlotPhysicalKeyboardKey(itemSlot)?.name)),
        ));

    return MouseOver(
      builder: (mouseOver) {
        return Stack(
          alignment: Alignment.center,
          children: [
            control,
            if (mouseOver)
              shortKey,
          ],
        );
      }
    );
  }

  AmuletImage buildIconPotion() {
    return AmuletImage(
              srcX: 133,
              srcY: 163,
              width: 22,
              height: 26,
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
        return nothing;
      }),
    );

    // final itemQuality = Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 5),
    //   child: buildWatch(amulet.aimTargetItemType, (itemType) {
    //     if (itemType == null){
    //       return nothing;
    //     }
    //     return buildText(itemType.quality.name, size: 15, color: Colors.white70);
    //   }),
    // );

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
                // itemQuality,
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
            color: AmuletColors.Health,
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
            color: AmuletColors.Magic,
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

  // Widget buildTogglePlayerStats() {
  //
  //   final active = buildToggleContainer(
  //     child: buildIconPlayerStats(),
  //     active: true,
  //   );
  //
  //   final notActive = buildToggleContainer(
  //     child: buildIconPlayerStatsGrey(),
  //     active: false,
  //   );
  //   return onPressed(
  //     hint: 'Stats (W)',
  //     action: amulet.windowVisiblePlayerStats.toggle,
  //     child: buildWatch(
  //         amulet.windowVisiblePlayerStats,
  //             (windowVisibleEquipment) =>
  //         windowVisibleEquipment ? active : notActive),
  //   );
  // }


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
                Tooltip(
                  message: 'Health',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildIconHealth(),
                      width8,
                      buildWatch(amulet.player.health, (health) => buildText(health, color: AmuletColors.Health)),
                      width2,
                      buildText('/', color: AmuletColors.Health),
                      width2,
                      buildWatch(amulet.player.maxHealth, (health) => buildText(health, color: AmuletColors.Health)),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Magic',
                  child: Row(
                    children: [
                      buildIconMagic(),
                      width8,
                      buildWatch(amulet.playerMagic, (value) => buildText(value, color: AmuletColors.Magic)),
                      width2,
                      buildText('/', color: AmuletColors.Magic),
                      width2,
                      buildWatch(amulet.playerMagicMax, (value) => buildText(value, color: AmuletColors.Magic)),
                    ],
                  ),
                ),
                        // Tooltip(
                        //   message: 'Player Perform Frame Velocity',
                        //   child: Row(
                        //     children: [
                        //       buildText('FV'),
                        //       width8,
                        //       buildWatch(amulet.playerPerformFrameVelocity, buildRowValue),
                        //     ],
                        //   ),
                        // ),
                height16,
                buildEquippedAmuletItems(),
              ],
            )),
      );

  // Widget buildWindowPlayerStats() {
  //   return GSContainer(
  //     width: 120,
  //     margin: const EdgeInsets.only(right: 8),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Tooltip(
  //                 message: 'Stats',
  //                 child: buildIconPlayerStats()),
  //             buildButtonClose(amulet.windowVisiblePlayerStats)
  //           ],
  //         ),
  //         height16,
  //         buildTextHeader('STATS'),
  //         Tooltip(
  //           message: 'Health',
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               buildIconHealth(),
  //               width8,
  //               buildWatch(amulet.player.health, buildRowValue),
  //               width2,
  //               buildRowValue('/'),
  //               width2,
  //               buildWatch(amulet.player.maxHealth, buildRowValue),
  //             ],
  //           ),
  //         ),
  //         Tooltip(
  //           message: 'Magic',
  //           child: Row(
  //             children: [
  //               buildIconMagic(),
  //               width8,
  //               buildWatch(amulet.playerMagic, buildRowValue),
  //               width2,
  //               buildRowValue('/'),
  //               width2,
  //               buildWatch(amulet.playerMagicMax, buildRowValue),
  //             ],
  //           ),
  //         ),
  //         // Tooltip(
  //         //   message: 'Health Regen',
  //         //   child: Row(
  //         //     children: [
  //         //       buildIconHealthRegen(),
  //         //       width8,
  //         //       buildWatch(amulet.playerRegenHealth, buildRowValue),
  //         //     ],
  //         //   ),
  //         // ),
  //         // Tooltip(
  //         //   message: 'Magic Regen',
  //         //   child: Row(
  //         //     children: [
  //         //       buildIconMagicRegen(),
  //         //       width8,
  //         //       buildWatch(amulet.playerRegenMagic, buildRowValue),
  //         //     ],
  //         //   ),
  //         // ),
  //         // Tooltip(
  //         //   message: 'Agility',
  //         //   child: Row(
  //         //     children: [
  //         //       buildIconAgility(),
  //         //       width8,
  //         //       buildWatch(amulet.playerAgility, buildRowValue),
  //         //     ],
  //         //   ),
  //         // ),
  //         // Tooltip(
  //         //   message: 'Critical Hit Points',
  //         //   child: Row(
  //         //     children: [
  //         //       buildIconCriticalHitPoints(),
  //         //       width8,
  //         //       buildWatch(amulet.playerCriticalHitPoints, buildRowValue),
  //         //     ],
  //         //   ),
  //         // ),
  //         if (amulet.options.developMode)
  //         Tooltip(
  //           message: 'Player Perform Frame Velocity',
  //           child: Row(
  //             children: [
  //               buildText('FV'),
  //               width8,
  //               buildWatch(amulet.playerPerformFrameVelocity, buildRowValue),
  //             ],
  //           ),
  //         ),
  //         height16,
  //         buildText('WEAPON', color: Colors.white70),
  //         Tooltip(
  //           message: 'Range',
  //           child: buildWatch(amulet.playerWeaponRange, buildBarsRange),
  //         ),
  //         buildWatch(amulet.playerWeaponAttackSpeed, (attackSpeed){
  //           return Tooltip(
  //             message: attackSpeed == null ? 'Attack Speed' : 'Attack Speed: ${AttackSpeed.values[attackSpeed].name.replaceAll('_', ' ')}',
  //             child: Row(
  //               children: [
  //                 buildIconAttackSpeed(),
  //                 width8,
  //                 buildAttackSpeedValue(attackSpeed ?? -1),
  //               ],
  //             ),
  //           );
  //         }),
  //         buildWatch(amulet.playerWeaponAreaDamage, buildBarsAreaDamage),
  //         // height16,
  //         // buildEquippedAmuletItems(),
  //       ],
  //     ),
  //   );
  // }

  Widget buildBarsRange(int? weaponRange) => Row(
        children: [
          buildText('range'),
          width8,
          buildBars(
            total: 4,
            value: weaponRange ?? -1,
          )
        ],
      );

  Widget buildBarsAttackSpeed(int? value) => Row(
        children: [
          buildText('speed'),
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

  Widget buildIconMagic() =>
      AmuletImage(srcX: 768, srcY: 16, width: 16, height: 16);

  Widget buildIconHealthRegen() =>
      AmuletImage(srcX: 768, srcY: 32, width: 16, height: 16);

  Widget buildWindowPlayerSkills() => buildWindowBorder(
    child: GSContainer(
          width: 270,
          height: amulet.engine.screen.height - 180,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildHint(
                    child: buildIconSkills(),
                    text: 'Skills (${amulet.amuletKeys.toggleWindowSkills.name.toUpperCase()})',
                  ),
                  onPressed(
                    action: filterSkillTypes.toggle,
                    child: Row(
                      children: [
                        buildText('ALL'),
                        width8,
                        buildWatch(filterSkillTypes, buildIconCheckBox),
                      ],
                    ),
                  ),
                  buildButtonClose(amulet.windowVisiblePlayerSkills)
                ],
              ),
              height16,
              Container(
                // constraints: BoxConstraints(
                //   maxHeight: amulet.engine.screen.height - 270,
                // ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnCasteType(CasteType.Sword),
                    width8,
                    buildColumnCasteType(CasteType.Bow),
                    width8,
                    buildColumnCasteType(CasteType.Staff),
                    width8,
                    buildColumnCasteType(CasteType.Passive),
                  ],
                ),
              ),
            ],
          ),
        ),
  );

  Widget buildHint({
    required Widget child,
    required String text,
  }) =>
      buildMouseOverHint(
        child: child,
        panel: buildBorder(
            color: Colors.white70,
            width: 2,
            child: GSContainer(child: buildText(text))),
        getTop: () => -60,
        right: -50,
      );

  Widget buildMouseOverHint({
    required Widget child,
    required Widget panel,
    Function? onEnter,
    Function? onExit,
    double Function()? getTop,
    double? left,
    double? bottom,
    double? right,
  }) =>
      MouseOver(
        onEnter: onEnter,
          onExit: onExit,
          builder: (mouseOver) => Stack(
                clipBehavior: Clip.none,
                fit: StackFit.passthrough,
                children: [
                  child,
                  if (mouseOver)
                    Positioned(
                      top: getTop?.call(),
                      left: left,
                      bottom: bottom,
                      right: right,
                      child: panel,
                    ),
                ],
              ));

  Widget buildColumnCasteType(CasteType casteType) =>
      Container(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildMouseOverHint(
                child: buildIconCasteType(casteType),
                panel: buildBorder(
                  width: 2,
                  color: Colors.white70,
                  child: GSContainer(child: Row(
                    children: [
                      buildText(casteType.name),
                      width8,
                      buildText('Skills'),
                    ],
                  )),
                ),
                right: -40,
                getTop: () => -70,
            ),
            height32,
            Column(
                children: SkillType.values
                    .where((element) =>
                        !const [
                          SkillType.None,
                          SkillType.Strike,
                          SkillType.Shoot_Arrow,
                        ].contains(element) &&
                        element.casteType == casteType)
                    .map((skillType) {
              final value = buildWindowPlayerSkillsItem(skillType);
              final watchLevel = amulet.playerSkillTypeLevels[skillType] ??
                  (throw Exception());

              final unlocked = buildWatch(watchLevel, (level) {
                if (level <= 0) {
                  return nothing;
                }
                return value;
              });

              return buildWatch(filterSkillTypes, (filter) {
                if (filter) {
                  return unlocked;
                }
                return value;
              });
            }).toList(growable: false)),
          ],
        ),
      );


  static const Container_Size = 40.0;

  Widget buildWindowPlayerSkillsItem(SkillType skillType){

    final watchAssigned = amulet.playerSkillTypeSlotAssigned[skillType] ?? (throw Exception());
    final watchLevel = amulet.playerSkillTypeLevels[skillType] ?? (throw Exception());

     return buildWatch(watchAssigned, (assigned) {
       return buildWatch(watchLevel, (level) {
         final unlocked = level > 0;
         final child = onPressed(
           action: unlocked ? () => amulet.toggleSkillType(skillType) : null,
           child: Container(
             width: Container_Size,
             height: Container_Size,
             margin: const EdgeInsets.only(bottom: 6),
             child: Stack(
               clipBehavior: Clip.none,
               fit: StackFit.passthrough,
               children: [
                 Container(
                   width: Container_Size,
                   height: Container_Size,
                   color: unlocked ? Palette.brown_3 : Colors.transparent,
                 ),
                 // b,
                 Positioned(
                   child: Container(
                     width: Container_Size,
                     height: Container_Size,
                     alignment: Alignment.center,
                     child: buildIconSkillType(skillType),
                   ),
                 ),
                 if (level > 0)
                   Positioned(
                       bottom: 0,
                       right: 0,
                       child:   Container(
                           width: 20,
                           height: 20,
                           color: assigned ? Palette.teal_2 : Palette.brown_1,
                           alignment: Alignment.center,
                           child: buildText(level)))
               ],
             ),
           ),
         );

         final control =  buildMouseOverHint(
          onEnter: () {
            amulet.mouseOverSkillType = skillType;
          },
          onExit: () {
            amulet.mouseOverSkillType = null;
          },
          child: child,
          panel: Column(
            children: [
              if (level > 0)
                buildText('press A,S,D,F to assign'),
              buildCardSkillType(skillType),
            ],
          ),
          getTop: () {

            final mouseY = mouseOverEnterPosition?.dy;
            if (mouseY != null){
              if (mouseY > amulet.engine.screen.height * 0.66){
                return -200;
              }
              if (mouseY > amulet.engine.screen.height * 0.5){
                return -140;
              }
            }
            return -70;
          },
          right: Container_Size + 5,
        );

         if (unlocked){
           return Draggable(
             data: skillType,
             feedback: buildIconSkillType(skillType, dstX: 25, dstY: 25),
             child: control,
           );
         }

         return control;

       });
     });

  }

  Widget buildCardSkillType(SkillType skillType) {

    final level = amulet.getSkillTypeLevel(skillType);

    final levelColor = level > 0 ? Colors.white70 : Colors.red.withOpacity(0.7);

    final controlLevel = buildBorder(
        color: levelColor,
        padding: const EdgeInsets.all(4),
        child: buildText(level > 0 ? 'lvl $level' : 'locked', color: levelColor)
    );

    final controlSkillTitle = Container(
      color: Colors.black26,
      alignment: Alignment.center,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildIconSkillType(skillType),
          width8,
          Container(
              child: buildText(
                skillType.name.clean,
                underline: true,
                color: Colors.white70,
              )
          ),
        ],
      ),
    );

    final controlMagicCost = Container(
      margin: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          iconMagic,
          width4,
          buildText(skillType.magicCost, color: Palette.red_1),
        ],
      ),
    );

    const cardWidth = 182.0;

    final contents = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white10,
            child: buildTextValue(getSkillTypeDescription(skillType))),
        height8,
        if (level > 0)
          buildText('current'),
        if (level > 0)
          Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: buildText(
                getSkillTypeLevelDescription(skillType, level),
                color: getSkillTypeLevelDescriptionColor(skillType),
              )),
        if (level < 20) // max skill level
          buildText('next'),
        if (level < 20) // max skill level
          buildText(getSkillTypeLevelDescription(skillType, level + 1), color: getSkillTypeLevelDescriptionColor(skillType)),
      ],
    );

    final bottomRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (skillType.magicCost > 0)
          controlMagicCost,
        controlLevel,
      ],
    );

    return buildBorder(
      color: Colors.white70,
      width: 2,
      child: GSContainer(
          width: cardWidth,
          height: cardWidth * goldenRatio_1618,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCardHeader('${skillType.casteType.name} Skill'),
                  controlSkillTitle,
                  Container(
                      padding: const EdgeInsets.all(8),
                      child: contents),
                ],
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  child: bottomRow),
            ],
          )),
    );
  }

  Widget buildRowValue(dynamic value) => buildText(value, color: Colors.white70);

  static final titleColor =  Colors.orange;

  Widget buildRowTitle(dynamic value) => Container(
      margin: const EdgeInsets.only(right: 8),
      child: buildText(value, color: titleColor),
  );

  Widget buildWatchAmuletItem(Watch<AmuletItem?> watchAmuletItem, SlotType slotType) {

    return buildWatch(watchAmuletItem, (amuletItem) {
      const size = 50.0;
      if (amuletItem == null){
        return Container(
          width: size,
          height: size,
          color: Colors.black12,
        );
      }

      final button = onPressed(
        action: () => amulet.dropAmuletItem(amuletItem),
        onRightClick: () {
          visibleRightClickedToDrop = false;
          amulet.dropAmuletItem(amuletItem);
        },
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: Colors.black12,
          child: AmuletItemImage(amuletItem: amuletItem, scale: size / 32,),
        ),
      );

      return buildMouseOverHint(
          child: button,
          panel: Column(
            children: [
              if (visibleRightClickedToDrop)
                buildText('right click to drop'),
              buildCardAmuletItem(amuletItem),
            ],
          ),
          left: 90,
          bottom: 0,
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

  Widget buildIconSlotType(SlotType slotType) =>
      AmuletImageSrc(src: getSrcSlotType(slotType));

  Widget buildIconSkillType(SkillType skillType, {double dstX = 0, double dstY = 0}) =>
      AmuletImageSrc(src: getSrcSkillType(skillType), dstX: dstX, dstY: dstY);

  Widget buildCardAmuletItem(AmuletItem? amuletItem) {
    if (amuletItem == null) {
      return nothing;
    }

    final slotType = amuletItem.slotType;
    final equippedItemType = amulet.getEquippedItemType(slotType);
    final equipped = equippedItemType == amuletItem;

    return buildBorder(
      width: 2,
      color: Colors.white70,
      child: Container(
        width: 190,
        color: Palette.brownDark,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCardHeader('Item ${slotType.name}'),
            Container(
              padding: const EdgeInsets.all(4),
              color: Colors.black12,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AmuletItemImage(amuletItem: amuletItem, scale: 1.0),
                  width8,
                  buildText(amuletItem.label, color: mapItemQualityToColor(amuletItem.quality)),
                ],
              ),
            ),
            if (equipped)
              Container(
                  padding: const EdgeInsets.all(8),
                  child: buildCardAmuletItemEquipped(amuletItem)),
            if (equippedItemType != null && !equipped)
              Container(
                padding: const EdgeInsets.all(8),
                child: buildCardCompareAmuletItems(equippedItemType, amuletItem),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildCardCompareAmuletItems(AmuletItem current, AmuletItem next){

    final damageDiff = getDiff(next.damage, current.damage)?.toInt();
    final healthDiff = getDiff(next.maxHealth, current.maxHealth);
    final magicDiff = getDiff(next.maxMagic, current.maxMagic);

    return Column(
      children: [
          if (healthDiff != null)
            buildComparisonRow(
              lead: iconHealth,
              value: next.maxHealth,
              diff: healthDiff,
            ),
          if (magicDiff != null)
            buildComparisonRow(
              lead: iconMagic,
              value: next.maxMagic,
              diff: magicDiff,
            ),
          if (damageDiff != null)
            buildComparisonRow(
              lead: 'damage',
              value: next.damage,
              diff: damageDiff,
            ),

          height16,
          ...SkillType.values.map((skillType) {

            final currentLevel = current.skills[skillType] ?? 0;
            final nextLevel = next.skills[skillType] ?? 0;

            if (currentLevel == 0 && nextLevel == 0) {
              return nothing;
            }

            final levelDiff = getDiff(nextLevel, currentLevel);

            if (levelDiff == null){
              return nothing;
            }

            return Container(
              color: Colors.black12,
              padding: EdgeInsets.symmetric(vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              child: buildComparisonRow(
                lead: Row(children: [
                  Container(
                    color: Colors.black12,
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: buildIconSkillType(skillType)
                  ),
                  width8,
                  buildText(skillType.name.clean, color: Colors.white70, size: 15),
                ],),
                value: nextLevel,
                diff: levelDiff,
              ),
            );
          })
      ],
    );
  }


  Widget buildComparisonRow({
    required dynamic lead,
    required num? value,
    required num diff,
  }) =>
      Row(
        children: [
          if (lead is Widget)
            lead,
          if (lead is String)
            buildText(lead),
          width8,
          buildText(value?.toInt() ?? '0'),
          // width8,
          expanded,
          buildDiff(diff),
        ],
      );

  Widget buildDiff(num diff) =>
      buildText('${diff > 0 ? "+" : ""}${diff.toInt()}', color: getDiffColor(diff));

  Color getDiffColor(num diff){
    if (diff < 0) {
      return Colors.red;
    }
    if (diff > 0) {
      return Colors.green;
    }
    return Colors.white54;
  }

  double getDiffDouble(double? a, double? b){
     return (a ?? 0.0) - (b ?? 0.0);
  }

  num? getDiff(num? a, num? b){
    if (a == null && b == null) {
      return null;
    }

    if (a == 0 && b == 0) {
      return null;
    }

    return (a ?? 0.0) - (b ?? 0.0);
  }

  Widget buildCardAmuletItemEquipped(AmuletItem amuletItem){
    final damage = amuletItem.damage;
    final maxHealth = amuletItem.maxHealth;
    final maxMagic = amuletItem.maxMagic;
    final range = amuletItem.range;
    final attackSpeed = amuletItem.attackSpeed;

    return Column(
      children: [
        if (damage != null)
          buildRow(buildText('damage'), damage.toInt()),
        if (range != null)
          buildBarsRange(range.index),
        if (attackSpeed != null)
          buildBarsAttackSpeed(attackSpeed.index),
        if (maxHealth != null && maxHealth > 0)
          buildRow(buildIconHealth(), maxHealth),
        if (maxMagic != null && maxMagic > 0)
          buildRow(buildIconMagic(), maxMagic),
        height16,
        ...amuletItem.skills.entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                color: Colors.black26,
                child: buildIconSkillType(e.key)),
            width8,
            buildTextValue(e.key.name.clean),
            // width4,
            expanded,
            buildText('+${e.value}', color: Colors.green),
          ],),
        )),
        height16,
        alignRight(child: buildBorder(
            color: Colors.green,
            padding: const EdgeInsets.all(4),
            child: buildText('EQUIPPED', color: Colors.green)))
      ],
    );
  }

  Widget buildCardHeader(String text) => Container(
    color: Colors.orange,
    alignment: Alignment.center,
    child: buildText(text.toUpperCase(), color: Colors.black87),
    height: 30,
  );


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
            buildIconSkillType(skillType),
          ],
        ),
      );

  Widget buildToggleHelp() =>
      buildToggle(amulet.windowVisibleHelp, 'help', hint: 'h');

  // Widget buildExpandableSkillType({
  //   required void onSelected(SkillType SkillType),
  //   required Watch<SkillType> watch,
  //   required WatchBool menuOpen,
  // }) {
  //   return MouseRegion(
  //     onExit: (_) => menuOpen.setFalse(),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         buildWatch(menuOpen, (bool visible) {
  //           if (!visible) return nothing;
  //           return Column(
  //             children: amulet.playerSkillTypeStats
  //                 .where((e) => e.unlocked)
  //                 .toList(growable: false)
  //                 .map((e) => onPressed(
  //                       action: () {
  //                         onSelected(e.skillType);
  //                         menuOpen.setFalse();
  //                       },
  //                       child: MouseOver(builder: (mouseOver) {
  //                         return Container(
  //                             width: containerSkillTypeWidth,
  //                             padding: const EdgeInsets.all(8),
  //                             color: mouseOver
  //                                 ? amulet.style.containerColorDark
  //                                 : amulet.style.containerColor,
  //                             child: Column(
  //                               children: [
  //                                 buildWatch(watch, (t) {
  //                                   return FittedBox(
  //                                       child: buildText(
  //                                     e.skillType.name.replaceAll('_', ' '),
  //                                     color: t == e.skillType
  //                                         ? Colors.white
  //                                         : Colors.white70,
  //                                     bold: t == e.skillType,
  //                                   ));
  //                                 }),
  //                                 height8,
  //                                 buildSkillTypeIcon(e.skillType),
  //                               ],
  //                             ));
  //                       }),
  //                     ))
  //                 .toList(growable: false),
  //           );
  //         }),
  //         onPressed(
  //           onEnter: menuOpen.setTrue,
  //           action: menuOpen.toggle,
  //           child: buildWatch(watch, buildContainerSkillType),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  Widget buildWindowPlayerSkillSlots() => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildSkillSlot(amulet.skillSlot0),
          width8,
          buildSkillSlot(amulet.skillSlot1),
          width8,
          buildSkillSlot(amulet.skillSlot2),
          width8,
          buildSkillSlot(amulet.skillSlot3),
        ],
      );

  Widget buildSkillSlot(Watch<SkillType> skillSlot){

    final index = amulet.getSkillSlotIndex(skillSlot);
    const size = 50.0;
    final slot = buildWatch(skillSlot, (skillType) {

      final button = onPressed(
        action: () {
          amulet.setSkillSlotIndex(index);
          if (skillType == SkillType.None) {
            amulet.windowVisiblePlayerSkills.setTrue();
          }
        },
        onRightClick: () {
          visibleRightClickedToClear = false;
          amulet.setSkillSlotValue(
            index: index,
            skillType: SkillType.None,
          );
          amulet.setSkillSlotIndex(index);
          amulet.windowVisiblePlayerSkills.setTrue();
        },
        child: Container(
          width: size,
          height: size,
          child: buildIconSkillType(skillType),
        ),
      );

      if (skillType == SkillType.None) {
        return button;
      }

      return buildMouseOverHint(
        child: button,
        panel: Column(
          children: [
            if (visibleRightClickedToClear)
              buildText('right click to change'),
            buildCardSkillType(skillType),
          ],
        ),
        bottom: 70,
        left: -70,
      );

    });

    final containerActive = buildBorder(
      color: Colors.white70,
      width: 3,
      child: Container(
        child: slot,
        color: Palette.brown_2,
        width: size,
        height: size,
        alignment: Alignment.center,
      ),
    );

    final containerInactive = buildBorder(
      width: 3,
      color: Palette.brown_4,
      child: Container(
        child: slot,
        color: Palette.brown_3,
        width: size,
        height: size,
        alignment: Alignment.center,
      ),
    );

    final key = Positioned(
        bottom: 4,
        right: 4,
        child: buildText(const['A', 'S', 'D', 'F',].tryGet(index), size: 20));


    final child = buildWatch(amulet.playerSkillSlotIndex, (selectedIndex) =>
    selectedIndex == index ? containerActive : containerInactive);

    return buildWatch(skillSlot, (skillType) {

      final feedback = buildIconSkillType(skillType, dstX: 25, dstY: 25);
      return Draggable(
        data: skillSlot.value,
        feedback: feedback,
        child: DragTarget<SkillType>(
          onAccept: (value){
            amulet.setSkillSlotValue(
              index: index,
              skillType: value,
            );
          },
          builder: (context, candidateData, rejectData) {
            return MouseOver(
                builder: (mouseOver) {
                  return Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.center,
                    children: [
                      child,
                      if (mouseOver)
                        key,
                    ],
                  );
                }
            );
          },
        ),
      );
    });

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

  Widget buildHudTopLeft() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPlayerHealthBar(),
          buildPlayerMagicBar(),
          buildWindowPotions(),
        ],
      );

  Widget buildTextValue(value) => buildText(value, color: Colors.white70);

  Widget buildIconCheckBox(bool value) =>
      value ? iconCheckBoxTrue : iconCheckBoxFalse;

}

String formatFramesToSeconds(int frames){
  const fps = 45;
  return '${(frames / fps).toStringAsFixed(2)} sec';
}

Widget buildWatchVisible(Watch<bool> watch, Widget child, {bool condition = true}) =>
    buildWatch(watch, (t) => t == condition ? child : nothing);

Color getSkillTypeLevelDescriptionColor(SkillType skillType){
   switch (skillType){
     case SkillType.Heal:
       return AmuletColors.Health;
     case SkillType.Magic_Regen:
       return AmuletColors.Magic;
     case SkillType.Magic_Steal:
       return AmuletColors.Magic;
     case SkillType.Health_Regen:
       return AmuletColors.Health;
     case SkillType.Health_Steal:
       return AmuletColors.Health;
     default:
       return Colors.orange;
   }
}

