import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/enums.dart';
import 'package:gamestream_flutter/modules/game/update.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/module.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/send.dart';
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

import '../isometric/enums.dart';
import 'state.dart';


class GameBuild {

  final GameState state;
  final GameActions actions;

  static const empty = SizedBox();

  final storeColumnKey = GlobalKey();
  final keyPanelStructure = GlobalKey();

  final slotSize = 50.0;

  GameBuild(this.state, this.actions);

  Widget buildUIGame() {
    print("buildUIGame()");

    return WatchBuilder(core.state.status, (GameStatus gameStatus) {
      switch (gameStatus) {
        case GameStatus.Counting_Down:
          return buildLayoutCountDown();
        case GameStatus.Awaiting_Players:
          return ui.layouts.buildLayoutLoading();
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
          return ui.layouts.buildLayoutLoading();
      }
    });
  }

  Widget buildLayoutCountDown() {
    return buildDialog(
        width: style.dialogWidthMedium,
        height: style.dialogHeightMedium,
        child: WatchBuilder(game.countDownFramesRemaining, (int frames){
          final seconds =  frames ~/ 30.0;
          return Center(child: text("Starting in $seconds seconds"));
        }));
  }

  Widget buildMagicBar() {
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

  Widget buildResourcePanel() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colours.brownDark,
            borderRadius: borderRadius4,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: resources.icons.resources.wood,
              ),
              Container(
                  alignment: Alignment.center,
                  width: 48,
                  height: 48,
                  child: textBuilder(modules.game.state.player.wood)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colours.brownDark,
            borderRadius: borderRadius4,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: resources.icons.resources.stone,
              ),
              Container(
                  alignment: Alignment.center,
                  width: 48,
                  height: 48,
                  child: textBuilder(modules.game.state.player.stone)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colours.brownDark,
            borderRadius: borderRadius4,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: resources.icons.resources.gold,
              ),
              Container(
                  alignment: Alignment.center,
                  width: 48,
                  height: 48,
                  child: textBuilder(modules.game.state.player.gold)),
            ],
          ),
        )


      ],
    );
  }

  Widget buildHealthBar() {
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
                // buildMagicBar(),
                // buildResourcePanel(),
                buildHealthBar(),
              ],
            ), padding: _pad),
            Positioned(
                left: _pad,
                top: _pad,
                child: WatchBuilder(state.debugPanelVisible, (bool visible){
                  return visible ? buildDebugPanel() : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildVersion(),
                      buildTime(),
                    ],
                  );
                })
            ),
            Positioned(
                left: _pad,
                bottom: _pad,
                child: boolBuilder(state.debugPanelVisible, widgetTrue: buildDebugMenu(), widgetFalse: buildScoreBoard()),
            ),
            // if (alive)
            // Positioned(
            //     right: _pad,
            //     bottom: _pad,
            //     child: buildBottomRight()
            // ),
            buildTextBox(),
            buildTopRight(),
            if (!alive)
            respawnButton(),
            buildHighlightedStoreSlot(),
            buildPanelHighlightedStructureType(),
            buildHighlightedSlot(),
            buildPanelUpgrades(),
          ]);
    });
  }

  Row buildDebugMenu() {
    return Row(
      children: [
        toggleDebugMode(),
        width8,
        button("Edit Map", () {
          core.actions.openMapEditor(newScene: false);
        }),
      ],
    );
  }

  Widget buildTopRight(){

    final menu = Row(
      children: [
        buildButtonFullScreen(),
        width8,
        buildButtonToggleCameraMode(),
        width8,
        buildButtonSkipTrack(),
        width8,
        buildToggleEnabledSound(),
        width8,
        buildToggleEnabledMusic(),
        width8,
        buildButtonExit(),
        // if (core.state.account.isNotNull)
        //   ui.widgets.saveCharacter,
        // if (core.state.account.isNotNull)
        //   ui.widgets.loadCharacter,
      ],
    );
    return Positioned(
      right: 8.0,
      top: 8.0,
      child: boolBuilder(modules.hud.menuVisible, widgetTrue: menu, widgetFalse: resources.icons.settings),
    );
  }

  Widget buildButtonExit() => button("Exit", core.actions.disconnect);

  Widget buildHighlightedSlot(){
    return WatchBuilder(state.highlightSlot, (Slot? slot){
      if (slot == null) return empty;
      final slotType = slot.type.value;
      if (slotType == SlotType.Empty) return empty;

      final name = SlotType.getName(slotType);
      final damage = SlotType.getDamage(slotType);
      final health = SlotType.getHealth(slotType);
      final magic = SlotType.getMagic(slotType);
      final range = SlotType.getRange(slotType);;

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
              text(name),
              if (damage > 0)
                text("Damage: $damage"),
              if (health > 0)
                text("Health: $health"),
              if (magic > 0)
                text("Magic: $magic"),
              if (range > 0)
                text("Range: $range"),

            ],
          ),
        )
      );
    });
  }

  Widget _buildUpgradeRow({
    required Function upgrade,
    required Function equip,
    required Widget icon,
    required String name
  }){
    return Row(
      children: [
        text("+", onPressed: upgrade, size: 30, color: colours.green, weight: FontWeight.bold),
        width16,
        onPressed(
          callback: equip,
          child: Row(
            children: [
              Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: icon
              ),
              width16,
              text(name),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPanelUpgrades() {
        return Positioned(
            top: 100,
            right: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 buildResourcePanel(),
                _buildUpgradeRow(
                  upgrade: Server.upgradePickaxe,
                  equip: Server.equipPickaxe,
                  icon: resources.icons.swords.pickaxe,
                  name: "Pickaxe",
                ),
                _buildUpgradeRow(
                  upgrade: Server.upgradeSword,
                  equip: Server.equipSword,
                  icon: resources.icons.swords.wooden,
                  name: "Sword",
                ),
              ],
            )
        );
  }

  Widget buildPanelHighlightedStructureType(){
    return WatchBuilder(state.highlightStructureType, (int? type){
       if (type == null) return const SizedBox();
       final context = keyPanelStructure.currentContext;
       if (context == null) return const SizedBox();
       final renderBox = context.findRenderObject() as RenderBox;

       final cost = StructureType.getCost(type);

       return Positioned(
        right: 220,
        top: renderBox.localToGlobal(Offset.zero).dy,
        child: Container(
          width: 200,
          // height: 200,
          padding: padding8,
          decoration: BoxDecoration(
            color: colours.brownDark,
            borderRadius: borderRadius4,
          ),
          child: Column(
            children: [
              text(StructureType.getName(type)),
              height8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (cost.wood > 0)
                  Column(
                    children: [
                      resources.icons.resources.wood,
                      text(cost.wood),
                    ],
                  ),
                  if (cost.stone > 0)
                    Column(
                      children: [
                        resources.icons.resources.stone,
                        text(cost.stone),
                      ],
                    ),
                  if (cost.gold > 0)
                    Column(
                      children: [
                        resources.icons.resources.gold,
                        text(cost.gold),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildHighlightedStoreSlot() {
    return WatchBuilder(state.highlightSlotType, (int slotType) {
      if (slotType == SlotType.Empty) return empty;

      final storeColumnContext = storeColumnKey.currentContext;
      var y = 0.0;
      if (storeColumnContext != null) {
        final renderBox = storeColumnContext.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);
        y = offset.dy;
      }

      final damage = SlotType.getDamage(slotType);
      final magic = SlotType.getMagic(slotType);
      final health = SlotType.getHealth(slotType);
      final name = SlotType.getName(slotType);

      return Positioned(
        right: 220,
        top: y,
        child: Container(
          padding: padding16,
          color: colours.brownDark,
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: text(name, color: colours.white80, bold: true, size: 20)),
              height8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                ],
              ),
              height8,
              Column(
                children: [
                  if (damage > 0)
                    _itemSlotStatRow("Damage", damage),
                  if (health > 0)
                    _itemSlotStatRow("Health", health),
                  if (magic > 0)
                    _itemSlotStatRow("Magic", magic),
                ],
              )
            ],
          )
        ),
      );
    });
  }

  // Widget buildBottomRight() {
  //   return Column(
  //     children: [
  //       buildPanelStructures(),
  //       height32,
  //       buildPanelStore(),
  //       height32,
  //       Container(
  //               width: 200,
  //               padding: padding8,
  //               color: colours.brownDark,
  //                 child: Column(
  //                   children: [
  //                     // buildPanelOrbs(),
  //                     // height16,
  //                     panel(child: _panelEquipped()),
  //                     height16,
  //                     panel(child: _panelInventory())
  //                   ],
  //                 ),
  //           ),
  //     ],
  //   );
  // }

  Widget panel({required Widget child, Alignment? alignment, EdgeInsets? padding, double? width}){
    return Container(
        color: colours.brownLight,
        child: child,
        alignment: alignment,
        padding: padding,
        width: width,
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

  // Widget _panelInventory() {
  //   final slots = state.player.slots;
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       Column(
  //         children: [
  //           buildInventorySlot(slots.slot1, 1),
  //           buildInventorySlot(slots.slot4, 4),
  //         ],
  //       ),
  //       Column(
  //         children: [
  //           buildInventorySlot(slots.slot2, 2),
  //           buildInventorySlot(slots.slot5, 5),
  //         ],
  //       ),
  //       Column(
  //         children: [
  //           buildInventorySlot(slots.slot3, 3),
  //            buildInventorySlot(slots.slot6, 6),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget mapStoreTabToIcon(StoreTab value) {
    switch (value) {
      case StoreTab.Weapons:
        return resources.icons.sword;
      case StoreTab.Armor:
        return resources.icons.shield;
      case StoreTab.Items:
        return resources.icons.books.grey;
    }
  }

  Widget buildPanelStructures() {
      return Container(
        key: keyPanelStructure,
        decoration: BoxDecoration(
          color: colours.brownDark,
          borderRadius: borderRadius4,
        ),
        child: Row(
          children: [
            MouseRegion(
              onEnter: (event) {
                state.highlightStructureType.value = StructureType.Tower;
              },
              onExit: (event) {
                if (state.highlightStructureType.value != StructureType.Tower) return;
                state.highlightStructureType.value = null;
              },
              child: onPressed(
                callback: modules.game.enterBuildModeTower,
                child: Container(
                    child: resources.icons.structures.tower,
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colours.brownDark,
                      borderRadius: borderRadius4,
                    ),
                ),
              ),
            ),
          MouseRegion(
            onEnter: (event){
              state.highlightStructureType.value = StructureType.Palisade;
            },
            onExit: (event){
              if (state.highlightStructureType.value != StructureType.Palisade) return;
              state.highlightStructureType.value = null;
            },
            child: onPressed(
              callback: modules.game.enterBuildModePalisade,
              child: Container(
                child: resources.icons.structures.palisade,
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colours.brownDark,
                  borderRadius: borderRadius4,
                ),
              ),
            ),
          ),
            MouseRegion(
              onEnter: (event){
                state.highlightStructureType.value = StructureType.Torch;
              },
              onExit: (event){
                if (state.highlightStructureType.value != StructureType.Torch) return;
                state.highlightStructureType.value = null;
              },
              child: onPressed(
                callback: modules.game.enterBuildModeTorch,
                child: Container(
                  child: resources.icons.structures.torch,
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colours.brownDark,
                    borderRadius: borderRadius4,
                  ),
                ),
              ),
            )

          ],),
      );
  }

  Widget buildPanelStore() {

    final storeTab = WatchBuilder(state.storeTab, (StoreTab activeStoreTab) {

      return border(
        color: colours.white,
        width: 2,
        child: Column(
          key: storeColumnKey,
          children: [
            Container(child: text("PURCHASE"), padding: EdgeInsets.all(8.0),),
            _storeTabs(activeStoreTab),
            if (activeStoreTab == StoreTab.Weapons)
              _storeTabWeapons(),
            if (activeStoreTab == StoreTab.Armor)
              _storeTabArmour(),
            if (activeStoreTab == StoreTab.Items)
              _storeTabItems(),
          ],
        ),
      );

    });

    return panel(
      child: visibleBuilder(state.player.storeVisible, storeTab),
      width: 200,
    );
  }

  Widget _storeTabs(StoreTab activeStoreTab) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: storeTabs.map((storeTab) => button(
              mapStoreTabToIcon(storeTab),
                  () => state.storeTab.value = storeTab,
              borderColor: none,
             hint: storeTab.name,
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


  Widget shopSlotRow(int a, int b, int c){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _storeSlot(a),
        _storeSlot(b),
        _storeSlot(c),
      ],
    );
  }

  Widget buildPanelOrbs(){
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

  Widget buildHighlightSlot({required Slot slot, required Widget child}){
    return MouseRegion(
        onEnter: (event){
          state.highlightSlot.value = slot;
        },
        onExit: (event){
          state.highlightSlot.value = null;
        },
        child: child,
    );
  }

  // Widget buildEquippedWeaponSlot(){
  //   final weapon = state.player.slots.weapon;
  //
  //   return onPressed(
  //       callback: actions.unequipWeapon,
  //       child: buildHighlightSlot(
  //         slot: weapon,
  //         child: Stack(
  //           children: [
  //             WatchBuilder(weapon.type, (int slotType){
  //               final child = slot(slotType: slotType, color: colours.white382);
  //               if (slotType == SlotType.Empty) return child;
  //               return child;
  //             }),
  //             WatchBuilder(weapon.amount, (int amount){
  //               if (amount < 0) return const SizedBox();
  //               return Padding(
  //                 padding: const EdgeInsets.all(1.0),
  //                 child: text(amount, size: style.fontSize.small),
  //               );
  //             })
  //           ],
  //         ),
  //       ));
  //
  // }

  // Widget _panelEquipped(){
  //   final slots = state.player.slots;
  //     return Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             buildEquippedWeaponSlot(),
  //             buildHighlightSlot(
  //               slot: slots.armour,
  //               child: WatchBuilder(slots.armour.type, (int slotType){
  //                 final child = slot(slotType: slotType, color: colours.white382);
  //                 if (slotType == SlotType.Empty) return child;
  //                 return onPressed(
  //                     callback: actions.unequipArmour,
  //                     child: child);
  //               }),
  //             ),
  //             buildHighlightSlot(
  //               slot: slots.helm,
  //               child: WatchBuilder(slots.helm.type, (int slotType){
  //                 final child = slot(slotType: slotType, color: colours.white382);
  //                 if (slotType == SlotType.Empty) return child;
  //                 return onPressed(
  //                     callback: actions.unequipHelm,
  //                     child: child);
  //               }),
  //             ),
  //           ],
  //         )
  //       ],
  //     );
  // }

  Widget buildInventorySlot(Slot slot, int index) {

    final amount = WatchBuilder(slot.amount, (int amount){
      if (amount < 0) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: text(amount, size: style.fontSize.small),
      );
    });


    final type = WatchBuilder(slot.type, (int slotType) {

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


      if (slotType == SlotType.Empty) return child;
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

  Widget _storeSlot(int slotType){

    if (slotType == SlotType.Empty){
      return Container(
          width: slotSize,
          height: slotSize,
          child: getSlotTypeImage(slotType));
    }

    return mouseOver(onEnter: () {
      state.highlightSlotType.value = slotType;
    }, onExit: () {
      if (state.highlightSlotType.value == slotType){
        state.highlightSlotType.value = SlotType.Empty;
      }
    }, builder: (context, isOver) {

      if (isOver){
        // final renderObject = context.findRenderObject();
        // if (renderObject != null){
        //   final translation = renderObject.getTransformTo(null).getTranslation();
        //   state.highlightPanelPosition.x = translation.x;
        //   state.highlightPanelPosition.y = translation.y;
        // }
      }


      return onPressed(
        callback: (){
          actions.purchaseSlotType(slotType);
        },
        child: Container(
            width: slotSize,
            height: slotSize,
            color: isOver && slotType != SlotType.Empty ? colours.black382 : none,
            child: getSlotTypeImage(slotType)),
      );
    });
  }

  Widget slot({required int slotType, required Color color}){
    return Container(
        width: 50,
        height: 50,
        color: color,
        child: getSlotTypeImage(slotType));
  }

  Widget getSlotTypeImage(int value){
    return _slotTypeImages[value] ?? resources.icons.unknown;
  }

  Widget mousePosition() {
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
      return text("Mouse Row:$mouseRow, Column: $mouseColumn");
    });
  }

  Widget buildFramesSinceUpdate(){
    return WatchBuilder(framesSinceUpdateReceived, (int frames){
      return text("Frames Since Update: $frames");
    });
  }

  Widget buildFramesSmoothed(){
    return WatchBuilder(state.framesSmoothed, (int frames){
      return text("Frames Smoothed: $frames");
    });
  }

  Widget buildTotalEvents(){
    return WatchBuilder(totalEvents, (int frames){
      return text("Events: $frames");
    });
  }

  Widget buildMSSinceUpdate(){
    return WatchBuilder(averageUpdate, (double frames){
      return text("Milliseconds Since Last: $frames");
    });
  }

  Widget buildSync(){
    return WatchBuilder(sync, (double frames){
      return text("Sync: $frames");
    });
  }

  Widget buildTotalFrames(){
    return WatchBuilder(totalUpdates, (int frames){
      return text("Frames: $frames");
    });
  }

  Widget get buildTotalParticles {
    return Refresh((){
      return text("Particles: ${isometric.particles.length}");
    });
  }

  Widget get playerScreen {
    return Refresh(() {
      return text("Player Screen: x: ${worldToScreenX(state.player.x)}, y: ${worldToScreenY(state.player.y)}");
    });
  }

  Widget get buildActiveParticles {
    return Refresh((){
      return text("Active Particles: ${isometric.totalActiveParticles}");
    });
  }

  Widget get tileAtMouse {
    return Refresh((){
      return text("Tile: ${isometric.tileAtMouse}");
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

  Widget get mousePositionWorld {
    return Refresh((){
      return text("Mouse World: x: ${mouseWorldX.toInt()}, y: ${mouseWorldY.toInt()}");
    });
  }

  Widget get mousePositionScreen {
    return Refresh((){
      return text("Mouse Screen: x: ${engine.mousePosition.x.toInt()}, y: ${engine.mousePosition.y.toInt()}");
    });
  }

  Widget get cameraZoom {
    return Refresh((){
      return text("Zoom: ${engine.zoom}");
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
    return text(version, color: colours.white618);
  }

  Widget buildTime(){
    return Row(
      children: [
        WatchBuilder(modules.isometric.hours, (int hours){
          return text(padZero(hours));
        }),
        text(":"),
        WatchBuilder(modules.isometric.minutes, (int minutes){
          return text(padZero(minutes));
        }),
      ],
    );
  }

  Widget toggleDebugMode(){
    return WatchBuilder(state.compilePaths, (bool compilePaths){
      return button("Debug Mode: $compilePaths", actions.toggleDebugPaths);
    });
  }

  Widget buildToggleEnabledSound(){
    return WatchBuilder(audio.soundEnabled, (bool enabled){
      return button(text("Sound", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleEnabledSound);
    });
  }

  Widget buildToggleEnabledMusic(){
    return WatchBuilder(audio.musicEnabled, (bool enabled){
      return button(text("Music", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleEnabledMusic);
    });
  }

  Widget buildButtonToggleCameraMode(){
    return WatchBuilder(modules.game.state.cameraMode, (CameraMode mode){
       return button(mode.name, modules.game.actions.nextCameraMode);
    });
  }

  Widget buildButtonSkipTrack(){
    return button("Next", audio.nextSong);
  }

  Widget buildButtonFullScreen(){
    return button("Fullscreen", engine.fullscreenToggle);
  }

  Widget buildScoreBoard(){
    return SingleChildScrollView(
      child: Container(
          constraints: BoxConstraints(maxHeight: 400),
          child: textBuilder(game.scoreText)),
    );
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
          mousePositionWorld,
          mousePositionScreen,
          byteCountWatcher,
          bufferLengthWatcher,
          playerPosition,
          cameraZoom,
          buildFramesSinceUpdate(),
          buildFramesSmoothed(),
          playerScreen,
          buildTotalEvents(),
          buildTotalFrames(),
          buildMSSinceUpdate(),
          buildSync(),
      ],
    );
  }
}


final _slotTypeImages = <int, Widget> {
  SlotType.Empty: resources.icons.empty,
  SlotType.Sword_Short : resources.icons.sword,
  SlotType.Sword_Wooden : resources.icons.swords.wooden,
  SlotType.Golden_Necklace : resources.icons.trinkets.goldenNecklace,
  SlotType.Sword_Long : resources.icons.swords.iron,
  SlotType.Bow_Wooden : resources.icons.bows.wooden,
  SlotType.Bow_Green : resources.icons.bows.green,
  SlotType.Bow_Gold : resources.icons.bows.gold,
  SlotType.Staff_Wooden : resources.icons.staffs.wooden,
  SlotType.Staff_Blue : resources.icons.staffs.blue,
  SlotType.Staff_Golden : resources.icons.staffs.golden,
  SlotType.Spell_Tome_Fireball : resources.icons.books.red,
  SlotType.Spell_Tome_Ice_Ring : resources.icons.books.blue,
  SlotType.Spell_Tome_Split_Arrow : resources.icons.books.blue,
  SlotType.Body_Blue : resources.icons.armour.standard,
  SlotType.Steel_Helmet : resources.icons.heads.steel,
  SlotType.Magic_Hat : resources.icons.heads.magic,
  SlotType.Rogue_Hood : resources.icons.heads.rogue,
  SlotType.Potion_Red : resources.icons.potions.red,
  SlotType.Potion_Blue : resources.icons.potions.blue,
  SlotType.Armour_Padded : resources.icons.armour.padded,
  SlotType.Magic_Robes : resources.icons.armour.magic,
  SlotType.Handgun : resources.icons.firearms.handgun,
  SlotType.Shotgun : resources.icons.firearms.shotgun,
  SlotType.Pickaxe : resources.icons.swords.pickaxe,
};