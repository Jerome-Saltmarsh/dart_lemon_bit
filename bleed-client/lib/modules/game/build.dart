import 'dart:math';

import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/RoyalCost.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/game/actions.dart';
import 'package:bleed_client/modules/game/enums.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/resources.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/compose/buildTextBox.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:bleed_client/widgets.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../toString.dart';
import 'state.dart';

class GameBuild {

  final GameState state;
  final GameActions actions;

  final double slotSize = 50;

  GameBuild(this.state, this.actions);

  Widget buildUIGame() {
    return WatchBuilder(state.player.uuid, (String uuid) {
      if (uuid.isEmpty) {
        return buildLayoutLoadingGame();
      }
      return WatchBuilder(state.status, (GameStatus gameStatus) {
        switch (gameStatus) {
          case GameStatus.Counting_Down:
            return buildDialog(
                width: style.dialogWidthMedium,
                height: style.dialogHeightMedium,
                child: WatchBuilder(game.countDownFramesRemaining, (int frames){
                  final seconds =  frames ~/ 30.0;
                  return Center(child: text("Starting in $seconds seconds"));
                }));
          case GameStatus.Awaiting_Players:
            return buildLayoutLobby() ;
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.MMO:
                // return playerCharacterType();
                return layoutRoyal();
              case GameType.Custom:
                return playerCharacterType();
              case GameType.Moba:
                return playerCharacterType();
              case GameType.BATTLE_ROYAL:
                return layoutRoyal();
              case GameType.CUBE3D:
                return buildUI3DCube();
              default:
                return text(game.type.value);
            }
          case GameStatus.Finished:
            return buildDialogGameFinished();
          default:
            return text(enumString(gameStatus));
        }
      });
    });
  }

  Widget playerCharacterType() {
    return WatchBuilder(modules.game.state.player.characterType, (CharacterType value) {
      if (value == CharacterType.Human) {
        return _buildHudWeapons();
      }
      return _buildHudAbilities();
    });
  }

  Widget _buildHudWeapons(){
    return WatchBuilder(modules.game.state.soldier.weaponType, (WeaponType weaponType){
      return layout(
          padding: 16,
          topLeft: buildTime(),
          topRight: buttons.exit,
          bottomLeft: buildWeaponMenu(),
      );
    });
  }

  Widget _magicBar() {
    final width = 280.0;
    final height = width *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(state.player.magic, (double magic) {
      final percentage = magic / state.player.maxMagic.value;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: colours.none, width: 2),
            borderRadius: borderRadius4),
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.blueDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: colours.blue,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${magic.toInt()} / ${state.player.maxMagic.value}'),
            ),
          ],
        ),
      );
    });
  }

  Widget _healthBar() {
    final width = 280.0;
    final height = width *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(state.player.health, (double health) {
      final percentage = health / state.player.maxHealth;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: colours.none, width: 2),
            borderRadius: borderRadius4),
        alignment: Alignment.centerLeft,
        // padding: EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.redDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: colours.red,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${health.toInt()} / ${state.player.maxHealth}'),
            ),
          ],
        ),
      );
    });
  }

  Widget respawnButton(){
    return WatchBuilder(state.player.alive, (bool alive){
      if (alive) return empty;
      return button("Respawn", actions.respawn);
    });
  }

  Widget layoutRoyal(){
    return layout(
        children: [
          bottomCenter(child: Column(
            children: [
              _magicBar(),
              _healthBar(),
            ],
          ), padding: 8),
          Positioned(
              left: 8,
              top: 8,
              child: mouseRowColumn()),
          Positioned(
              left: 8,
              bottom: 8,
              child: toggleDebugMode()),
          Positioned(
              right: 8,
              bottom: 8,
              child: _panelMagicStore()),
          respawnButton(),
      _panelHighlightedSlot(),
    ]);
  }

  WatchBuilder<SlotType> _panelHighlightedSlot() {
    return WatchBuilder(state.highLightSlotType, (SlotType slotType) {
      if (slotType == SlotType.Empty) return empty;

      final cost = slotTypeCosts[slotType];
      if (cost == null){
        throw Exception("No SlotTypeCost found for $slotType");
      }

      return Positioned(
        child: Container(
          padding: padding16,
          color: colours.brownDark,
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: text(slotTypeNames[slotType] ?? slotType.name, color: colours.white80, bold: true, size: 20)),
              height8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (cost.topaz > 0)
                    Row(
                      children: [resources.icons.topaz, text(cost.topaz)],
                    ),
                  if (cost.rubies > 0)
                    Row(
                      children: [resources.icons.ruby, text(cost.rubies)],
                    ),
                  if (cost.emeralds > 0)
                    Row(
                      children: [resources.icons.emerald, text(cost.emeralds)],
                    )
                ],
              ),
              height8,
              Column(
                children: [
                  if (slotType.damage > 0)
                    _itemSlotStatRow("Damage", slotType.damage),
                  if (slotType.health > 0)
                    _itemSlotStatRow("Health", slotType.health),
                  if (slotType.magic > 0)
                    _itemSlotStatRow("Magic", slotType.magic),
                ],
              )
            ],
          )
        ),
        right: (engine.state.screen.width - engine.state.mousePosition.x) + 50,
        top: engine.state.mousePosition.y,
      );
    });
  }

  Container _panelMagicStore() {
    return Container(
            width: 200,
            // height: 650,
            padding: padding8,
            color: colours.brownDark,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                      child: rowOrbs()),
                  height16,
                  panel(child: _panelStore()),
                  height16,
                  panel(child: _panelEquipped()),
                  height16,
                  panel(child: _panelInventory())
                ],
              ),
        );
  }

  Widget panel({required Widget child, Alignment? alignment, EdgeInsets? padding}){
    return Container(
        color: colours.brownLight,
        child: child,
        alignment: alignment,
        padding: padding,
    );
  }

  Widget _itemSlotStatRow(String name, dynamic value) {
    return margin(
      top: 8,
      child: panel(
        padding: padding8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text(name),
            text("+$value"),
          ],
        ),
      ),
    );
  }

  Widget _panelInventory() {
    final slots = state.player.slots;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            _inventorySlot(slots.slot1, 1),
            _inventorySlot(slots.slot4, 4),
          ],
        ),
        Column(
          children: [
            _inventorySlot(slots.slot2, 2),
            _inventorySlot(slots.slot5, 5),
          ],
        ),
        Column(
          children: [
            _inventorySlot(slots.slot3, 3),
             _inventorySlot(slots.slot6, 6),
          ],
        ),
      ],
    );
  }

  Widget mapStoreTabToIcon(StoreTab value){
    switch(value){
      case StoreTab.Weapons:
        return resources.icons.sword;
      case StoreTab.Armor:
        return resources.icons.shield;
      case StoreTab.Items:
        return resources.icons.book;
    }
  }

  Widget _panelStore() {
    return WatchBuilder(state.storeTab, (StoreTab activeStoreTab){
      return Column(
        children: [
          _storeTabs(activeStoreTab),
          if (activeStoreTab == StoreTab.Weapons)
          _storeTabWeapons(),
          if (activeStoreTab == StoreTab.Armor)
            _storeTabArmour(),
          if (activeStoreTab == StoreTab.Items)
            _storeTabItems(),
        ],
      );
    });
  }

  Widget _storeTabs(StoreTab activeStoreTab) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: storeTabs.map((storeTab) => button(
              mapStoreTabToIcon(storeTab),
                  () => state.storeTab.value = storeTab,
              borderColor: none,
             fillColor: activeStoreTab == storeTab ? colours.white618 : colours.white10,
            borderColorMouseOver: none,
            fillColorMouseOver: activeStoreTab == storeTab ? colours.white618 : colours.black618,
            borderWidth: 0,
            width: 60,
            height: 50,
            borderRadius: borderRadius2,
          )).toList(),
        );
  }

  Widget _storeTabWeapons() {
    return Column(
          children: [
            shopSlotRow(
                SlotType.Sword_Wooden,
                SlotType.Sword_Short,
                SlotType.Sword_Long
            ),
            shopSlotRow(
                SlotType.Bow_Wooden,
                SlotType.Bow_Green,
                SlotType.Bow_Gold
            ),
            shopSlotRow(
                SlotType.Staff_Wooden,
                SlotType.Staff_Blue,
                SlotType.Staff_Golden
            )
          ],
        );
  }

  Column _storeTabArmour() {
    return Column(
      children: [
        shopSlotRow(
          SlotType.Body_Blue,
          SlotType.Empty,
          SlotType.Empty,
        ),
        shopSlotRow(
          SlotType.Empty,
          SlotType.Steel_Helmet,
          SlotType.Magic_Hat,
        ),
        shopSlotRow(
          SlotType.Empty,
          SlotType.Empty,
          SlotType.Empty,
        )
      ],
    );
  }

  Column _storeTabItems() {
    return Column(
      children: [
        shopSlotRow(
          SlotType.Spell_Tome_Fireball,
          SlotType.Frogs_Amulet,
          SlotType.Silver_Pendant,
        ),
        shopSlotRow(
          SlotType.Potion_Red,
          SlotType.Potion_Blue,
          SlotType.Empty,
        ),
        shopSlotRow(
          SlotType.Empty,
          SlotType.Empty,
          SlotType.Empty,
        )
      ],
    );
  }


  Widget shopSlotRow(SlotType a, SlotType b, SlotType c){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _storeSlot(a),
        _storeSlot(b),
        _storeSlot(c),
      ],
    );
  }

  Widget rowOrbs(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            resources.icons.topaz,
            width4,
            textWatch(state.player.orbs.topaz),
          ],
        ),
        width8,
        Row(
          children: [
            resources.icons.ruby,
            width4,
            textWatch(state.player.orbs.ruby),
          ],
        ),
        width8,
        Row(
          children: [
            resources.icons.emerald,
            width4,
            textWatch(state.player.orbs.emerald),
          ],
        ),
      ],
    );
  }

  Widget _buildHudAbilities(){
    return WatchBuilder(modules.game.state.player.alive, (bool alive) {
      return Stack(
        children: [
          buildTextBox(),
          if (alive) buildBottomRight(),
          buildTopLeft(),
          if (alive) characterStatistics(),
          if (!hud.state.observeMode && !alive) _buildViewRespawn(),
          if (!alive && hud.state.observeMode) _buildRespawnLight(),
          _buildServerText(),
          buildTopRight(),
          buildNumberOfPlayersRequiredDialog(),
          // bottomLeft(child: fps),
        ],
      );
    });
  }

  Widget _buildViewRespawn() {
    print("buildViewRespawn()");
    return Container(
      width: engine.state.screen.width,
      height: engine.state.screen.height,
      child: Row(
        mainAxisAlignment: axis.main.center,
        crossAxisAlignment: axis.cross.center,
        children: [
          Container(
              padding: padding16,
              width: max(engine.state.screen.width * goldenRatio_0381, 480),
              decoration: BoxDecoration(
                  borderRadius: borderRadius4, color: Colors.black38),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: axis.cross.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius4,
                          color: colours.blood,
                        ),
                        padding: padding8,
                        child: text("BLEED beta v1.0.0")),
                    height16,
                    text("YOU DIED", size: 30, underline: true),
                    height16,
                    Container(
                      padding: padding16,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius4,
                        color: black26,
                      ),
                      child: Column(
                        crossAxisAlignment: axis.cross.center,
                        children: [
                          text("Please Support Me"),
                          height16,
                          Row(
                            mainAxisAlignment: axis.main.even,
                            children: [
                              onPressed(
                                child: border(
                                    child: Container(
                                        width: 70,
                                        alignment: Alignment.center,
                                        child: text(
                                          "Paypal",
                                        )),
                                    radius: borderRadius4,
                                    padding: padding8),
                                callback: () {
                                  // openLink(links.paypal);
                                },
                                // hint: links.paypal
                              ),
                              onPressed(
                                child: border(
                                    child: Container(
                                        width: 70,
                                        alignment: Alignment.center,
                                        child: text("Patreon")),
                                    radius: borderRadius4,
                                    padding: padding8),
                                callback: () {
                                  // openLink(links.patreon);
                                },
                                // hint: links.patreon
                              )
                            ],
                          ),
                          height8,
                        ],
                      ),
                    ),
                    height8,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius4,
                        color: black26,
                      ),
                      padding: padding16,
                      child: Column(
                        children: [
                          text("Hints"),
                          Row(
                            mainAxisAlignment: axis.main.center,
                            crossAxisAlignment: axis.cross.center,
                            children: [
                              Container(
                                  width: 350,
                                  alignment: Alignment.center,
                                  child: text(hud.currentTip)),
                              width16,
                            ],
                          ),
                        ],
                      ),
                    ),
                    height32,
                    Row(
                      mainAxisAlignment: axis.main.between,
                      children: [
                        onPressed(
                            child: Container(
                                padding: padding16, child: text("Close")),
                            callback: () {
                              hud.state.observeMode = true;
                            }),
                        width16,
                        mouseOver(
                            builder: (BuildContext context, bool mouseOver) {
                              return onPressed(
                                child: border(
                                    child: text(
                                      "RESPAWN",
                                      weight: bold,
                                    ),
                                    padding: padding16,
                                    radius: borderRadius4,
                                    color: Colors.white,
                                    borderWidth: 1,
                                    fillColor: mouseOver ? black54 : black26),
                                callback: actions.respawn,
                                hint: "Click to respawn",
                              );
                            })
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildServerText() {
    return WatchBuilder(modules.game.state.player.message, (String value) {
      if (value.isEmpty) return blank;

      return Positioned(
          child: Container(
            width: engine.state.screen.width,
            alignment: Alignment.center,
            child: Container(
              width: 300,
              color: Colors.black45,
              padding: padding16,
              child: Column(
                children: [
                  text(modules.game.state.player.message.value),
                  height16,
                  button("Next", clearPlayerMessage),
                ],
              ),
            ),
          ),
          bottom: 100);
    });
  }

  Positioned _buildRespawnLight() {
    return Positioned(
        top: 30,
        child: Container(
            width: engine.state.screen.width,
            child: Column(
              crossAxisAlignment: axis.cross.center,
              children: [
                Row(mainAxisAlignment: axis.main.center, children: [
                  onPressed(
                      callback: () {
                        actions.respawn();
                        hud.state.observeMode = false;
                      },
                      child: border(
                          child: text("Respawn", size: 30),
                          padding: padding8,
                          radius: borderRadius4))
                ]),
                height32,
                text("Hold E to pan camera")
              ],
            )));
  }

  Widget _panelEquipped(){
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WatchBuilder(state.player.slots.weapon, (SlotType weapon){
                return onPressed(
                    callback: actions.unequipWeapon,
                    child: slot(slotType: weapon, color: colours.white382));
              }),
              WatchBuilder(state.player.slots.armour, (SlotType slotType){
                return onPressed(
                    callback: actions.unequipArmour,
                    child: slot(slotType: slotType, color: colours.white382));
              }),
              WatchBuilder(state.player.slots.helm, (SlotType slotType){
                return onPressed(
                    callback: actions.unequipHelm,
                    child: slot(slotType: slotType, color: colours.white382));
              }),
            ],
          )
        ],
      );
  }

  Widget _inventorySlot(Watch<SlotType> slot, int index){
    return WatchBuilder(slot, (SlotType slotType){

      final child = Container(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                child: getSlotTypeImage(slotType),
              ),
              Positioned(child: text(index, size: 14, color: colours.white618), bottom: 5, right: 5,)
            ],
          ));

      if (slotType.isEmpty) return child;

      return onPressed(
        callback: (){
          actions.equipSlot(index);
        },
        onRightClick: (){
          actions.sellSlotItem(index);
        },
        child: child,
      );
    });
  }

  Widget _storeSlot(SlotType slotType){

    if (slotType.isEmpty){
      return Container(
          width: slotSize,
          height: slotSize,
          child: getSlotTypeImage(slotType));
    }

    return mouseOver(onEnter: () {
      state.highLightSlotType.value = slotType;
    }, onExit: () {
      if (state.highLightSlotType.value == slotType){
        state.highLightSlotType.value = SlotType.Empty;
      }
    }, builder: (context, isOver) {
      return onPressed(
        callback: (){
          actions.purchaseSlotType(slotType);
        },
        child: Container(
            width: slotSize,
            height: slotSize,
            color: isOver && !slotType.isEmpty ? colours.black382 : none,
            child: getSlotTypeImage(slotType)),
      );
    });
  }

  Widget slot({required SlotType slotType, required Color color}){
    return Container(
        width: 50,
        height: 50,
        color: color,
        child: getSlotTypeImage(slotType));
  }

  Widget getSlotTypeImage(SlotType value){
    if (state.slotTypeImages.containsKey(value)){
      return state.slotTypeImages[value]!;
    }
    return resources.icons.unknown;
  }

  Widget mouseRowColumn(){
    return Refresh((){
      return text("Mouse row:$mouseRow, column $mouseColumn");
    });
  }

  Widget toggleDebugMode(){
    return WatchBuilder(state.compilePaths, (bool compilePaths){
      return button("Debug Mode: $compilePaths", actions.toggleDebugPaths);
    });
  }
}

List<SlotType> mapStoreTabSlotTypes(StoreTab storeTab){
  switch(storeTab){
    case StoreTab.Weapons:
      return slotTypes.weapons;
    case StoreTab.Armor:
      return slotTypes.armour;
    case StoreTab.Items:
      return slotTypes.items;
  }
}
