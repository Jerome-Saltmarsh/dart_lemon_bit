
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';


class GameUIInteract {
  static const _width = 400;

    static Widget buildWatchInteractMode() =>
      watch(GamePlayer.interactMode, buildInteractMode);

    static Widget buildInteractMode(int mode) {
      switch (mode) {
        case InteractMode.None:
          return const SizedBox();
        case InteractMode.Talking:
          return buildPositionedTalk();
        case InteractMode.Trading:
          return watch(GamePlayer.storeItems, buildStoreItems);
        case InteractMode.Inventory:
          return buildPositionedInventory();
        default:
          return const SizedBox();
      }
    }

    static Widget buildStoreItems(List<int> itemTypes){
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 100,
            child: buildContainerTrade(itemTypes),
          ),
          buildPositionedInventory(),
        ],
      );
    }

    static Widget buildContainerTrade(List<int> itemTypes) =>
      GameUI.buildDialog(
        dialogType: DialogType.Trade,
        child: DragTarget<int>(
          onWillAccept: (int? data){
            return true;
          },
          onAccept: (int? data){
            if (data == null) return;
            GameNetwork.sendClientRequestInventorySell(data);
          },
          builder: (context, data, rejected){
            return Container(
              width: GameInventoryUI.Inventory_Width,
              height: 400,
              color: GameColors.brownDark,
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
                child: GameInventoryUI.buildAtlasIconSlotEmpty(),
            ),
        );
      }
      return Stack(
        children: children,
      );
    }

    static Widget buildPositionedInventory(){
      return Positioned(
        top: 55,
        right: 5,
        child: GameInventoryUI.buildInventoryUI(),
      );
    }

    static Widget buildPositionedTalk() =>
      Positioned(top: 55, left: 5, child: GameUI.buildDialog(
        dialogType: DialogType.Talk,
        child: Container(
          color: GameColors.brownDark,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              watch(GameState.player.npcTalk, buildControlNpcTalk),
              watch(GameState.player.npcTalkOptions, buildControlNpcTopics)
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
                  GameNetwork.sendClientRequestNpcSelectTopic(topics.indexOf(value));
                }
            );
          }).toList(),
        );

  static List<Widget> buildPositionedTrading(List<int> itemTypes){
      final children = <Widget>[];
      for (var i = 0; i < itemTypes.length; i++){
          children.add(
             GameInventoryUI.buildPositionGridItem(
                 index: i,
                 child: Draggable<int>(
                   feedback: GameInventoryUI.buildItemTypeAtlasImage(itemType: itemTypes[i]),
                   onDraggableCanceled: (Velocity velocity, Offset offset){
                     if (GameUI.mouseOverDialogInventory) return;
                     GameNetwork.sendClientRequestInventoryBuy(i);
                   },
                   child: onPressed(
                       child: GameInventoryUI.buildItemTypeAtlasImage(itemType: itemTypes[i]),
                       action: () => GameNetwork.sendClientRequestInventoryBuy(i),
                       onRightClick: () => GameNetwork.sendClientRequestInventoryBuy(i),
                   ),
                 ),
             )
          );
      }
      return children;
  }
}