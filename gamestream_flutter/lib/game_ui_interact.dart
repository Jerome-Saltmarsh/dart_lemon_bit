
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'gamestream/games/isometric/game_isometric_colors.dart';


class GameUIInteract {
  static const _width = 400;


    static Widget buildWatchInteractMode() =>
      watch(gamestream.games.isometric.serverState.interactMode, (int interactMode){
        switch (interactMode) {
          case InteractMode.None:
            return GameStyle.Null;
          case InteractMode.Talking:
            return buildInteractModeTalking();
          case InteractMode.Trading:
            return buildInteractModeTrading();
          case InteractMode.Inventory:
            return buildInteractModeInventory();
          case InteractMode.Craft:
            return buildInteractModeCrafting();
          default:
            return GameStyle.Null;
        }
      });

    static Widget buildInteractModeCrafting() => Stack(
        children: [
          Positioned(
            left: 0,
            top: 100,
            child: buildContainerCraft(),
          ),
          buildInteractModeInventory(),
        ],
      );

    static Widget buildContainerCraft() => GameUI.buildDialog(
        dialogType: DialogType.Craft,
        child: Container(
           color: GameIsometricColors.brownDark,
          child: text("Craft"),
        ),
      );

    static Widget buildInteractModeTrading(){
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 100,
            child: watch(gamestream.games.isometric.player.storeItems, buildContainerStoreItems),
          ),
          buildInteractModeInventory(),
        ],
      );
    }

    static Widget buildContainerStoreItems(List<int> itemTypes) =>
      GameUI.buildDialog(
        dialogType: DialogType.Trade,
        child: DragTarget<int>(
          onWillAccept: (int? data){
            return data != null;
          },
          onAccept: (int? data){
            if (data == null) return;
            gamestream.network.sendClientRequestInventorySell(data);
          },
          builder: (context, data, rejected){
            return Container(
              width: GameInventoryUI.Inventory_Width,
              height: 400,
              color: GameIsometricColors.brownDark,
              child: Stack(
                children: [
                  buildStackSlotGrid(itemTypes.length + 12),
                  ...buildPositionedTrading(itemTypes),
                ],
              ),
            );
          },
        ),
      );

    static Widget buildStackSlotGrid(int count){
      final children = <Widget>[];
      for (var i = 0; i < count; i++) {
        children.add(
            GameInventoryUI.buildPositionGridElement(
                index: i,
                child: GameInventoryUI.atlasIconSlotEmpty,
            ),
        );
      }
      return Stack(
        children: children,
      );
    }

    static Widget buildInteractModeInventory(){
      return Positioned(
        bottom: 150,
        right: 5,
        child: GameInventoryUI.buildInventoryUI(),
      );
    }

    static Widget buildInteractModeTalking() =>
      Positioned(top: 55, left: 5, child: GameUI.buildDialog(
        dialogType: DialogType.Talk,
        child: Container(
          color: GameIsometricColors.brownDark,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              watch(gamestream.games.isometric.player.npcTalk, buildControlNpcTalk),
              watch(gamestream.games.isometric.player.npcTalkOptions, buildControlNpcTopics)
            ],
          ),
        ),
      ));

    static Widget buildControlNpcTalk(String value) =>
        container(
          child: SingleChildScrollView(child: text(value = value.replaceAll(". ", "\n\n"), color: white80, height: 2.2)),
          color: brownLight,
          width: _width,
          height: _width * Engine.GoldenRatio_0_618,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(16),
        );

    static Widget buildControlNpcTopics(List<String> topics) =>
        Column(
          children: topics.map((String value) {
            return container(
                margin: const EdgeInsets.only(top: 6),
                child: text(value, color: white80, align: TextAlign.center),
                color: value.endsWith("(QUEST)") ? green : brownLight,
                hoverColor: brownDark,
                width: _width,
                alignment: Alignment.center,
                action: () {
                  gamestream.network.sendClientRequestNpcSelectTopic(topics.indexOf(value));
                }
            );
          }).toList(),
        );

  static List<Widget> buildPositionedTrading(List<int> itemTypes){
      final children = <Widget>[];
      for (var i = 0; i < itemTypes.length; i++){
          children.add(
             GameInventoryUI.buildPositionGridElement(
                 index: i,
                 child: Draggable<int>(
                   onDragCompleted: (){

                   },
                   onDragEnd: (details){

                   },
                   feedback: GameUI.buildAtlasItemType(itemTypes[i]),
                   onDraggableCanceled: (Velocity velocity, Offset offset){
                     if (gamestream.games.isometric.clientState.hoverDialogIsInventory) return;
                     gamestream.network.sendClientRequestInventoryBuy(i);
                   },
                   child: onPressed(
                         child: GameInventoryUI.buildPressableItemIndex(itemIndex: i, itemType: itemTypes[i]),
                         action: () => gamestream.network.sendClientRequestInventoryBuy(i),
                         onRightClick: () => gamestream.network.sendClientRequestInventoryBuy(i),
                     ),
                   ),
                 ),
             );
      }
      return children;
  }
}