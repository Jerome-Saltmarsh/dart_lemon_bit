
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric/ui/widgets/nothing.dart';


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
          return Stack(
            children: [
              buildPositionedTrading(),
              buildPositionedInventory(),
            ],
          );
        case InteractMode.Inventory:
          return buildPositionedInventory();
        default:
          return const SizedBox();
      }
    }

    static Widget buildPositionedInventory(){
      return Positioned(
        top: 55,
        right: 5,
        child: GameInventoryUI.buildInventoryUI(),
      );
    }

    static Widget buildPositionedTalk(){
      return Positioned(top: 55, left: 5, child: Container(
        color: brownDark,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            watch(GameState.player.npcTalk, buildControlNpcTalk),
            watch(GameState.player.npcTalkOptions, buildControlNpcTopics)
          ],
        ),
      ));
    }

    static Widget buildControlNpcTalk(String? value) =>
        (value == null || value.isEmpty)
            ? nothing
            : container(
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

  static Widget buildPositionedTrading(){
    return Positioned(
      top: 55,
      left: 5,
      child: watch(GamePlayer.storeItems, (List<int> itemTypes) {
        if (itemTypes.isEmpty) return text("No items to trade");
        return Container(
          color: brownDark,
          child: Column(
            children: itemTypes.map(text).toList(),
          ),
        );
      }),
    );
  }

}