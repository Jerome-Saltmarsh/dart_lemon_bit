
import 'dart:math';

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

  late final iconCheckBoxTrue = buildIcon(srcX: 560, srcY: 16, width: 16, height: 16);
  late final iconCheckBoxFalse = buildIcon(srcX: 560, srcY: 0, width: 16, height: 16);

  final barBlockSm70 = buildBarBlock(color: Colors.white70, size: 5);
  final barBlockSm24 = buildBarBlock(color: Colors.white24, size: 5);

  final barBlockWhite70 = buildBarBlock(color: Colors.white70, size: 8);
  final barBlockWhite24 = buildBarBlock(color: Colors.white24, size: 8);

  final barBlockGreen = buildBarBlock(color: Colors.green.withOpacity(0.7), size: 8);
  final barBlockRed = buildBarBlock(color: Colors.red.withOpacity(0.7), size: 8);

  final blockGreen = Container(width: 15, height: 15, color: Colors.green,);
  final blockRed = Container(width: 15, height: 15, color: Colors.red,);

  final quantifyTab = Watch(QuantifyTab.values.first);
  final quantifyAmuletItemSlotType = Watch(SlotType.Weapon);
  final quantifyLevel = WatchInt(1);
  final quantifyShowValue = WatchBool(false);

  late final iconMagic = buildIconMagic();
  late final iconGold = buildIcon(
      srcX: 784,
      srcY: 80,
      width: 16,
      height: 16,
  );

  var visibleRightClickedToClear = true;
  var visibleRightClickedToDrop = true;

  final skillTypeLevels = Map.fromEntries(
      SkillType.values.map((skillType) => MapEntry(skillType, 0)));

  final skillTypeLevelsDelta = Map.fromEntries(
      SkillType.values.map((skillType) => MapEntry(skillType, 0)));

  final notifierSkillTypes = WatchInt(0);
  final notifierEquipment = WatchInt(0);
  final amuletItemObjectHover = Watch<AmuletItemObject?>(null);
  var amuletItemObjectHoverUpgrade = false;


  AmuletUI(this.amulet) {

    amulet.playerSkillsNotifier.onChanged((t) {
      notifierSkillTypes.increment();
    });

    amulet.equippedChangedNotifier.onChanged((t) {
      notifierEquipment.increment();
    });

    amulet.playerCanUpgrade.onChanged((t) {
      notifierEquipment.increment();
    });

    amuletItemObjectHover.onChanged((amuletItemObject) {

       if (amuletItemObject == null){
         for (final skillType in SkillTypes) {
           final level = amulet.getSkillTypeLevel(skillType);
           skillTypeLevels[skillType] = level;
           skillTypeLevelsDelta[skillType] = level;
         }
         notifierSkillTypes.increment();
         return;
       }

       if (amulet.isEquipped(amuletItemObject)){

         if (amuletItemObjectHoverUpgrade){
           for (final skillType in SkillTypes) {
             final currentSkillLevel = amulet.getSkillTypeLevel(skillType);
             final nextItemLevel = amuletItemObject.getSkillLevelNext(skillType);
             final currentItemLevel = amuletItemObject.getSkillLevel(skillType);
             final diff = nextItemLevel - currentItemLevel;
             if (diff <= 0) continue;
             skillTypeLevels[skillType] = currentSkillLevel;
             skillTypeLevelsDelta[skillType] = currentSkillLevel + diff;
           }
           notifierSkillTypes.increment();
           return;
         }

         for (final skillType in SkillTypes) {
           final itemLevel = amuletItemObject.getSkillLevel(skillType);
           final level = amulet.getSkillTypeLevel(skillType);
           skillTypeLevels[skillType] = level - itemLevel;
           skillTypeLevelsDelta[skillType] = level;
         }
         notifierSkillTypes.increment();
         return;
       }

       final equipped = amulet.getEquipped(amuletItemObject.amuletItem.slotType);
       if (equipped == null) {
         for (final skillType in SkillTypes) {
           final itemLevel = amuletItemObject.getSkillLevel(skillType);
           final level = amulet.getSkillTypeLevel(skillType);
           skillTypeLevels[skillType] = level;
           skillTypeLevelsDelta[skillType] = itemLevel;
         }
         notifierSkillTypes.increment();
         return;
       }

       for (final skillType in SkillTypes) {
         final equippedLevel = equipped.getSkillLevel(skillType);
         final itemLevel = amuletItemObject.getSkillLevel(skillType);
         final level = amulet.getSkillTypeLevel(skillType);
         final newLevel = level - equippedLevel + itemLevel;
         skillTypeLevels[skillType] = level;
         skillTypeLevelsDelta[skillType] = newLevel;
       }
       notifierSkillTypes.increment();
    });
  }

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
            top: 70,
            left: 10,
            child: buildWatchVisible(amulet.playerCanUpgrade, buildWindowStash()),
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

  // Widget buildWindowUpgradeMode() {
  //
  //   final child = buildWatch(amulet.equippedChangedNotifier, (t) =>
  //       AmuletWindow(child: Column(
  //       children: [
  //         Container(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               buildBorder(
  //                   width: 3,
  //                   color: Colors.white60,
  //                   child: buildPlayerGold()
  //               ),
  //               width32,
  //               buildDialogTitle('UPGRADE EQUIPMENT'),
  //               width32,
  //               // onPressed(
  //               //     action: amulet.endUpgradeMode,
  //               //     child: buildText('CLOSE X', underline: true)),
  //             ],
  //           ),
  //         ),
  //         height16,
  //         if (amulet.nothingEquipped)
  //           buildText('No items equipped to upgrade'),
  //         if (!amulet.nothingEquipped)
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             buildCardUpgradeAmuletItemObject(amulet.equippedWeapon),
  //             buildCardUpgradeAmuletItemObject(amulet.equippedHelm),
  //             buildCardUpgradeAmuletItemObject(amulet.equippedArmor),
  //             buildCardUpgradeAmuletItemObject(amulet.equippedShoes),
  //           ],
  //         )
  //       ],
  //     )));
  //
  //   return buildWatchVisible(amulet.playerUpgradeMode, Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       child,
  //       // width8,
  //       // buildWindowStash(),
  //     ],
  //   ));
  // }

  Widget buildWindowStash() => buildNotifier(
      amulet.playerStashNotifier, () => Container(
        padding: paddingAll8,
        color: amuletStyle.containerColor,
        child: Column(
          children: [
            Row(
              children: [
                buildIconStash(),
                width8,
                buildDialogTitle('STASH'),
              ],
            ),
            Row(children: const[
              SlotType.Weapon,
              SlotType.Helm,
              SlotType.Armor,
              SlotType.Shoes,
            ].map((slotType) {
              return onPressed(
                action: () {
                  amulet.playerStashSlot = slotType;
                  amulet.notifyStashChanged();
                },
                child: Container(
                    padding: paddingAll8,
                    color: slotType == amulet.playerStashSlot ? Colors.white38 : Colors.white12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: buildText(slotType.name)),
              );
            }).toList(growable: false),),
            height16,
            Container(
              height: amulet.engine.screen.height - 320,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: amulet.playerStash
                      .map(buildStashRow)
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        ),
      )
  );

  Widget buildStashRow(AmuletItemObject amuletItemObject) {

    final buttonEquip = MouseOver(
      builder: (mouseOver) {
        return Container(
          alignment: Alignment.centerLeft,
          width: 200,
          padding: paddingAll8,
          color: mouseOver ? Colors.black26 : Colors.black12,
          child: onPressed(
            onEnter: () {
              amuletItemObjectHover.value = amuletItemObject;
              amuletItemObjectHoverUpgrade = false;
            },
            onExit: () {
              if (amuletItemObjectHover.value == amuletItemObject){
                amuletItemObjectHover.value = null;
              }
            },
            action: () => amulet.equipStashItem(amuletItemObject),
            child: buildCardLargeAmuletItemObjectTitle(amuletItemObject),
          ),
        );
      }
    );

    final buttonSell = MouseOver(
      builder: (mouseOver) {
        return onPressed(
            action: () {
              amulet.sellStashItem(amuletItemObject);
            },
            child: buildBorder(
              padding: paddingAll8,
              color: mouseOver ? Colors.white54 : Colors.white38,
              fillColor: mouseOver ? Colors.white12 : Colors.transparent,
              width: 2,
              child: Row(
                children: [
                  buildText('sell ${amuletItemObject.sellValue}', size: 14),
                  iconGold,
                ],
              ),
            ));
      }
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          buttonEquip,
          width16,
          buttonSell,
        ],
      ),
    );

  }

  // Widget buildCardUpgradeAmuletItemObject(AmuletItemObject? amuletItemObject){
  //   if (amuletItemObject == null) return nothing;
  //
  //   final amuletItem = amuletItemObject.amuletItem;
  //   final level = amuletItemObject.level;
  //   final cost = amuletItem.getUpgradeCost(level);
  //   final fullyUpgraded = level >= amuletItem.maxLevel;
  //
  //   final controlButton = fullyUpgraded ?  buildText('MAX LEVEL')
  //       : buildWatch(amulet.playerGold, (playerGold) {
  //
  //     final canAfford = playerGold >= cost;
  //     final costText = buildText(cost, color: canAfford ? AmuletColors.Gold : Palette.apricot_2, size: 22);
  //
  //     return Container(
  //         color: canAfford ? Colors.green : Colors.white12,
  //         padding: paddingAll8,
  //         child: Row(
  //           children: [
  //             buildText('UPGRADE'),
  //             width8,
  //             costText,
  //             iconGold,
  //           ],
  //         ));
  //   });
  //
  //   return onPressed(
  //     action: () => amulet.upgradeSlotType(amuletItem.slotType),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         buildWatch(amulet.playerGold, (playerGold) {
  //           return Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 4),
  //               child: buildCardLargeAmuletItemObject(
  //                 amuletItemObject, compareLevels: true,
  //                 borderColor: Colors.orange
  //               ));
  //         }),
  //         height8,
  //         controlButton,
  //       ],
  //     ),
  //   );
  // }

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

  Widget buildIconPotion() => buildIcon(
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
                  Row(
                    children: [
                      buildIconQuest(),
                      width8,
                      buildDialogTitle('QUEST'),
                    ],
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

    final content = buildWatch(notifierEquipment, (t) => Row(
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

  Widget buildIconItems() => buildIcon(srcX: 725, srcY: 99, width: 22, height: 25);

  Widget buildIconItemsGrey() => buildIcon(srcX: 693, srcY: 99, width: 22, height: 25);

  Widget buildIconPlayerStats() =>
      buildIcon(srcX: 723, srcY: 131, width: 26, height: 26);

  Widget buildIconPlayerStatsGrey() =>
      buildIcon(srcX: 691, srcY: 131, width: 26, height: 26);

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

  Widget buildIconSkills() => buildIcon(srcX: 723, srcY: 39, width: 26, height: 20);

  Widget buildIconSkillsGrey({double scale = 1.0}) =>
      buildIcon(
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
      buildIcon(srcX: 691, srcY: 3, width: 26, height: 25);

  Widget buildIconQuest() =>
      buildIcon(srcX: 723, srcY: 3, width: 26, height: 25);


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
        child: buildIcon(
            srcX: 688,
            srcY: 96,
            width: 32,
            height: 32,
        ),
        active: true,
    );

    final notActive = buildToggleContainer(
      child: buildIcon(
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
            value > index ? barBlockWhite70 : barBlockWhite24)
      );

  static Widget buildBarBlock({
    required Color color,
    required double size,
  }) => Container(
      width: size,
      height: size,
      margin: EdgeInsets.symmetric(horizontal: size * (goldenRatio_0381 * 0.5)),
      color: color,
    );

  Widget buildIconAgility() =>
      buildIcon(srcX: 768, srcY: 64, width: 16, height: 16);

  Widget buildIconMagicRegen() =>
      buildIcon(srcX: 768, srcY: 48, width: 16, height: 16);

  Widget buildIconHealth() =>
      buildIcon(srcX: 768, srcY: 0, width: 16, height: 16);

  Widget buildIconHealAmount() =>
      buildIcon(srcX: 768, srcY: 320, width: 16, height: 16);

  Widget buildIconMagic() =>
      buildIcon(srcX: 784, srcY: 16, width: 16, height: 16);

  Widget buildIconHealthRegen() =>
      buildIcon(srcX: 768, srcY: 32, width: 16, height: 16);

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


  Widget skillBoxActive = Container(
    width: 5,
    height: 5,
    color: Colors.white,
    margin: const EdgeInsets.only(right: 4),
  );

  Widget skillBoxInactive = Container(
    width: 5,
    height: 5,
    color: Colors.white24,
    margin: const EdgeInsets.only(right: 4),
  );



  Widget buildCardLargeSkillType(SkillType skillType) {

    final level = amulet.getSkillTypeLevel(skillType);
    final title = buildCardLargeTitleTemplate(
      icon: buildIconSkillType(skillType),
      name: skillType.name.clean,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextSubtitle('lvl $level/${skillType.maxLevel}'),
          buildLevelBarSkillType(skillType)
        ],
      ),
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



  Widget buildLevelBarSkillType(SkillType skillType) {
    final level = skillTypeLevels[skillType] ?? (throw Exception());
    final delta = skillTypeLevelsDelta[skillType] ?? (throw Exception());
    final maxLevel = skillType.maxLevel;
    final levelPercentage = level.percentageOf(maxLevel);
    final deltaPercentage = delta.percentageOf(maxLevel);
    return buildLevelBarDelta(levelPercentage, deltaPercentage);
  }

  Widget buildLevelBar(double value) {
    const levelWidth = 50.0;
    const levelHeight = 5.0;

    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: value * levelWidth,
              height: levelHeight,
              color: Colors.white70,
            ),
            Container(
              width: (1.0 - value) * levelWidth,
              height: levelHeight,
              color: Colors.white24,
            ),
          ],
        );
  }

  Widget buildLevelBarDelta(double a, double b) {
    const levelWidth = 50.0;
    const levelHeight = 5.0;

    final start = min(a, b);
    final end = max(a, b);
    final diff = end - start;

    final widthA = levelWidth * start;
    final widthB = levelWidth * diff;
    final widthC = levelWidth - widthA - widthB;

    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widthA,
              height: levelHeight,
              color: Colors.white70,
            ),
            Container(
              width: widthB,
              height: levelHeight,
              color: b > a ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
            ),
            Container(
              width: widthC,
              height: levelHeight,
              color: Colors.white24,
            ),
          ],
        );
  }

  Widget buildRowValue(dynamic value) => buildText(value, color: Colors.white70);

  Widget buildCardLarge({
    required Widget header,
    required Widget title,
    required Widget content,
    Color? borderColor,
  }) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.orange, width: 2),
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
            buildCardLargeHeader(child: header, color: borderColor),
            Center(child: buildCardLargeTitle(child: title)),
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
    final canUpgrade = amulet.playerCanUpgrade.value && !amuletItemObject.maxLevelReached;
    final playerGold = amulet.playerGold.value;
    final canAfford = playerGold >= amuletItemObject.upgradeCost;

    return Column(
      children: [
        if (canUpgrade)
          buildState((rebuild) {
              return onPressed(
                onEnter: () {
                  amuletItemObjectHover.value = amuletItemObject;
                  amuletItemObjectHoverUpgrade = true;
                },
                onExit: (){
                  if (amuletItemObjectHover.value == amuletItemObject) {
                    amuletItemObjectHover.value = null;
                    amuletItemObjectHoverUpgrade = false;
                  }
                },
                action: () {
                  amulet.upgradeSlotType(amuletItemObject.amuletItem.slotType);
                },
                child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: AmuletColors.Gold,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            width: 50,
                            height: 20,
                            color: Colors.orange,
                            child: buildText('lvl ${amuletItemObject.level + 1}', size: 18, color: Colors.white70)),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildText(amuletItemObject.upgradeCost, color: canAfford ? Colors.green : Colors.red),
                              iconGold,
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
              );
            }
          ),
        onPressed(
            action: () => amulet.dropAmuletItem(amuletItem),
            child: buildMouseOverPanel(
                onEnter: () {
                  amuletItemObjectHover.value = amuletItemObject;
                  amuletItemObjectHoverUpgrade = false;
                },
                onExit: () => amuletItemObjectHover.value = null,
                bottom: 150,
                left: 0,
                panel: buildCardLargeAmuletItemObject(amuletItemObject),
                child: buildCardSmallAmuletItemObject(amuletItemObject)
            ),
        ),
      ],
    );
  }

  Widget buildIconHealthCost() =>
      buildIcon(
        srcX: 768,
        srcY: 208,
        width: 16,
        height: 16,
      );

  Widget buildIconMagicCost() =>
      buildIcon(
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
    return buildIcon(
          srcX: src[0],
          srcY: src[1],
          width: src.tryGet(2) ?? size,
          height: src.tryGet(3) ?? size,
          dstX: dstX,
          dstY: dstY,
    );
  }

  Widget buildCardLargeAmuletItemObjectTitle(AmuletItemObject amuletItemObject){
    final amuletItem = amuletItemObject.amuletItem;
    return buildCardLargeTitleTemplate(
      icon: buildIconAmuletItem(amuletItem),
      name: amuletItem.label,
      subtitle: buildBars(
          total: amuletItem.maxLevel,
          value: amuletItemObject.level,
      ),
      // subtitle: Column(
      //   children: [
      //     buildTextSubtitle('lvl ${amuletItemObject.level}/${amuletItem.maxLevel}'),
      //     buildLevelBar(amuletItemObject.levelPercentage),
      //   ],
      // ),
    );
  }

  Widget buildBarBlocks(int current, int max) =>
      Row(
        children: List.generate(max,
            (index) => index < current ? barBlockWhite70 : barBlockWhite24),
      );

  Widget buildBarBlocksSmall(int current, int max) =>
      Row(
        children: List.generate(max,
            (index) => index < current ? barBlockSm70 : barBlockSm24),
      );

  Widget buildCardLargeAmuletItemObject(AmuletItemObject amuletItemObject, {
    bool compareLevels = false,
    Color? borderColor,
  }) {

    final amuletItem = amuletItemObject.amuletItem;

    final header = buildCardLargeHeaderText(
        amuletItem.slotType.name.clean
    );

    final content = compareLevels
        ? buildCardLargeAmuletItemObjectContentCompareLevel(amuletItemObject)
        : buildCardLargeAmuletItemObjectContent(
          amuletItemObject,
    );

    final title = buildCardLargeAmuletItemObjectTitle(amuletItemObject);

    return buildCardLarge(
        header: header,
        title: title,
        content: content,
        borderColor: borderColor,
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

  Widget buildCardLargeAmuletItemObjectContentCompareLevel(AmuletItemObject amuletItemObject){

    final amuletItem = amuletItemObject.amuletItem;
    return Container(
      padding: paddingAll8,
      child: Column(
        children: [
            ...SkillType.values.map((skillType) {

              final skillLevel = amuletItemObject.getSkillLevel(skillType);
              final skillLevelNext = amuletItem.getSkillTypeLevel(
                  skillType: skillType,
                  level: amuletItemObject.level + 1
              );

              final diff = skillLevelNext - skillLevel;

              if (skillLevel <= 0 && skillLevelNext <= 0) return nothing;

              final icon = Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: buildIconSkillType(skillType)
              );

              final controlLevel = buildText('+$skillLevel', color: Colors.green);
              final controlLevelNext = buildText('+$diff', color: Colors.green);
              final controlName = buildText(skillType.name.clean, color: Colors.white70, size: 15);

              return Container(
                color: Colors.black12,
                margin: const EdgeInsets.only(bottom: 6),
                padding: paddingAll4,
                child: Row(
                  children: [
                    icon,
                    width8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controlName,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            controlLevel,
                            if (diff > 0)
                            buildText(' > ', color: Colors.white60),
                            if (diff > 0)
                            controlLevelNext,
                          ],
                        )

                      ],
                    ),
                  ],
                ),
              );
            }),
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

  Widget buildCardLargeHeader({required Widget child, Color? color}) =>
      Container(
        color: color ?? Colors.orange,
        alignment: Alignment.center,
        child: child,
        height: 30,
      );

  Widget buildCardLargeTitleTemplate({
    required Widget icon,
    required String name,
    required Widget subtitle,
  }) =>
      Row(
        // mainAxisAlignment: mainAxisAlignment,
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
              subtitle,
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
        width: amuletStyle.widthCardLarge,
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

  Widget buildIconDamage() => buildIcon(
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



  Widget buildIconRange() => buildIcon(
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
        SkillType.Split_Shot => buildIcon(
              srcX: 768,
              srcY: 240,
              width: 16,
              height: 16,
          ),
        _ => buildText('Amount')
      };

  Widget buildIconHealthSteal() =>
      buildIcon(srcX: 768, srcY: 256, width: 16, height: 16);

  Widget buildIconMagicSteal() =>
      buildIcon(srcX: 768, srcY: 272, width: 16, height: 16);

  Widget buildIconAttackSpeed() =>
      buildIcon(srcX: 768, srcY: 288, width: 16, height: 16);

  Widget buildIconAreaDamage() =>
      buildIcon(srcX: 768, srcY: 304, width: 16, height: 16);

  Widget buildIconCriticalHitPoints() =>
      buildIcon(srcX: 768, srcY: 336, width: 16, height: 16);

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
      notifierSkillTypes,
      (_) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  margin: EdgeInsets.only(right: 32),
                  child: buildPlayerSkillAttack()),
              buildRowPlayerSkillsPassive(),
              buildRowPlayerSkillsActive(),
            ],
          ));

  Widget buildRowPlayerSkillsPassive() => buildNotifier(
      amulet.playerSkillsNotifier, () {
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

    final a = skillTypeLevels[skillType] ?? (throw Exception());
    final b = skillTypeLevelsDelta[skillType] ?? (throw Exception());
    final c = b - a;

    final child = Container(
      color: Palette.brown_4,
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: size,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildText(amulet.getSkillTypeLevel(skillType), color: Palette.brown_0),
              ],
            ),
            alignment: Alignment.center,
            color: Palette.brown_4,
          ),
          Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Palette.brown_3,
              child: buildIconSkillType(skillType)),
          height2,
          buildLevelBarSkillType(skillType),
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

    final value = amulet.playerSkillRight == skillType ? borderActive : borderNotActive;

    return buildMouseOverPanel(
        bottom: 90,
        left: -60,
        panel: buildCardLargeSkillType(skillType),
        child: Column(
          children: [
            if (c != 0)
              Column(
                children: List.generate(c.abs(), (index) => c > 0 ? blockGreen : blockRed),
              ),
              // Container(
              //   margin: const EdgeInsets.only(bottom: 16),
              //   width: 50,
              //   height: 50,
              //   color: Palette.brown_3,
              //   child: buildText(c.toStringSigned, color: c > 0 ? Colors.green : Colors.red),
              //   alignment: Alignment.center,
              // ),
            value,
          ],
        ),
    );
  }

  Widget buildCardSmallEmpty() => buildCardSmall(
      title: nothing,
      child: nothing,
      footer: nothing,
  );

  Widget buildCardSmallAmuletItemObject(AmuletItemObject amuletItemObject) =>
      buildCardSmallAmuletItem(
        amuletItem: amuletItemObject.amuletItem,
        level: amuletItemObject.level,
      );


  Widget buildCardSmallAmuletItem({
    required AmuletItem amuletItem,
    required int level,
  }) =>
      buildCardSmall(
        title: buildCardTitleText(level),
        child: buildIconAmuletItem(amuletItem),
        // footer: buildBarBlocksSmall(level.percentageOf(amuletItem.maxLevel)),
        footer: buildBarBlocksSmall(level, amuletItem.maxLevel),
      );


  late final iconPotionEmpty = buildIcon(
      srcX: 784,
      srcY: 32,
      width: 16,
      height: 16,
  );

  late final iconPotionHealth = buildIcon(
      srcX: 784,
      srcY: 48,
      width: 16,
      height: 16,
  );

  late final iconPotionMagic = buildIcon(
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

  Widget buildCardTitleText(dynamic value) => buildText(value, color: Palette.brown_0);

  Widget buildCardSmall({
    required Widget title,
    required Widget child,
    required Widget footer,
  }) {
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
          height4,
          footer,
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
      buildPlayerGold(),
      width4,
      buildTogglePlayerQuest(),
      width4,
      buildToggleInventory(),
    ],
  );

  Widget buildPlayerGold() {
    final title = buildWatch(amulet.playerGold, buildCardTitleText);
    final child = buildCardSmallHalf(title: title, child: iconGold);
    final panel = buildHint('Use a fireplace to upgrade equipment');
    return buildMouseOverPanel(child: child, panel: panel, top: 60);
  }

  Widget buildCardSmallHalfGold(int amount) =>
      buildCardSmallHalf(
          title: buildText(amount),
          child: iconGold,
      );

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
    return buildIcon(
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
      buildIcon(
        srcX: src[0].toDouble(),
        srcY: src[1].toDouble(),
        width: src[2].toDouble(),
        height: src[3].toDouble(),
      );

  Widget buildIcon({
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
          child: buildIcon(
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
          child: buildIcon(
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

  Widget buildIconStash() => buildIcon(srcX: 720, srcY: 64, width: 32, height: 32);
}

String formatFramesToSeconds(int frames){
  const fps = 45;
  return '${(frames / fps).toStringAsFixed(2)} sec';
}

Widget buildWatchVisible(Watch<bool> watch, Widget child, {bool condition = true}) =>
    buildWatch(watch, (t) => t == condition ? child : nothing);

Widget buildWatchNull<T>(Watch<T?> watch, Widget Function(T t) build) =>
    buildWatch(watch, (t) => t == null ? nothing : nothing);

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

Widget buildNotifier(Watch watch, Widget Function() build) => buildWatch(watch, (t) => build());