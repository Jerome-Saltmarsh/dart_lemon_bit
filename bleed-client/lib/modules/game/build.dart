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
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/resources.dart';
import 'package:bleed_client/send.dart';
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
    return WatchBuilder(modules.game.state.player.weaponType, (WeaponType weaponType){
      return layout(
          padding: 16,
          topLeft: buildTime(),
          topRight: buttons.exit,
          bottomLeft: buildWeaponMenu(),
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

  Widget layoutRoyal(){
    return layout(
        children: [
          bottomCenter(child: _healthBar(), padding: 8),
          Positioned(
              right: 8,
              bottom: 8,
              child: _panelMagicStore()),
      _highlightedSlotType(),
    ]);
  }

  WatchBuilder<SlotType> _highlightedSlotType() {
    return WatchBuilder(state.highLightSlotType, (SlotType slotType) {
      if (slotType == SlotType.Empty) return empty;

      final cost = slotTypeCosts[slotType];
      if (cost == null){
        throw Exception("no cast found for $slotType");
      }

      return Positioned(
        child: Container(
          padding: padding8,
          color: colours.brownDark,
          child: Column(
            children: [
              text(slotTypeNames[slotType]),
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

            ],
          )
        ),
        right: (engine.state.screen.width - mouseX) + 50,
        top: mouseY,
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
                  Container(
                      color: colours.brownLight,
                      child: panelStore()),
                  height16,
                  Container(
                      color: colours.brownLight,
                      child: columnInventory())
                ],
              ),
        );
  }

  Widget columnInventory() {
    final slots = state.player.slots;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            playerSlot(slots.slot1, 1),
            playerSlot(slots.slot2, 2),
          ],
        ),
        Column(
          children: [
            playerSlot(slots.slot3, 3),
            playerSlot(slots.slot4, 4),
          ],
        ),
        Column(
          children: [
            playerSlot(slots.slot5, 5),
             playerSlot(slots.slot6, 6),
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

  Widget panelStore() {
    return WatchBuilder(state.storeTab, (StoreTab activeStoreTab){
      return Column(
        children: [
          Row(
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
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _storeSlot(SlotType.Sword_Wooden),
                  _storeSlot(SlotType.Sword_Short),
                  _storeSlot(SlotType.Sword_Long),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _storeSlot(SlotType.Bow_Wooden),
                  _storeSlot(SlotType.Bow_Green),
                  _storeSlot(SlotType.Bow_Gold),
                ],
              ),
              shopSlotRow(
                  SlotType.Staff_Wooden,
                  SlotType.Staff_Blue,
                  SlotType.Staff_Golden
              )
            ],
          ),
        ],
      );
    });
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
                                callback: sendRequestRevive,
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
                        sendRequestRevive();
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

  Widget playerSlot(Watch<SlotType> slot, int index){
    return WatchBuilder(slot, (SlotType slotType){
      return onPressed(
        callback: (){
          // TODO show context menu
        },
        onRightClick: (){
          actions.sellSlotItem(index);
        },
        child: Container(
            width: 50,
            height: 50,
            child: getSlotTypeImage(slotType)),
      );
    });
  }

  Widget _storeSlot(SlotType slotType){
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
            width: 50,
            height: 50,
            color: isOver ? colours.black382 : none,
            child: getSlotTypeImage(slotType)),
      );
    });
  }

  Widget getSlotTypeImage(SlotType value){
    if (state.slotTypeImages.containsKey(value)){
      return state.slotTypeImages[value]!;
    }
    return resources.icons.unknown;
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

