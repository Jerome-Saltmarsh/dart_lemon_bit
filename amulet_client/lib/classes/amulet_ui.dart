
import 'package:amulet_client/classes/amulet_colors.dart';
import 'package:amulet_client/components/isometric_options.dart';
import 'package:amulet_client/extensions/physical_keyboardkey_extension.dart';
import 'package:amulet_client/getters/get_src_skill_type.dart';
import 'package:amulet_client/getters/src.dart';
import 'package:amulet_client/ui/isometric_colors.dart';
import 'package:amulet_client/ui/src.dart';
import 'package:amulet_client/ui/widgets/gs_container.dart';
import 'package:amulet_client/ui/widgets/mouse_over.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/amulet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/src.dart';

import 'amulet_style.dart';

class AmuletUI {
  static const itemImageSize = 64.0;
  static const margin2 = 130.0;
  static const barWidth = 80.0;
  static const barHeight = 20.0;

  final Amulet amulet;
  final amuletStyle = AmuletStyle();

  late final iconCheckBoxTrue = buildAmuletImage(srcX: 560, srcY: 16, width: 16, height: 16);
  late final iconCheckBoxFalse = buildAmuletImage(srcX: 560, srcY: 0, width: 16, height: 16);

  final barBlockWhite70 = buildBarBlock(color: Colors.white70);
  final barBlockWhite24 = buildBarBlock(color: Colors.white24);
  final barBlockGreen = buildBarBlock(color: Colors.green.withOpacity(0.7));
  final barBlockRed = buildBarBlock(color: Colors.red.withOpacity(0.7));

  final quantifyTab = Watch(QuantifyTab.values.first);
  final quantifyAmuletItemSlotType = Watch(SlotType.Weapon);
  final quantifyLevel = WatchInt(1);
  final quantifyShowValue = WatchBool(false);

  late final iconMagic = buildIconMagic();
  late final iconGold = buildAmuletImage(
      srcX: 784,
      srcY: 80,
      width: 16,
      height: 16,
  );

  var visibleRightClickedToClear = true;
  var visibleRightClickedToDrop = true;

  AmuletUI(this.amulet);

  IsometricOptions get options => amulet.options;

  Widget buildUI(BuildContext buildContext) =>
      maximize(
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
            top: 0,
            left: 0,
            child: buildMouseCursorCatcher(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: buildMainMenu(),
          ),
          Positioned(bottom: 140, child: buildDialogTalk()),
          Positioned(bottom: 8, right: 8, child: buildWorldMap()),
          // Positioned(
          //   top: 8,
          //   child: buildPlayerAimNode(),
          // ),
          Positioned(
            top: 8,
            child: buildPlayerAimTarget(),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: buildHudTopLeft(),
          ),
          Positioned(
            top: 8,
            left: 64,
            child: buildWatch(
              amulet.aimTargetAmuletItemObject,
              (amuletItemObject) => amuletItemObject == null
                  ? nothing
                  : buildCardLargeAmuletItemObject(amuletItemObject),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: buildEquippedSlotTypes(),
          ),
          Positioned(
            bottom: 8,
            child: buildRowPlayerSkills(),
          ),
          Positioned(
              top: 0,
              left: 0,
              child: buildMessageIndex()),
          Positioned(
            bottom: 100,
            left: 50,
            child: buildWatch(amulet.playerCanUpgrade, (playerCanUpgrade) {
               if (!playerCanUpgrade) return nothing;
               return buildText('UPGRADE EQUIPMENT');
            }),
          ),
          Positioned(
            top: 100,
            child: buildWindowUpgradeMode(),
          ),
          Positioned(
              top: 8,
              child: buildWindowQuest()),
          Positioned(
              top: 16,
              child: buildWindowAmuletError()),
          Positioned(
              top: 0,
              left: 0,
              child: buildOverlayScreenColor()),
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
            child: buildWatch(amulet.windowVisibleQuantify, (visible) {
              return visible ? WindowQuantify(amuletUI: this) : nothing;
            }),
          ),
          Positioned(
              top: 50,
              child: buildWatch(amulet.windowVisibleHelp,
                  (t) => t ? buildWindowHelp() : nothing))
        ]),
      );

  Widget buildWindowUpgradeMode() {
    return buildWatch(amulet.playerUpgradeMode, (upgradeMode) {
        if (!upgradeMode) return nothing;
        return buildWatch(amulet.equippedChangedNotifier, (t) {
          return AmuletWindow(child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    onPressed(
                        action: amulet.endUpgradeMode,
                        child: buildText('CLOSE X')),
                  ],
                ),
              ),
              height16,
              Row(
                children: [
                  buildCardUpgradeAmuletItemObject(amulet.equippedWeapon),
                  buildCardUpgradeAmuletItemObject(amulet.equippedHelm),
                  buildCardUpgradeAmuletItemObject(amulet.equippedArmor),
                  buildCardUpgradeAmuletItemObject(amulet.equippedShoes),
                ],
              )
            ],
          ));
        });
    });
  }

  Widget buildCardUpgradeAmuletItemObject(AmuletItemObject? amuletItemObject){
    if (amuletItemObject == null) return nothing;

    final amuletItem = amuletItemObject.amuletItem;
    final level = amuletItemObject.level;
    final cost = amuletItem.getUpgradeCost(level);

    return onPressed(
      action: () => amulet.upgradeSlotType(amuletItem.slotType),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: Colors.black12,
            padding: paddingAll8,
            child: Row(
              children: [
                buildText('lvl ${level + 1}'),
                width8,
                buildText('${cost}g', color: AmuletColors.Gold70),
              ],
            ),
          ),
          height8,
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: buildCardLargeAmuletItemObject(amuletItemObject)),

        ],
      ),
    );
  }

  Widget buildWindowAmuletError() => buildWatch(amulet.gameError, (gameError){
    if (gameError == null) return nothing;
    return buildText(gameError.name.clean);
  });

  Widget buildMouseCursorCatcher() {
    final click = MouseRegion(
      cursor: SystemMouseCursors.click,
      hitTestBehavior: HitTestBehavior.translucent,
    );

    final translucent = MouseRegion(
      cursor: SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.translucent,
    );

    return maximize(
      child: buildWatch(amulet.aimTargetSet, (aimTargetSet) =>
        aimTargetSet ? click : translucent),
    );
  }

  Widget buildIconPotion() => buildAmuletImage(
              srcX: 133,
              srcY: 163,
              width: 22,
              height: 26,
            );

  Widget buildOverlayScreenColor() => IgnorePointer(
      child: buildWatch(amulet.screenColor, (color) => Container(
            width: amulet.engine.screen.width,
            height: amulet.engine.screen.height,
            color: color,

          )
      ),
    );

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
      return buildWindowBorder(
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
      );
    });

  Widget buildWorldMap() {
    final small = AmuletWorldMap(amulet: amulet, size: 200);
    final large = AmuletWorldMap(amulet: amulet, size: 400);
    return onPressed(
      action: amulet.worldMapLarge.toggle,
      child: buildWatch(amulet.worldMapLarge, (bool isLarge)
      => isLarge ? large : small
      ),
    );

  }

  Widget buildMessageIndex() => buildWatch(amulet.messageIndex, (int messageIndex) {
    if (messageIndex == -1) {
      return nothing;
    }
    final messages = amulet.messages;
    return Container(
      width: amulet.engine.screen.width,
      height: amulet.engine.screen.height,
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
  });

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

  Widget buildError() {
    final color = Colors.red.withOpacity(0.7);
    return IgnorePointer(
        child: buildWatch(
            amulet.error, (error) => buildText(error, color: color)));
  }

  Widget buildDialogTalk() {
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

    return buildWatch(
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
    );
  }

  Widget buildPlayerAimTarget() {
    const width = 200.0;
    const height = width * goldenRatio_0381 * goldenRatio_0381;

    final aimTarget = IgnorePointer(
      child: buildWatch(amulet.aimTargetNotifier, (t) {

          final level = amulet.aimTargetLevel;
          var textColor = Colors.white;
          final itemQuality = amulet.aimTargetItemQuality;
          final subtitles = amulet.aimTargetSubtitles;
          if (itemQuality != null){
            textColor = mapItemQualityToColor(itemQuality);
          }

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                  width: width,
                  height: height,
                  color: Palette.brown_4,
              ),
              Container(
                  width: width * amulet.aimTargetHealthPercentage,
                  height: height,
                  color: Palette.red_3,
              ),
              Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: FittedBox(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          buildText(amulet.aimTargetText, color: textColor),
                          if (level != null)
                            Container(
                                margin: const EdgeInsets.only(left: 8),
                                child: buildText('lvl $level', color: textColor.withOpacity(0.7))),
                        ],
                      ),
                      if (subtitles != null && subtitles.isNotEmpty)
                        buildText(subtitles, italic: true, size: 14, color: textColor.withOpacity(0.7))
                    ],
                  ))),
            ],
          );
      }),
    );

    return buildWatchVisible(amulet.aimTargetSet, aimTarget);

    // final healthPercentageBox = buildWatch(
    //     amulet.player.aimTargetHealthPercentage,
    //     (healthPercentage) => Container(
    //           width: width * healthPercentage,
    //           height: height,
    //           color: amulet.colors.red_3,
    //         ));

    // final name = Container(
    //   alignment: Alignment.centerLeft,
    //   height: height,
    //   color: amulet.colors.brownDark,
    //   padding: const EdgeInsets.all(4),
    //   width: width,
    //   child: Stack(
    //     children: [
    //       buildWatch(amulet.player.aimTargetAction, (targetAction) {
    //         if (targetAction != TargetAction.Attack) return nothing;
    //
    //         return healthPercentageBox;
    //       }),
    //       Container(
    //         width: width,
    //         height: height,
    //         alignment: Alignment.center,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             buildWatch(amulet.aimTargetAmuletItemObject, (amuletItem) {
    //               return FittedBox(
    //                 child: buildWatch(amulet.player.aimTargetName,
    //                         (name) => buildText(name.replaceAll('_', ' '),
    //                           color: Colors.white
    //                         )),
    //               );
    //             }),
    //             // itemQuality,
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    // return Positioned(
    //     top: 16,
    //     left: 0,
    //     child: IgnorePointer(
    //       child: Container(
    //         width: amulet.engine.screen.width,
    //         alignment: Alignment.center,
    //         child: buildWatch(amulet.player.aimTargetSet, (t) {
    //           if (!t) return nothing;
    //           return name;
    //         }),
    //       ),
    //     ));
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

  Widget buildEquippedSlotTypes() {

    final content = buildWatch(amulet.equippedChangedNotifier, (t) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildSlotType(SlotType.Weapon),
        width2,
        buildSlotType(SlotType.Helm),
        width2,
        buildSlotType(SlotType.Armor),
        width2,
        buildSlotType(SlotType.Shoes),
      ],
    ));

    return buildWatchVisible(amulet.windowVisibleInventory, content);
  }

  Widget buildPlayerHealthBar() => IgnorePointer(
        child: Row(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: barWidth,
                  height: barHeight,
                  color: Palette.brown_4,
                ),
                buildWatch(amulet.player.healthPercentage, (percentage) =>
                Container(
                    width: barWidth * percentage,
                    height: barHeight,
                    color: Palette.red_3,
                    )
                ),
                Container(
                  alignment: Alignment.center,
                  width: barWidth,
                  height: barHeight,
                  child: buildWatch(amulet.player.healthChangedNotifier, (_) =>
                      buildText('${amulet.player.health}/${amulet.player.maxHealth}', color: Colors.white70)),
                ),
              ],
            ),
          ],
        ),
      );

  Widget buildPlayerMagicBar() => IgnorePointer(
    child: Row(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: barWidth,
              height: barHeight,
              color: Palette.blue_3.withOpacity(0.3),
            ),
            buildWatch(amulet.playerMagicPercentage, (percentage) =>
                Container(
                  width: barWidth * percentage,
                  height: barHeight,
                  color: Palette.blue_3,
                )
            ),
            Container(
              alignment: Alignment.center,
              width: barWidth,
              height: barHeight,
              child: buildWatch(amulet.playerMagicNotifier, (_) =>
                  buildText('${amulet.playerMagic}/${amulet.playerMagicMax}', color: Colors.white70)),
            ),
          ],
        ),
      ],
    ),
  );
  // Widget buildPlayerHealthBar() {
  //
  //   return IgnorePointer(
  //     child: buildWatch(amulet.player.healthPercentage, (healthPercentage) {
  //       if (healthPercentage == 0) {
  //         return nothing;
  //       }
  //       return Container(
  //         width: barWidth,
  //         height: barHeight,
  //         color: Colors.black26,
  //         padding: const EdgeInsets.all(2),
  //         alignment: Alignment.centerLeft,
  //         child: Container(
  //           width: barWidth * healthPercentage,
  //           height: barHeight,
  //           color: AmuletColors.Health,
  //         ),
  //       );
  //     }),
  //   );
  // }

  // Widget buildPlayerMagicBar() {
  //   return IgnorePointer(
  //     child: buildWatch(amulet.playerMagicPercentage, (percentage) =>
  //       Container(
  //         width: barWidth,
  //         height: barHeight,
  //         color: Colors.black26,
  //         padding: const EdgeInsets.all(2),
  //         alignment: Alignment.centerLeft,
  //         child: AnimatedContainer(
  //           duration: const Duration(milliseconds: 100),
  //           width: barWidth * percentage,
  //           height: barHeight,
  //           color: AmuletColors.Magic,
  //         ),
  //       )),
  //   );
  // }

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

  Widget buildIconItems() => buildAmuletImage(srcX: 725, srcY: 99, width: 22, height: 25);

  Widget buildIconItemsGrey() => buildAmuletImage(srcX: 693, srcY: 99, width: 22, height: 25);

  Widget buildIconPlayerStats() =>
      buildAmuletImage(srcX: 723, srcY: 131, width: 26, height: 26);

  Widget buildIconPlayerStatsGrey() =>
      buildAmuletImage(srcX: 691, srcY: 131, width: 26, height: 26);

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

  Widget buildIconSkills() => buildAmuletImage(srcX: 723, srcY: 39, width: 26, height: 20);

  Widget buildIconSkillsGrey({double scale = 1.0}) =>
      buildAmuletImage(
        srcX: 691,
        srcY: 39,
        width: 26,
        height: 20,
        scale: scale,
      );

  // Widget buildTogglePlayerSkills() {
  //
  //   final active = buildToggleContainer(
  //     child: buildIconSkills(),
  //     active: true,
  //   );
  //
  //   final notActive = buildToggleContainer(
  //     child: buildIconSkillsGrey(),
  //     active: false,
  //   );
  //
  //   return onPressed(
  //     hint: 'Skills (E)',
  //     action: amulet.windowVisiblePlayerSkills.toggle,
  //     child: buildWatch(
  //         amulet.windowVisiblePlayerSkills,
  //             (windowVisibleEquipment) =>
  //         windowVisibleEquipment ? active : notActive),
  //   );
  // }

  Widget buildIconQuestGrey() =>
      buildAmuletImage(srcX: 691, srcY: 3, width: 26, height: 25);

  Widget buildIconQuest() =>
      buildAmuletImage(srcX: 723, srcY: 3, width: 26, height: 25);


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

  Widget buildToggleInventory() {

    final active = buildToggleContainer(
        child: buildAmuletImage(
            srcX: 688,
            srcY: 96,
            width: 32,
            height: 32,
        ),
        active: true,
    );

    final notActive = buildToggleContainer(
      child: buildAmuletImage(
        srcX: 688,
        srcY: 96,
        width: 32,
        height: 32,
      ),
      active: false,
    );
    return onPressed(
      hint: 'Inventory (${amulet.amuletKeys.toggleWindowInventory.name.upper})',
      action: amulet.windowVisibleInventory.toggle,
      child: buildWatch(
          amulet.windowVisibleInventory,
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

  Widget buildBars({required int total, required int value}) =>
      Row(
      children: List.generate(
          total,
          (index) =>
            value >= index ? barBlockWhite70 : barBlockWhite24)
      );

  static Widget buildBarBlock({required Color color}){
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 4),
      color: color,
    );
  }

  Widget buildIconAgility() =>
      buildAmuletImage(srcX: 768, srcY: 64, width: 16, height: 16);

  Widget buildIconMagicRegen() =>
      buildAmuletImage(srcX: 768, srcY: 48, width: 16, height: 16);

  Widget buildIconHealth() =>
      buildAmuletImage(srcX: 768, srcY: 0, width: 16, height: 16);

  Widget buildIconHealAmount() =>
      buildAmuletImage(srcX: 768, srcY: 320, width: 16, height: 16);

  Widget buildIconMagic() =>
      buildAmuletImage(srcX: 784, srcY: 16, width: 16, height: 16);

  Widget buildIconHealthRegen() =>
      buildAmuletImage(srcX: 768, srcY: 32, width: 16, height: 16);

  Widget buildHint(String text) =>
      buildBorder(
          color: Colors.white70,
          width: 2,
          child: GSContainer(
            child: buildText(text),
            width: 150,)
      );

  Widget buildMouseOverPanel({
    required Widget child,
    required Widget panel,
    Function? onEnter,
    Function? onExit,
    double? top,
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
                      top: top,
                      left: left,
                      bottom: bottom,
                      right: right,
                      child: panel,
                    ),
                ],
              ));

  Widget buildCardLargeSkillType(SkillType skillType) {

    final level = amulet.getSkillTypeLevel(skillType);

    final title = buildCardLargeTitleTemplate(
      icon: buildIconSkillType(skillType),
      name: skillType.name.clean,
      subtitle: 'lvl $level',
    );

    final magicCost = skillType.magicCost;

    final contents = Container(
      padding: paddingAll8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white10,
              child: buildTextValue(getSkillTypeDescription(skillType))),
          height8,
          if (magicCost > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  iconMagic,
                  width4,
                  buildText(magicCost, color: Palette.red_1),
                ],
              ),
            ),
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
      ),
    );

    // final bottomRow = Row(
    //   mainAxisAlignment: MainAxisAlignment.end,
    //   children: [
    //     if (skillType.magicCost > 0)
    //       controlMagicCost,
    //   ],
    // );

    return buildCardLarge(
        header: buildCardLargeHeaderText(skillType.casteType.name),
        title: title,
        content: contents,
    );
  }

  Widget buildRowValue(dynamic value) => buildText(value, color: Colors.white70);

  Widget buildCardLarge({
    required Widget header,
    required Widget title,
    required Widget content,
  }) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70, width: 2),
          borderRadius: borderRadius2,
          color: amuletStyle.colorCardLargeContent,
        ),
        width: amuletStyle.widthCardLarge,
        constraints: BoxConstraints(minHeight: amuletStyle.widthCardLarge * goldenRatio_1618),
        padding: EdgeInsets.zero,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCardLargeHeader(child: header),
            buildCardLargeTitle(child: title),
            buildCardLargeContent(child: content),
          ],
        ));

  }

  static final titleColor =  Colors.orange;

  Widget buildRowTitle(dynamic value) => Container(
      margin: const EdgeInsets.only(right: 8),
      child: buildText(value, color: titleColor),
  );

  Widget buildSlotType(SlotType slotType) {

    final amuletItemObject = amulet.getEquipped(slotType);

    if (amuletItemObject == null){
      return buildCardSmallEmpty();
    }

    final amuletItem = amuletItemObject.amuletItem;

    return onPressed(
        action: () => amulet.dropAmuletItem(amuletItem),
        child: buildMouseOverPanel(
            bottom: 90,
            left: 0,
            panel: buildCardLargeAmuletItemObject(amuletItemObject),
            child: buildCardSmallAmuletItemObject(amuletItemObject)
        ),
    );

    // final button = onPressed(
    //   action: amuletItem == null ? null : () => amulet.dropAmuletItem(amuletItem),
    //   onRightClick: amuletItem == null ? null : () {
    //     visibleRightClickedToDrop = false;
    //     amulet.dropAmuletItem(amuletItem);
    //   },
    //   child: buildBorder(
    //     color: Palette.brown_4,
    //     width: 3,
    //     child: Container(
    //       width: width,
    //       color: Palette.brown_3,
    //       child: Column(
    //         children: [
    //           Container(
    //               height: 20,
    //               child: amuletItemObject == null ? null : buildText(amuletItemObject.level, color: Colors.white70)),
    //           Container(
    //             height: 50,
    //             width: width,
    //             color: Colors.white12,
    //             alignment: Alignment.center,
    //             child: amuletItem == null ? null : AmuletItemImage(
    //               amuletItem: amuletItem,
    //               scale: 1.2,),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );


    // final canAfford = upgradeCost != null && amulet.playerGold.value >= upgradeCost;
    // final upgradeColor = canAfford ? AmuletColors.Gold : AmuletColors.Gold70;
    //
    // return Container(
    //   margin: const EdgeInsets.only(right: 4),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.end,
    //     children: [
    //       if (upgradeCost != null)
    //         onPressed(
    //           action: () => amulet.upgradeSlotType(slotType),
    //           child: Container(
    //             decoration: BoxDecoration(
    //               color: Palette.brown_3,
    //               border: Border.all(color: Palette.brown_4, width: 2),
    //               borderRadius: BorderRadius.zero,
    //             ),
    //             margin: const EdgeInsets.only(bottom: 8),
    //             padding: paddingAll4,
    //             alignment: Alignment.center,
    //             child: Column(
    //               children: [
    //                 if (level != null)
    //                 Container(
    //                     color: Colors.black26,
    //                     child: buildText('lvl ${level + 1}', color: upgradeColor, size: 13)),
    //                 buildText('${upgradeCost}g', color: upgradeColor),
    //               ],
    //             ),
    //           ),
    //         ),
    //       buildMouseOverPanel(
    //         child: button,
    //         panel: Column(
    //           children: [
    //             if (amuletItemObject != null && visibleRightClickedToDrop)
    //               buildText('left click to drop'),
    //             tryBuildCardAmuletItemObject(amuletItemObject),
    //           ],
    //         ),
    //         left: 0,
    //         bottom: 130,
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget buildIconHealthCost() =>
      buildAmuletImage(
        srcX: 768,
        srcY: 208,
        width: 16,
        height: 16,
      );

  Widget buildIconMagicCost() =>
      buildAmuletImage(
        srcX: 768,
        srcY: 224,
        width: 16,
        height: 16,
      );

  Widget buildIconSlotType(SlotType slotType) =>
      buildAmuletImageSrc(getSrcSlotType(slotType));

  Widget buildIconSkillType(SkillType skillType, {double dstX = 0, double dstY = 0}) {
    final src = getSrcSkillType(skillType);
    const size = 32.0;
    return buildAmuletImage(
          srcX: src[0],
          srcY: src[1],
          width: src.tryGet(2) ?? size,
          height: src.tryGet(3) ?? size,
          dstX: dstX,
          dstY: dstY,
    );
  }

  Widget buildCardLargeAmuletItemObject(AmuletItemObject amuletItemObject) {

    final amuletItem = amuletItemObject.amuletItem;
    final header = buildCardLargeHeaderText(amuletItem.slotType.name.clean);
    final content = buildCardLargeAmuletItemObjectContent(amuletItemObject);

    final title = buildCardLargeTitleTemplate(
      icon: buildIconAmuletItem(amuletItem),
      name: amuletItem.label,
      subtitle: 'lvl ${amuletItemObject.level}',
    );

    return buildCardLarge(
        header: header,
        title: title,
        content: content,
    );
  }

  Widget buildTextSubtitle(dynamic value) =>
      buildText('$value', color: Colors.white70, size: 16);

  Widget buildCardLargeAmuletItemObjectContent(AmuletItemObject next){
    final current = amulet.getEquipped(next.amuletItem.slotType);
    // final nextAmuletItem = next.amuletItem;
    // final currentAmuletItem = current?.amuletItem;
    // final levelDiff = getDiff(next.level, current?.level);
    // final valueDiff = getDiff(nextAmuletItem.quantify, currentAmuletItem?.quantify);
    final showDiff = current != next;

    return Container(
      padding: paddingAll8,
      child: Column(
        children: [
            ...SkillType.values.map((skillType) {


              final currentLevel = current?.getSkillLevel(skillType) ?? 0;
              final nextLevel = next.getSkillLevel(skillType);

              if (currentLevel == 0 && nextLevel == 0) {
                return nothing;
              }

              final levelDiff = getDiff(nextLevel, currentLevel);

              if (levelDiff == null){
                return nothing;
              }

              final icon = Container(
                  // color: Colors.black12,
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: buildIconSkillType(skillType)
              );

              final controlLevel =   buildText('+$nextLevel', color: Colors.green);
              final controlName = buildText(skillType.name.clean, color: Colors.white70, size: 15);

              return Container(
                color: Colors.black12,
                margin: const EdgeInsets.only(bottom: 6),
                padding: paddingAll4,
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black26, width: 2),
                //   borderRadius: BorderRadius.zero,
                // ),
                child: Row(
                  children: [
                    icon,
                    width8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controlName,
                        controlLevel,
                      ],
                    ),
                  ],
                ),
              );
            }),

          if (showDiff)
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  onPressed(
                    action: amulet.sellAmuletItem,
                    child: Container(
                        color: Colors.yellow,
                        padding: paddingAll8,
                        child: buildText('SELL')),
                  ),
                  onPressed(
                    action: amulet.pickupAmuletItem,
                    child: Container(
                      color: Colors.green,
                        padding: paddingAll8,
                        child: buildText('TAKE')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCompareBars(String text, num current, num next){

    if (current == 0 && next == 0){
      return nothing;
    }

    final diff = getDiff(next, current);

    if (current == 0 && next == 0){
      return nothing;
    }

    if (diff == null){
      return nothing;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildText(text),
        expanded,
        Row(
          children: List.generate(4, (index) {
            if (index <= next && index <= current){
              return barBlockWhite70;
            }
            if (index > current && index > next) {
              return barBlockWhite24;
            }
            if (current > next){
              return barBlockRed;
            }
            return barBlockGreen;
          }).toList(growable: false),
        ),
        // expanded,
        // buildDiff(diff),
      ],
    );
  }

  Widget buildComparisonRow({
    required dynamic lead,
    required num? value,
    required num? diff,
  }) =>
      Row(
        children: [
          if (lead is Widget)
            lead,
          if (lead is String)
            buildText(lead),
          width8,
          if (diff == null)
            expanded,
          buildText('${diff == null ? getOperator(value) : ''}${value?.toInt() ?? '0'}'),
          if (diff != null)
          expanded,
          if (diff != null)
          buildDiff(diff),
        ],
      );

  Widget buildComparisonRow01({
    required dynamic lead,
    required double? next,
    required double? current,
  }) {
    if (next == null && current == null){
      return nothing;
    }

    int? nextInt;
    int? currentInt;
    int? diffInt;
    if (next != null){
      nextInt = (next * 100).toInt();
    }
    if (current != null){
      currentInt = (current * 100).toInt();
    }
    if (nextInt != null && currentInt != null){
      diffInt = nextInt - currentInt;
    }
    return buildComparisonRow(lead: lead, value: nextInt, diff: diffInt);
  }

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

  Widget buildCardLargeHeaderText(dynamic value) =>
      buildText(value.toString().upper, color: Colors.black54);

  Widget buildCardLargeHeader({required Widget child}) =>
      Container(
        color: Colors.orange,
        alignment: Alignment.center,
        child: child,
        height: 30,
      );

  Widget buildCardLargeTitleTemplate({
    required Widget icon,
    required String name,
    required dynamic subtitle,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          width8,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText(
                name,
                color: Colors.white,
              ),
              buildTextSubtitle(subtitle),
            ],
          ),
        ],
      );

  Widget buildCardLargeTitle({required Widget child}) =>
      Container(
        color: amuletStyle.colorCardTitle,
        alignment: Alignment.center,
        child: child,
        height: 50,
      );

  Widget buildCardLargeContent({required Widget child}) =>
      Container(
        color: amuletStyle.colorCardLargeContent,
        child: child,
      );

  Widget buildCardHeaderText(dynamic value) =>
      buildText(value.toUpperCase(), color: Colors.black87);


  Widget buildRowTitleValue(dynamic title, dynamic value) =>
    Row(
      children: [
        buildRowTitle(title), buildRowValue(value),
      ],
    );

  Widget buildIconDamage() => buildAmuletImage(
        srcX: 768,
        srcY: 208,
        width: 16,
        height: 16,
    );

  Widget buildIconCasteType(CasteType casteType) =>
      buildAmuletImageSrc(getSrcCasteType(casteType));

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



  Widget buildIconRange() => buildAmuletImage(
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
        SkillType.Split_Shot => buildAmuletImage(
              srcX: 768,
              srcY: 240,
              width: 16,
              height: 16,
          ),
        _ => buildText('Amount')
      };

  Widget buildIconHealthSteal() =>
      buildAmuletImage(srcX: 768, srcY: 256, width: 16, height: 16);

  Widget buildIconMagicSteal() =>
      buildAmuletImage(srcX: 768, srcY: 272, width: 16, height: 16);

  Widget buildIconAttackSpeed() =>
      buildAmuletImage(srcX: 768, srcY: 288, width: 16, height: 16);

  Widget buildIconAreaDamage() =>
      buildAmuletImage(srcX: 768, srcY: 304, width: 16, height: 16);

  Widget buildIconCriticalHitPoints() =>
      buildAmuletImage(srcX: 768, srcY: 336, width: 16, height: 16);

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

  // Widget buildPlayerAimNode() {
  //   return buildWatch(amulet.player.aimNodeIndex, (aimNodeIndex) {
  //      if (aimNodeIndex == null) {
  //        return nothing;
  //      }
  //      return IgnorePointer(
  //          child: GSContainer(
  //              child: buildText(getAimNodeText(aimNodeIndex))
  //          )
  //      );
  //   });
  // }

  Widget buildRowPlayerSkills() => buildWatch(
      amulet.playerSkillsNotifier,
      (_) => Row(
            children: [
              Container(
                  margin: EdgeInsets.only(right: 32),
                  child: buildPlayerSkillAttack()),
              // width32,
              buildRowPlayerSkillsPassive(),
              // width32,
              buildRowPlayerSkillsActive(),
            ],
          ));

  Widget buildRowPlayerSkillsPassive() => buildWatch(
      amulet.playerSkillsNotifier,
      (t) {
        final content = Container(
          margin: const EdgeInsets.only(right: 32),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: SkillType.values.map((skillType) {
                if (!skillType.isPassive) return nothing;
                final level = amulet.getSkillTypeLevel(skillType);
                if (level <= 0) return nothing;
                return buildCardSmallSkillType(skillType);
              }).toList(growable: false),
            ),
        );

        return buildWatchVisible(amulet.windowVisibleInventory, content);
      });

  Widget buildRowPlayerSkillsActive() => buildWatch(
      amulet.playerSkillsNotifier,
      (t) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: SkillType.values.map((skillType) {
              if (skillType.isPassive) return nothing;
              if (skillType.isBaseAttack) return nothing;
              final level = amulet.getSkillTypeLevel(skillType);
              if (level <= 0) return nothing;
              return onPressed(
                  action: () => amulet.selectSkillTypeRight(skillType),
                  child: buildCardSmallSkillType(skillType),
              );
            }).toList(growable: false),
          ));

  Widget buildCardSmallSkillType(SkillType skillType) {
    const size = 50.0;

    final child = Container(
      color: Palette.brown_4,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            width: size,
            child: buildText(amulet.getSkillTypeLevel(skillType), color: Palette.brown_0),
            alignment: Alignment.center,
            color: Palette.brown_4,
          ),
          Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Palette.brown_3,
              child: buildIconSkillType(skillType)),
        ],
      ),
    );

    final borderActive = buildBorder(
      color: amulet.playerSufficientMagicForSkillRight
          ? Colors.white70 : Colors.red.withOpacity(0.7),
      width: 3,
      child: child,
    );

    final borderNotActive = buildBorder(
      color: Colors.transparent,
      width: 3,
      child: child,
    );

    return buildMouseOverPanel(
        bottom: 90,
        left: -60,
        panel: buildCardLargeSkillType(skillType),
        child: amulet.playerSkillRight == skillType ? borderActive : borderNotActive,
    );
  }

  Widget buildCardSmallEmpty(){
    return buildCardSmall(title: nothing, child: nothing);
  }

  Widget buildCardSmallAmuletItemObject(AmuletItemObject amuletItemObject) =>
      buildCardSmallAmuletItemLevel(
        amuletItem: amuletItemObject.amuletItem,
        level: amuletItemObject.level,
      );


  Widget buildCardSmallAmuletItemLevel({
    required AmuletItem amuletItem,
    required int level,
  }) =>
      buildCardSmall(
        title: buildCardTitleText(level),
        child: buildIconAmuletItem(amuletItem),
      );


  late final iconPotionEmpty = buildAmuletImage(
      srcX: 784,
      srcY: 32,
      width: 16,
      height: 16,
  );

  late final iconPotionHealth = buildAmuletImage(
      srcX: 784,
      srcY: 48,
      width: 16,
      height: 16,
  );

  late final iconPotionMagic = buildAmuletImage(
      srcX: 784,
      srcY: 64,
      width: 16,
      height: 16,
  );

  Widget buildRowMagicPotions() =>
      buildWatch(amulet.potionsMagic, (potions) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(potions, (index) => iconPotionMagic).toList(growable: false),
      ));

  Widget buildRowHealthPotions() =>
      buildWatch(amulet.potionsHealth, (potions) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(potions, (index) => iconPotionHealth).toList(growable: false),
      ));

  Widget buildCardSmallPotionMagic() {
    final child = onPressed(
      action: amulet.usePotionMagic,
      child: Container(
        padding: paddingAll4,
        color: amuletStyle.colorCardTitle,
        child: Column(children: [
          buildPlayerMagicBar(),
          height4,
          Container(
              width: barWidth,
              height: 16,
              child: buildRowMagicPotions(),
          ),
        ],),
      ),
    );

    return buildMouseOverPanel(
        top: 60,
        child: child, panel: buildHint('Use Magic Potion (${amulet.amuletKeys.usePotionMagic.name.upper})'));
  }

  Widget buildCardSmallPotionHealth() {
    final child = onPressed(
      action: amulet.usePotionHealth,
      child: Container(
        padding: paddingAll4,
        color: amuletStyle.colorCardTitle,
        child: Column(children: [
          buildPlayerHealthBar(),
          height4,
          Container(
              width: barWidth,
              height: 16,
              child: buildRowHealthPotions()),
        ],),
      ),
    );

    return buildMouseOverPanel(
        top: 60,
        child: child, panel: buildHint('Use health Potion (${amulet.amuletKeys.usePotionHealth.name.upper})'));
  }

  Widget buildCardSmallAmuletItem({
    required Widget title,
    required AmuletItem amuletItem,
  }) =>
      buildCardSmall(title: title, child: buildIconAmuletItem(amuletItem));

  Widget buildCardTitleText(dynamic value) => buildText(value, color: Palette.brown_0);

  Widget buildCardSmall({required Widget title, required Widget child}) {
    const size = 50.0;

    return Container(
      color: Palette.brown_4,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            width: size,
            height: size * goldenRatio_0381,
            child: title,
            alignment: Alignment.center,
            color: Palette.brown_4,
          ),
          Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Palette.brown_3,
              child: child
          ),
        ],
      ),
    );
  }

  Widget buildCardSmallHalf({required Widget title, required Widget child}) {
    const size = 50.0;
    return Container(
      color: Palette.brown_4,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            width: size,
            child: title,
            alignment: Alignment.center,
            color: Palette.brown_4,
          ),
          Container(
              width: size,
              height: size * 0.5,
              alignment: Alignment.center,
              color: Palette.brown_3,
              child: child
          ),
        ],
      ),
    );
  }

  Widget buildSkillTypeLevel({
    required SkillType skillType,
    required Widget Function(int level) builder,
  }) => buildWatch(
      amulet.playerSkillsNotifier,
      (t) => builder(amulet.getSkillTypeLevel(skillType)),
  );

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

  Widget buildHudTopLeft() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildCardSmallPotionHealth(),
      width4,
      buildCardSmallPotionMagic(),
      width4,
      buildControlGold(),
      width4,
      buildTogglePlayerQuest(),
      width4,
      buildToggleInventory(),
    ],
  );

  Widget buildControlGold() {
    final title = buildWatch(amulet.playerGold, buildCardTitleText);
    final child = buildCardSmallHalf(title: title, child: iconGold);
    final panel = buildHint('Stand near a fireplace to upgrade equipment');
    return buildMouseOverPanel(child: child, panel: panel, top: 60);
  }

  Widget buildTextValue(value) => buildText(value, color: Colors.white70);

  Widget buildIconCheckBox(bool value) =>
      value ? iconCheckBoxTrue : iconCheckBoxFalse;

  Widget buildWatchCheckbox(WatchBool watch) =>
    buildWatch(watch, buildIconCheckBox);

  Widget buildIconAmuletItem(AmuletItem amuletItem, {
    double scale = 1.0,
    double dstX = 0,
    double dstY = 0,
  }) {
    const size = 32.0;
    final src = getSrcAmuletItem(amuletItem);
    return buildAmuletImage(
      srcX: src[0],
      srcY: src[1],
      width: src.tryGet(2) ?? size,
      height: src.tryGet(3) ?? size,
      scale: scale,
    );
  }

  Widget buildAmuletImageSrc(List<num> src,
  { double dstX = 0,
    double dstY = 0,
    double scale = 1.0,}
   ) =>
      buildAmuletImage(
        srcX: src[0].toDouble(),
        srcY: src[1].toDouble(),
        width: src[2].toDouble(),
        height: src[3].toDouble(),
      );

  Widget buildAmuletImage({
    required double srcX,
    required double srcY,
    required double width,
    required double height,
    double dstX = 0,
    double dstY = 0,
    double scale = 1.0,
  }) =>
      amulet.engine.buildAtlasImage(
        image: amulet.images.atlas_amulet_items,
        srcX: srcX,
        srcY: srcY,
        srcWidth: width,
        srcHeight: height,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
      );

  Widget buildPlayerSkillAttack() {
    final skillType = amulet.playerSkillLeft;
    // final level = amulet.getSkillTypeLevel(skillType);
    // if (level <= 0) return nothing;
    return buildCardSmallSkillType(skillType);
  }

  Widget buildMainMenu() => MouseRegion(
      onEnter: (PointerEnterEvent event) {
        options.windowOpenMenu.value = true;
      },
      onExit: (PointerExitEvent event) {
        options.windowOpenMenu.value = false;
      },
      child: buildWatch(options.windowOpenMenu, (bool menuVisible) =>
          Container(
            padding: paddingAll8,
          color: menuVisible ? amulet.style.containerColor : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              height16,
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buildSceneName(),
                    width32,
                    menuVisible ? buildIconCogTurned() : buildIconCog(),
                    width16,
                  ]
              ),
              if (menuVisible)
                ...buildMenuVisible(),
            ],
          ),
        )),
    );

  Widget buildIconCog() => onPressed(
      action: options.windowOpenMenu.toggle,
      child: Container(
        width: 16,
        height: 16,
        child: FittedBox(
          fit: BoxFit.contain,
          child: buildAmuletImage(
              srcX: 864,
              srcY: 208,
              width: 64,
              height: 64,
          ),
        ),
      )
  );

  Widget buildIconCogTurned() => Container(
    width: 16,
    height: 16,
    child: FittedBox(
      fit: BoxFit.contain,
      child: onPressed(
          action: options.windowOpenMenu.toggle,
          child: buildAmuletImage(
            srcX: 929,
            srcY: 208,
            width: 64,
            height: 64,
          )
      ),
    ),
  );

  Widget buildSceneName() =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildWatch(
              options.sceneName,
                  (sceneName) =>
                  buildText(sceneName, color: Colors.white70, size: 22)),
          // width8,
          // buildControlFiendsRemaining(),
        ],
      );

  List<Widget> buildMenuVisible() => [
       height16,
       onPressed(
         action: options.audio.enabledSound.toggle,
         child: buildWatch(options.audio.enabledSound, (enabled) {
           return Row(
             children: [
               buildText('Sound $enabled'),
               width8,
               buildIconCheckBox(enabled),
             ],
           );
         }),
       ),
       onPressed(
         action: options.audio.enabledMusic.toggle,
         child: buildWatch(options.audio.enabledMusic, (enabled) {
           return Row(
             children: [
               buildText('Music $enabled'),
               width8,
               buildIconCheckBox(enabled),
             ],
           );
         }),
       ),
       height16,
       buildButtonDisconnect(),
    ];

  Widget buildButtonDisconnect() => onPressed(
      action: amulet.disconnect,
      child: buildText('DISCONNECT'));
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

String getOperator(num? value){
  if (value == null || value == 0){
    return '';
  }
  if (value < 0) {
    return '-';
  }
  return '+';
}


double getAmuletItemSkillSetTotal(AmuletItem amuletItem) {
  var total = 0.0;
  for (final entry in amuletItem.skillSet.values){
    total += entry;
  }
  return total;
}

Widget buildPostFrameCallback({required WidgetBuilder builder}){
  var set = false;
  return StatefulBuilder(builder: (context, setState){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (set) return;
      setState(() {
        set = true;
      });
    });

    if (set){
      return builder(context);
    }
    return nothing;
  });
}