
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/classes/item_slot.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_icon.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/sprite/render_sprite.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_sprite/lib.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'ui/src.dart';

class AmuletUI {

  static const itemImageSize = 64.0;
  static const margin1 = 16.0;
  static const margin2 = 130.0;
  static const margin3 = 315.0;
  static const margin4 = 560.0;

  final Amulet amulet;

  AmuletUI(this.amulet);

  Widget buildAmuletUI() => Stack(
    alignment: Alignment.center,
    children: [
      buildNpcText(),
      Positioned(
        bottom: margin1,
        left: margin1,
        child: buildPlayerWeapons(),
      ),
      Positioned(
        top: margin1,
        left: margin1,
        child: buildDialogPlayerInventory(),
      ),
      buildPlayerAimTarget(),
      Positioned(
         top: margin1,
         left: margin3 + 50,
         child: buildItemHoverDialog(),
      ),
      Positioned(
          bottom: margin2,
          right: margin1,
          child: buildDialogPlayerTalents()
      ),
      Positioned(
          bottom: margin2,
          right: margin4,
          child: buildTalentHoverDialog()
      ),
      Positioned(
          bottom: margin1,
          right: margin1,
          child: buildPlayerStatsRow(),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: amulet.engine.screen.width,
          height: amulet.engine.screen.height,
          alignment: Alignment.center,
          child: buildDialogCreateCharacter(),
        ),
      ),
      Positioned(
          bottom: margin2,
          child: Container(
              width: amulet.engine.screen.width,
              alignment: Alignment.center,
              child: buildError(),
          ),
      ),
    ],
  );

  Widget buildError() {
    final color = Colors.red.withOpacity(0.7);
    return IgnorePointer(child: buildWatch(amulet.error, (error) => buildText(error, color: color)));
  }

  Positioned buildNpcText() {

    const width = 200.0;
    const height = width * goldenRatio_0618;

    final options = buildWatch(amulet.npcOptionsReads, (t) =>
        Container(
          width: width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: amulet.npcOptions.map((option)=> onPressed(
                action: () => amulet.network.sendAmuletRequest.selectTalkOption(amulet.npcOptions.indexOf(option)),
                child: buildText(option))).toList(growable: false)),
        ));

    return Positioned(
      bottom: margin1,
      child:
      buildWatch(amulet.playerInteracting, (interacting) => !interacting ? nothing :
      buildWatch(amulet.npcText, (npcText) => npcText.isEmpty ? nothing :
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
                  action: amulet.network.sendAmuletRequest.endInteraction,
                  child: buildText('x', size: 25)),
            ),
          ],
        ),
      )),
    )
    );
  }

  Widget buildPlayerWeapons() => GSContainer(
    rounded: true,
    child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(amulet.weapons.length, buildWeaponSlotAtIndex),
        ),
      );

  Widget buildPlayerTreasures() => buildInventoryContainer(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                amulet.treasures.length,
                (i) => buildItemSlot(amulet.treasures[i])
            )
        ),
      );

  Widget buildPlayerAimTarget() {

    const width = 120.0;
    const height = width * goldenRatio_0381;

    final healthPercentageBox = buildWatch(amulet.player.aimTargetHealthPercentage, (healthPercentage) => Container(
      width: width * healthPercentage,
      height: height,
      color: amulet.colors.red_3,
    ));

    final name = Container(
      alignment: Alignment.centerLeft,
      height: height,
      color: amulet.colors.brownDark,
      width: width,
      child: Stack(
        children: [
          buildWatch(amulet.player.aimTargetAction, (targetAction) {
             if (targetAction != TargetAction.Attack)
               return nothing;

             return healthPercentageBox;
          }),
          Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: FittedBox(
              child: buildWatch(amulet.player.aimTargetName, (name) => buildText(name.replaceAll('_', ' '))),
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

  Widget buildWeaponSlotAtIndex(int index, {double size = 64}) {

    final backgroundSelectedWeapon = buildWatch(
        amulet.equippedWeaponIndex,
        (equippedWeaponIndex) => Positioned(
              child: GSContainer(
                color: index == equippedWeaponIndex
                    ? Colors.white12
                    : Colors.black12,
                width: size,
                height: size,
                rounded: true,
              ),
            ));

    final backgroundActivePower = buildWatch(amulet.activatedPowerIndex, (activatedPowerIndex){
      if (index != activatedPowerIndex)
        return nothing;

      return Positioned(
        child: GSContainer(
          color: Colors.green,
          width: size,
          height: size,
          rounded: true,
        ),
      );
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          backgroundSelectedWeapon,
          backgroundActivePower,
          Positioned(child: buildItemSlot(amulet.weapons[index], color: Colors.transparent)),
          Positioned(
              top: 8,
              left: 8,
              child: buildText(
                  const['A', 'S', 'D', 'F'][index],
                  color: Colors.white70,
              )
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: buildWatch(amulet.weapons[index].cooldown, (cooldown) => cooldown <= 0 ? nothing: buildText(cooldown, color: Colors.red))
          )
        ],
      ),
    );
  }

  buildItemHoverDialog({double edgePadding = 150}) => buildWatch(
      amulet.itemHover,
      (item) => item == null
          ? nothing
          : GSContainer(
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
            )));

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

  Widget buildInventoryItems() => buildInventoryContainer(
    child: Row(
      children: [
        Column(
            children: List.generate(
                amulet.items.length ~/ 2, (index) => buildItemSlot(amulet.items[index]),
                growable: false)
        ),
        Column(
            children: List.generate(
                amulet.items.length ~/ 2, (index) => buildItemSlot(amulet.items[index + (amulet.items.length ~/ 2)]),
                growable: false)
        ),
      ],
    )
  );

  Widget buildInventorySlot({required Widget child}) => Container(
        color: Colors.black12,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        width: 64,
        height: 64,
        child: child,
    );

  Widget buildInventoryContainer({required Widget child}) => Container(
        child: child,
        padding: const EdgeInsets.all(2),
    );

  Widget buildInventoryEquipped() => buildInventoryContainer(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildItemSlot(amulet.equippedHelm),
        buildItemSlot(amulet.equippedBody),
        buildItemSlot(amulet.equippedLegs),
        buildItemSlot(amulet.equippedHandLeft),
        buildItemSlot(amulet.equippedHandRight),
        buildItemSlot(amulet.equippedShoes),
      ],),
  );

  Widget buildTalentPointsRemaining() =>
      buildWatch(
          amulet.playerTalentPoints,
      (skillPoints) => onPressed(
          action: amulet.network.sendAmuletRequest.toggleTalentsDialog,
          child: GSContainer(
              child: buildText('Talents $skillPoints',
                  color: skillPoints > 0 ? Colors.green : Colors.white70))));

  Widget buildPlayerHealthBar(){
    const width = 200.0;
    const height = 40.0;
     return Tooltip(
       message: 'Health',
       child: buildWatch(amulet.player.maxHealth, (maxHealth) {
         if (maxHealth == 0) return nothing;
         return buildWatch(amulet.player.health, (health) {
           return Container(
             width: width,
             height: height,
             child: Stack(
               children: [
                 Container(
                   width: width,
                   height: height,
                   color: amulet.style.containerColor,
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
                     child: buildText('$health / $maxHealth', color: Colors.white54),
                 ),
               ],
             ),
           );
         });
       }),
     );
  }

  Widget buildPlayerLevel({double size = 50}) =>
      GSContainer(
        width: size * goldenRatio_1618,
        height: size,
        rounded: true,
        child: buildWatch(amulet.playerLevel, (level) => buildText('Lvl $level', color: Colors.white70))
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
                  amulet.playerExperienceRequired,
                      (experienceRequired) =>
                          buildWatch(amulet.playerExperience, (experience) {
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

  Widget buildTalent(MMOTalentType talentType){
    final currentLevel = amulet.getTalentLevel(talentType);
    final nextLevel = currentLevel + 1;
    final maxLevel = talentType.maxLevel;
    final maxLevelReached = currentLevel >= maxLevel;
    final cost = nextLevel * talentType.levelCostMultiplier;
    final talentPoints = amulet.playerTalentPoints.value;
    final canUpgrade = currentLevel < maxLevel && cost <= talentPoints;
    final canAfford = cost <= talentPoints;

    const barWidth = 130.0;
    const barHeight = barWidth * goldenRatio_0381 * goldenRatio_0618;

    return MouseRegion(
      onEnter: (_){
        amulet.talentHover.value = talentType;
      },
      onExit: (_){
        if (amulet.talentHover.value == talentType){
          amulet.talentHover.value = null;
        }
      },
      child: GSContainer(
        color: Colors.black26,
        margin: const EdgeInsets.all(4),
        padding: null,
        rounded: true,
        child: onPressed(
          action: canUpgrade ? () => amulet.network.sendAmuletRequest.upgradeTalent(talentType) : null,
          child: Container(
            padding: const EdgeInsets.all(4),
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 12,
                  left: 12,
                  child: MMOTalentIcon(talentType: talentType, size: 32),
                ),
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      // buildText(talentType.name.replaceAll('_', ' ')),
                      Row(
                        children: [
                          Container(
                            color: Colors.black26,
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.green,
                                  alignment: Alignment.centerLeft,
                                  width: barWidth * (currentLevel / maxLevel),
                                  height: barHeight,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: barWidth,
                                  height: barHeight,
                                  child: buildText('$currentLevel / $maxLevel', color: Colors.white54),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
                if (!maxLevelReached)
                  Positioned(
                      top: 2,
                      right: 2,
                      child: GSContainer(
                          rounded: true,
                          color: Colors.black12,
                          padding: const EdgeInsets.all(4),
                          child: buildText(cost, color: canAfford ? Colors.green : Colors.red)
                      )
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlayerStatsRow() => Row(
      children: [
        buildTalentPointsRemaining(),
        width8,
        buildPlayerLevel(),
        width8,
        buildPlayerExperienceBar(),
        width8,
        buildPlayerHealthBar(),
      ],
    );

  Widget buildInventoryButton() {
    const scale = 1.8;
    final iconOpen = IsometricIcon(iconType: IconType.Inventory_Open, scale: scale,);
    final iconClosed = IsometricIcon(iconType: IconType.Inventory_Closed, scale: scale,);
    return onPressed(
        action: amulet.network.sendAmuletRequest.toggleInventoryOpen,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: GSContainer(
                width: itemImageSize,
                height: itemImageSize,
                child: buildWatch(amulet.playerInventoryOpen, (inventoryOpen) =>
                    inventoryOpen ? iconOpen : iconClosed)
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: buildText('Q', color: Colors.white70),
            ),
          ],
        )
    );
  }

  Widget buildItemSlot(ItemSlot slot, {Color? color}) => Container(
    margin: const EdgeInsets.all(2),
    child: buildWatch(
        slot.item,
        (item) =>
            buildWatch(amulet.dragging, (dragging) => DragTarget(
              onWillAccept: (value) => true,
              onAccept: (value) {
                if (value is! ItemSlot) return;
                amulet.reportItemSlotDragged(src: value, target: slot);
              },
              builder: (context, data, rejectData) => Container(
                  width: 64.0,
                  height: 64.0,
                  color: dragging != null && slot.acceptsDragFrom(dragging)
                      ? amulet.colors.teal_4
                      : (color ?? amulet.colors.brown_3),
                  alignment: Alignment.center,
                  child: item == null
                      ? nothing
                      : Draggable(
                    data: slot,
                    feedback: MMOItemImage(item: item, size: 64),
                    onDragStarted: () {
                      this.amulet.dragging.value = slot;
                    },
                    onDragEnd: (details) {
                      if (amulet.engine.mouseOverCanvas){
                        amulet.dropItemSlot(slot);
                      }
                      this.amulet.dragging.value = null;
                    },
                    child: onPressed(
                      onRightClick: () =>
                          amulet.dropItemSlot(slot),
                      action: () => amulet.reportItemSlotLeftClicked(slot),
                      child: MMOItemImage(item: item, size: 64),
                    ),
                  ),
                ),
            ))
           ),
  );


  Widget buildButtonClose({required Function action}) => onPressed(child: Container(
      width: 80,
      height: 80 * goldenRatio_0381,
      alignment: Alignment.center,
      color: Colors.black26,
      child: buildText('x', color: Colors.white70, size: 22)
  ), action: action
  );

  Widget buildDialogTitle(String text) =>
      buildText(text, size: 28.0, color: Colors.white70);

  Widget buildDialogPlayerInventory(){

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
                  child: buildDialogTitle('INVENTORY')),
              buildButtonClose(action: amulet.network.sendAmuletRequest.toggleInventoryOpen),
            ],
          ),
          height16,
          height16,
          Row(
            children: [
              buildInventoryEquipped(),
              width16,
              Column(
                children: [
                  buildPlayerTreasures(),
                  buildInventoryItems(),
                ],
              ),
            ],
          )
        ],),
    );

    final inventoryButton = buildInventoryButton();

    return buildWatch(amulet.playerInventoryOpen, (inventoryOpen) =>
    inventoryOpen ? dialog : inventoryButton);
  }

  Widget buildDialogPlayerTalents() {
    return buildWatch(
        amulet.playerTalentsChangedNotifier,
            (_) {

          final dialog = GSContainer(
            width: 500,
            rounded: true,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 20),
                        child: buildDialogTitle('TALENTS ${amulet.playerTalentPoints.value}')
                    ),
                    buildButtonClose(action: amulet.network.sendAmuletRequest.toggleTalentsDialog),
                  ],
                ),
                GSContainer(
                    height: amulet.engine.screen.height - 270,
                    alignment: Alignment.topLeft,
                    child: GridView.count(
                        crossAxisCount: 4,
                        children: MMOTalentType.values
                            .map(buildTalent)
                            .toList(growable: false))),
              ],
            ),
          );

          return buildWatch(amulet.playerTalentDialogOpen,
                  (playersDialogOpen) => !playersDialogOpen ? nothing : dialog);
        });
  }

  Widget buildTalentHoverDialog() => buildWatch(
      amulet.talentHover,
          (talentType) => talentType == null
          ? nothing
          : GSContainer(
        child: buildText(talentType.name),
      ));

  void renderSprite({
    required Canvas canvas,
    required Sprite? sprite,
    required int row,
    required int column,
    int? color = null,
    double scale = 1.0,
  }) {
    if (sprite == null){
      return;
    }

    final blendMode = color == null ? BlendMode.dstATop : BlendMode.modulate;
    final frame = sprite.getFrame(row: row, column: column);

    spriteExternal(
      canvas: canvas,
      sprite: sprite,
      frame: frame,
      color: 0,
      scale: scale,
      dstX: 0,
      dstY: 0,
      blendMode: blendMode,
    );

    if (color != null){
      spriteExternal(
        canvas: canvas,
        sprite: sprite,
        frame: sprite.getFrame(row: row, column: column),
        color: color,
        scale: scale,
        dstX: 0,
        dstY: 0,
        blendMode: blendMode,
      );
    }
  }

  Widget buildDialogCreateCharacter({double width = 300}) => Container(
    child: buildWatchBool(
        amulet.characterCreated, () {
          var row = 0;

          final engine = amulet.engine;
          final images = amulet.images;
          final player = amulet.player;
          final sprites = images.kidCharacterSprites;
          final nameController = TextEditingController();
          final canvasFrame = ValueNotifier(0);
          final canvasTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {

            if (canvasFrame.value++ % 3 == 0) {
              row = (row + 1) % 8;
            };
          });

          engine.disableKeyEventHandler();

          return OnDisposed(
            action: () {
              engine.enableKeyEventHandler();
              canvasTimer.cancel();
            },
            child: GSContainer(
              width: width,
              height: width * goldenRatio_1381,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // buildDialogTitle('CHARACTER CREATION'),
                    buildBorder(
                      width: 2,
                      color: Colors.white,
                      child: Container(
                        width: 100,
                        height: 150,
                        alignment: Alignment.center,
                        child: CustomCanvas(
                          frame: canvasFrame,
                          paint: (canvas, size) {
                            final color = 0;
                            final dstX = 0.0;
                            final dstY = 0.0;
                            final scale = 1.0;
                            final column = 0;
                            final gender = player.gender.value;
                            final isMale = gender == Gender.male;
                            final characterState = CharacterState.Idle;
                            final helm = sprites.helm[player.helmType.value]?.fromCharacterState(characterState);
                            final head = sprites.head[HeadType.regular]?.fromCharacterState(characterState);
                            final bodySprite = isMale ? sprites.bodyMale : sprites.bodyFemale;
                            final body = bodySprite[player.bodyType.value]?.fromCharacterState(characterState);
                            final torso = sprites.torso[gender]?.fromCharacterState(characterState);
                            final armsLeft = sprites.armLeft[ArmType.regular]?.fromCharacterState(characterState);
                            final armsRight = sprites.armRight[ArmType.regular]?.fromCharacterState(characterState);
                            final shoesLeft = sprites.shoesLeft[player.shoeType.value]?.fromCharacterState(characterState);
                            final shoesRight = sprites.shoesRight[player.shoeType.value]?.fromCharacterState(characterState);
                            final legs = sprites.legs[player.legsType.value]?.fromCharacterState(characterState);
                            final complexion = player.complexion.value;
                            final skinColor = player.skinColor.value;

                            renderSprite(sprite: torso, canvas: canvas, row: row, column: column, color: skinColor);
                            renderSprite(sprite: legs, canvas: canvas, row: row, column: column);
                            renderSprite(sprite: armsLeft, canvas: canvas, row: row, column: column, color: skinColor);
                            renderSprite(sprite: armsRight, canvas: canvas, row: row, column: column, color: skinColor);
                            renderSprite(sprite: shoesLeft, canvas: canvas, row: row, column: column);
                            renderSprite(sprite: shoesRight, canvas: canvas, row: row, column: column);
                            renderSprite(sprite: body, canvas: canvas, row: row, column: column);
                            renderSprite(sprite: head, canvas: canvas, row: row, column: column, color: skinColor);
                            renderSprite(sprite: helm, canvas: canvas, row: row, column: column);
                          }
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('NAME'),
                        Container(
                            width: 150,
                            child: TextField(
                                controller: nameController,
                                autofocus: true,
                            ),
                        ),
                      ],
                    ),
                    buildText('COMPLEXION'),
                    buildWatch(player.gender, (gender) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        buildText('BODY'),
                        Row(children: [
                          onPressed(
                            action: player.toggleGender,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: gender == Gender.male ? Colors.white38 : null,
                              child: buildText('Square'),
                            ),
                          ),
                          onPressed(
                            action: player.toggleGender,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: gender == Gender.female ? Colors.white38 : null,
                              child: buildText('Curvy'),
                            ),
                          ),
                        ]),
                    ])),
                    Expanded(child: const SizedBox()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        onPressed(
                            action: () {
                              amulet.createPlayer(
                                name: nameController.text,
                              );
                            },
                            child: buildText('START', size: 24, bold: true, color: Colors.green)
                        ),
                      ],
                    )

                  ],
                )),
          );
        },
        match: false,
    ),
  );
}
