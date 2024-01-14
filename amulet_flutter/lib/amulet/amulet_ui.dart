
import 'package:flutter/material.dart';

import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/maps/map_amulet_element_to_icon_type.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_icon.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/website/widgets/gs_fullscreen.dart';
import 'package:golden_ratio/constants.dart';
import 'package:amulet_engine/packages/lemon_math.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'ui/builders/build_item_slot.dart';
import 'ui/containers/build_container_item_hover.dart';
import 'ui/containers/build_container_player_front.dart';
import 'ui/widgets/amulet_world_map.dart';
import 'ui/widgets/mmo_item_image.dart';

class AmuletUI {
  static const itemImageSize = 64.0;
  static const margin1 = 16.0;
  static const margin2 = 130.0;
  static const margin3 = 315.0;
  static const margin4 = 560.0;

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
              // return grab;
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
          // Positioned(top: 4, left: 4, child: buildPlayerStatsRow()),
          Positioned(
            bottom: margin1,
            left: margin1,
            child: buildDialogPlayerInventory(),
          ),
          buildPlayerAimTarget(),
          // buildPositionedAmuletItemHover(),
          buildPositionedAmuletItemInformation(),
          buildPositionedMessage(),
          Positioned(
            top: margin2,
            child: Container(
              width: amulet.engine.screen.width,
              alignment: Alignment.center,
              child: buildError(),
            ),
          ),
          Positioned(
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
          )
        ]),
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
                GSContainer(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      buildPlayerHealthBar(),
                      height2,
                      // buildPlayerWeapons(),
                      buildInventoryEquipped(),
                    ],
                  ),
                ),
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
            buildRow('',  AmuletItemImage(amuletItem: current), target == null ? nothing : AmuletItemImage(amuletItem: target)),
            buildRow('',
                buildText(current.label, color: mapItemQualityToColor(current.quality)),
                target == null ? null : buildText(target.label, color: mapItemQualityToColor(target.quality)),
            ),
            buildRowText('value', current.quality.name, target?.quality.name),
            buildRowText('skill', current.skillType?.name, target?.skillType?.name),
            buildRowInt('min dmg', current.damageMin, target?.damageMin),
            buildRowInt('max dmg', current.damageMax, target?.damageMax),
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
        child: Container(
          width: amulet.engine.screen.width,
          alignment: Alignment.center,
          child: buildWatch(amulet.player.aimTargetSet, (t) {
            if (!t) return nothing;
            return name;
          }),
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

  Widget buildInventoryItems() {
    return buildWatch(amulet.items, (items) {
      return buildInventoryContainer(
          child: Row(
            children: [
              Column(
                  children: List.generate(items.length ~/ 2,
                          (index) => buildItemSlot(items[index], amulet: amulet),
                      growable: false)),
              Column(
                  children: List.generate(
                      items.length ~/ 2,
                          (index) => buildItemSlot(
                          items[index + (items.length ~/ 2)],
                          amulet: amulet),
                      growable: false)),
            ],
          ));

    });

  }

  Widget buildInventoryContainer({required Widget child}) => Container(
        child: child,
        padding: const EdgeInsets.all(2),
      );

  Widget buildInventoryEquipped() => buildInventoryContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                buildItemSlot(amulet.equippedWeapon,
                    amulet: amulet,
                    onEmpty: IsometricIcon(
                      iconType: IconType.Inventory_Weapon,
                      color: Colors.black12.value,
                      scale: 0.3,
                    )),
                buildItemSlot(amulet.equippedHelm,
                    amulet: amulet,
                    onEmpty: IsometricIcon(
                      iconType: IconType.Inventory_Helm,
                      color: Colors.black12.value,
                      scale: 0.3,
                    )),
                buildItemSlot(amulet.equippedBody,
                    amulet: amulet,
                    onEmpty: IsometricIcon(
                      iconType: IconType.Inventory_Armour,
                      color: Colors.black12.value,
                      scale: 1,
                    )),
                buildItemSlot(amulet.equippedShoes,
                    amulet: amulet,
                    onEmpty: IsometricIcon(
                      iconType: IconType.Inventory_Shoes,
                      color: Colors.black12.value,
                      scale: 0.6,
                    ))
                // buildItemSlot(amulet.equippedHandLeft,
                //     amulet: amulet,
                //     onEmpty: IsometricIcon(
                //       iconType: IconType.Inventory_Glove_Left,
                //       color: Colors.black12.value,
                //       scale: 0.6,
                //     )),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //
                //     // buildItemSlot(amulet.equippedLegs,
                //     //     amulet: amulet,
                //     //     onEmpty: IsometricIcon(
                //     //       iconType: IconType.Inventory_Legs,
                //     //       color: Colors.black12.value,
                //     //       scale: 0.6,
                //     //     )),
                //   ],
                // ),
                // buildItemSlot(amulet.equippedHandRight,
                //     amulet: amulet,
                //     onEmpty: IsometricIcon(
                //       iconType: IconType.Inventory_Glove_Right,
                //       color: Colors.black12.value,
                //       scale: 0.6,
                //     )),
              ],
            ),
          ],
        ),
      );

  Widget buildPlayerHealthBar() {
    const width = 282.0;
    const height = 16.0;

    return IgnorePointer(
      child: buildWatch(amulet.player.healthPercentage, (healthPercentage) {
        if (healthPercentage == 0) {
          return nothing;
        }
        return Container(
          width: width,
          height: height,
          color: Colors.black26,
          padding: const EdgeInsets.all(2),
          alignment: Alignment.center,
          child: Container(
            width: width * healthPercentage,
            height: height,
            color: Color.lerp(Colors.red, Colors.green, healthPercentage),
          ),
        );
      }),
    );
  }

  Widget buildPlayerLevel() => buildWatch(amulet.playerLevel,
      (level) => Container(
          alignment: Alignment.center,
          width: 40,
          height: 40,
          child: buildText(level, color: Colors.white70, size: 22, bold: true)));

  Widget buildPlayerExperienceBar() {
    const width = 186.0;
    const height = 10.0;
    return buildBorder(
        width: 2,
        color: Colors.white70,
        radius: BorderRadius.zero,
        child: buildWatch(
            amulet.playerExperienceRequired,
            (experienceRequired) =>
                buildWatch(amulet.playerExperience, (experience) {
                  if (experienceRequired <= 0) return nothing;

                  final percentage =
                      clamp(experience / experienceRequired, 0, 1);
                  return Tooltip(
                    message: '$experience / $experienceRequired',
                    child: Container(
                      width: width,
                      height: height,
                      alignment: Alignment.centerLeft,
                      color: Colors.white12,
                      child: Container(
                          color: Colors.white70,
                          width: width * percentage,
                          height: height),
                    ),
                  );
                })));
  }


  Widget buildPlayerStatsRow() => Row(
    children: [
      GSContainer(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                buildPlayerLevel(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // buildAmuletElements(),
                    buildPlayerExperienceBar(),
                  ],
                ),
                buildElementPoints(),
              ],
            ),
          ),
      width4,
      onPressed(
        action: amulet.windowVisibleQuests.toggle,
        child: GSContainer(
            height: 32,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: buildText('QUEST'),
        ),
      ),
    ],
  );

  Widget buildInventoryButton() {
    const scale = 1.8;
    final iconOpen = IsometricIcon(
      iconType: IconType.Inventory_Open,
      scale: scale,
    );
    final iconClosed = IsometricIcon(
      iconType: IconType.Inventory_Closed,
      scale: scale,
    );
    final watchInventoryOpen = buildWatch(amulet.playerInventoryOpen,
        (inventoryOpen) => inventoryOpen ? iconOpen : iconClosed);

    final flashingTrue =
        ColorChangingContainer(size: itemImageSize, child: watchInventoryOpen);
    final flashingFalse = GSContainer(
      width: itemImageSize,
      height: itemImageSize,
      child: watchInventoryOpen,
    );

    return onPressed(
        action: amulet.toggleInventoryOpen,
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildWatch(
                amulet.options.highlightIconInventory,
                (highlightIconInventory) =>
                    highlightIconInventory ? flashingTrue : flashingFalse),
            Positioned(
              top: 8,
              left: 8,
              child: buildText('Q', color: Colors.white70),
            ),
          ],
        ));
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

  Widget buildDialogPlayerInventory() {
    final inventoryItems = buildInventoryItems();
    final dialog = GSContainer(
      rounded: true,
      width: 450,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: buildDialogTitle('CHEST')),
              buildButtonClose(
                  action: amulet.toggleInventoryOpen),
            ],
          ),
          height32,
          inventoryItems,
          // height16,
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     buildInventoryEquipped(),
          //     // buildInventoryPlayerFront(),
          //     // buildPlayerTreasures(),
          //   ],
          // )
        ],
      ),
    );

    // final inventoryButton = buildInventoryButton();

    return MouseRegion(
      onEnter: (_) => amulet.setInventoryOpen(true),
      onExit: (_) {
        if (amulet.dragging.value == null) {
          amulet.setInventoryOpen(false);
        }
      },
      child: buildWatch(
          amulet.playerInventoryOpen,
          (inventoryOpen) => inventoryOpen
              ? dialog
              // : inventoryButton),
              : nothing),
    );
  }

  Widget buildInventoryPlayerFront() => Container(
        width: 180 * goldenRatio_0618,
        height: 180,
        child: buildContainerPlayerFront(
          player: amulet.player,
          height: 180,
          borderColor: Colors.transparent,
        ),
      );

  Widget buildAmuletElements() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          AmuletElement.values.map(buildAmuletElement).toList(growable: false));

  Widget buildAmuletElement(AmuletElement amuletElement) {
    final icon =
        IsometricIcon(iconType: mapAmuletElementToIconType(amuletElement));
    final watchAmuletElement = amulet.getAmuletElementWatch(amuletElement);

    final row = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
            height: 32,
            child: icon),
        Container(
            color: Colors.black12,
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: buildWatch(watchAmuletElement,
                (t) => buildText(t, color: Colors.white70))),
      ],
    );

    return buildWatch(
        amulet.elementPointsAvailable,
        (elementPointsAvailable) => onPressed(
              action: elementPointsAvailable
                  ? () => amulet.upgradeAmuletElement(amuletElement)
                  : null,
              child: row,
            ));
  }

  Widget buildElementPoints() =>
      buildWatch(amulet.elementPoints, (elementPoints) {
        if (elementPoints <= 0) {
          return nothing;
        }
        return GSContainer(
          width: 50,
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          child: buildText('+$elementPoints', color: Colors.green),
        );
      });

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
}

