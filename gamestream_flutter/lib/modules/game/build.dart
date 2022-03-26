import 'package:bleed_common/GameStatus.dart';
import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/RoyalCost.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:bleed_common/version.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/enums.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/module.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/compose/buildTextBox.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../toString.dart';
import 'state.dart';

const empty = SizedBox();

class GameBuild {

  final GameState state;
  final GameActions actions;

  final double slotSize = 50;

  GameBuild(this.state, this.actions);

  Widget buildUIGame() {
    print("buildUIGame()");

    return WatchBuilder(state.player.uuid, (String uuid) {
      if (uuid.isEmpty) {
        return ui.layouts.waitingForGame();
      }
      return WatchBuilder(core.state.status, (GameStatus gameStatus) {
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
            return ui.layouts.waitingForGame();
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.CUBE3D:
                return buildUI3DCube();
              default:
                return layoutRoyal();
            }
          case GameStatus.Finished:
            return buildDialogGameFinished();
          default:
            return text(enumString(gameStatus));
        }
      });
    });
  }

  Widget _magicBar() {
    final width = 280.0;
    final height = width *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(state.player.magic, (double magic) {
      final maxMagic = state.player.maxMagic.value;
      if (maxMagic <= 0) return empty;
      final percentage = magic / maxMagic;
      return Container(
        width: width,
        height: height,
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

      final maxHealth = state.player.maxHealth;
      if (maxHealth <= 0) return empty;

      final percentage = health / maxHealth;
      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
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
    return button("Respawn", actions.respawn);
  }

  Widget layoutRoyal(){
    const _pad = 8.0;

    return WatchBuilder(state.player.alive, (bool alive){
      return layout(
          children: [
            if (alive)
            bottomCenter(child: Column(
              children: [
                _magicBar(),
                _healthBar(),
              ],
            ), padding: _pad),
            Positioned(
                left: _pad,
                top: _pad,
                child: WatchBuilder(state.debugPanelVisible, (bool visible){
                  return visible ? buildDebugPanel() : ui.widgets.time;
                })),
            Positioned(
                left: _pad,
                bottom: _pad,
                child: WatchBuilder(state.debugPanelVisible, (bool visible){
                  return visible ? toggleDebugMode() : empty;
                })),
            if (alive)
            Positioned(
                right: _pad,
                bottom: _pad,
                child: _panelMagicStore()),
            buildTextBox(),
            Positioned(
              child: Row(
                children: [
                  toggleAudioEnabled(),
                  width8,
                  ui.widgets.exit,
                  if (core.state.account.isNotNull)
                    ui.widgets.saveCharacter,
                  if (core.state.account.isNotNull)
                    ui.widgets.loadCharacter,
                ],
              ),
              right: _pad,
              top: _pad,
            ),
            if (!alive)
            respawnButton(),
            _panelHighlightedStoreSlot(),
            buildHighlightedSlot(),
          ]);
    });
  }

  Widget buildHighlightedSlot(){
    return WatchBuilder(state.highlightSlot, (Slot? slot){
      if (slot == null) return empty;
      final slotType = slot.type.value;
      if (slotType.isEmpty) return empty;

      return Positioned(
        right: 220,
        bottom: 10,
        child: Container(
          width: 200,
          height: 300,
          padding: const EdgeInsets.all(8),
          color: colours.brownDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text(slotTypeNames[slotType] ?? "?"),
            ],
          ),
        )
      );
    });
  }

  WatchBuilder<SlotType> _panelHighlightedStoreSlot() {
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
        // right: (engine.screen.width - engine.mousePosition.x) + 50,
        // top: engine.mousePosition.y,
        right: 220,
        top: state.highlightPanelPosition.y,
      );
    });
  }

  Container _panelMagicStore() {
    return Container(
            width: 200,
            padding: padding8,
            color: colours.brownDark,
              child: Column(
                children: [
                  rowOrbs(),
                  // height16,
                  // panel(child: _panelStore()),
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
            buildInventorySlot(slots.slot1, 1),
            buildInventorySlot(slots.slot4, 4),
          ],
        ),
        Column(
          children: [
            buildInventorySlot(slots.slot2, 2),
            buildInventorySlot(slots.slot5, 5),
          ],
        ),
        Column(
          children: [
            buildInventorySlot(slots.slot3, 3),
             buildInventorySlot(slots.slot6, 6),
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
        return resources.icons.books.grey;
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
          SlotType.Armour_Padded,
          SlotType.Magic_Robes,
        ),
        shopSlotRow(
          SlotType.Rogue_Hood,
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
          SlotType.Spell_Tome_Ice_Ring,
          SlotType.Spell_Tome_Split_Arrow,
        ),
        shopSlotRow(
          SlotType.Potion_Red,
          SlotType.Potion_Blue,
          SlotType.Golden_Necklace,
        ),
        shopSlotRow(
          SlotType.Silver_Pendant,
          SlotType.Handgun,
          SlotType.Shotgun,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                resources.icons.ruby,
                width8,
                AdvancedWatchBuilder(state.player.orbs.ruby, (int value, int previous){
                  return text(value);
                }),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              resources.icons.emerald,
              width8,
              AdvancedWatchBuilder(state.player.orbs.emerald, (int value, int previous){
                return text(value);
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              resources.icons.topaz,
              width8,
              AdvancedWatchBuilder(state.player.orbs.topaz, (int value, int previous){
                return text(value);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEquippedWeaponSlot(){
    final weapon = state.player.slots.weapon;
    return onPressed(
        callback: actions.unequipWeapon,
        child: Stack(
          children: [
            WatchBuilder(weapon.type, (SlotType slotType){
              final child = slot(slotType: slotType, color: colours.white382);
              if (slotType.isEmpty) return child;
              return child;
            }),
            WatchBuilder(weapon.amount, (int amount){
              if (amount < 0) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: text(amount, size: style.fontSize.small),
              );
            })
          ],
        ));

  }

  Widget _panelEquipped(){
    final slots = state.player.slots;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildEquippedWeaponSlot(),
              WatchBuilder(slots.armour, (SlotType slotType){
                final child = slot(slotType: slotType, color: colours.white382);
                if (slotType.isEmpty) return child;
                return onPressed(
                    callback: actions.unequipArmour,
                    child: child);
              }),
              WatchBuilder(slots.helm, (SlotType slotType){
                final child = slot(slotType: slotType, color: colours.white382);
                if (slotType.isEmpty) return child;
                return onPressed(
                    callback: actions.unequipHelm,
                    child: child);
              }),
            ],
          )
        ],
      );
  }

  Widget buildInventorySlot(Slot slot, int index) {

    final amount = WatchBuilder(slot.amount, (int amount){
      if (amount < 0) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: text(amount, size: style.fontSize.small),
      );
    });


    final type = WatchBuilder(slot.type, (SlotType slotType) {

      final child = mouseOver(builder: (BuildContext context, bool mouseOver){
        if (mouseOver){
          state.highlightSlot.value = slot;
        } else if (state.highlightSlot.value == slot){
          state.highlightSlot.value = null;
        }

        return Container(
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
      });


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

    return Stack(
      children: [
        type,
        amount,
      ],
    );
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

      if (isOver){
        final renderObject = context.findRenderObject();
        if (renderObject != null){
          final translation = renderObject.getTransformTo(null).getTranslation();
          state.highlightPanelPosition.x = translation.x;
          state.highlightPanelPosition.y = translation.y;
        }
      }


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

  Widget mousePosition(){
    return Refresh((){
      return text("Mouse Screen: x: ${engine.mousePosition.x}, y: ${engine.mousePosition.y}");
    });
  }

  Widget mouseDownState(){
    return WatchBuilder(engine.mouseLeftDown, (bool down){
      return text("Mouse Down: $down");
    });
  }

  Widget mouseRowColumn(){
    return Refresh((){
      return text("Mouse row:$mouseRow, column $mouseColumn");
    });
  }

  Widget get buildTotalParticles {
    return Refresh((){
      return text("Particles: ${isometric.state.particles.length}");
    });
  }


  Widget get buildActiveParticles {
    return Refresh((){
      return text("Active Particles: ${isometric.properties.totalActiveParticles}");
    });
  }

  Widget get tileAtMouse {
    return Refresh((){
      return text("Tile: ${isometric.queries.tileAtMouse.name}");
    });
  }

  Widget get playerPosition {
    final character = modules.game.state.player;
    return Refresh((){
      return text("Player Position: X: ${character.x}, Y: ${character.y}");
    });
  }

  Widget get playerId {
    final character = modules.game.state.player;
    return Refresh((){
      return text("Player Id: ${character.id}");
    });
  }


  Widget get offscreenTiles {
    return Refresh((){
      return text("Offscreen: ${isometric.state.offScreenTiles}");
    });
  }

  Widget get onScreenTiles {
    return Refresh((){
      return text("OnScreen: ${isometric.state.onScreenTiles}");
    });
  }

  Widget get mousePositionWorld {
    return Refresh((){
      return text("Mouse World: x: ${mouseWorldX.toInt()}, y: ${mouseWorldY.toInt()}");
    });
  }

  Widget get byteCountWatcher {
    return WatchBuilder(byteLength, (int count){
        return text("Bytes: $count");
    });
  }

  Widget get bufferLengthWatcher {
    return WatchBuilder(bufferSize, (int count){
      return text("Buffer Size: $count");
    });
  }

  Widget buildVersion(){
    return text(version);
  }

  Widget frameSmoothing(){
    return WatchBuilder(state.frameSmoothing, (bool frameSmoothing){
       return text("Frame Smoothing: $frameSmoothing", onPressed: (){
         state.frameSmoothing.value = !state.frameSmoothing.value;
       });
    });
  }

  Widget toggleDebugMode(){
    return WatchBuilder(state.compilePaths, (bool compilePaths){
      return button("Debug Mode: $compilePaths", actions.toggleDebugPaths);
    });
  }

  Widget toggleAudioEnabled(){
    return WatchBuilder(audio.enabled, (bool enabled){
      return button(text("Audio", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggle);
    });
  }

  Widget buildDebugPanel(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          ui.widgets.time,
          buildTotalZombies(),
          buildTotalPlayers(),
          mouseRowColumn(),
          buildVersion(),
          buildTotalParticles,
          buildActiveParticles,
          tileAtMouse,
          // offscreenTiles,
          // onScreenTiles,
          mousePositionWorld,
          byteCountWatcher,
          bufferLengthWatcher,
          playerPosition,
          playerId,
      ],
    );
  }
}

