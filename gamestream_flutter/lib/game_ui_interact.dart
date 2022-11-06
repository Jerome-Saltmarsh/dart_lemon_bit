
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric/ui/widgets/nothing.dart';


class InteractMode {
   static const None = 0;
   static const Talking = 1;
   static const Trading = 2;
}

class GameUIInteract {
  static const _width = 400;

    static Widget buildUIInteract(){
      return Positioned(top: 0, left: 0, child: Container(
        width: Engine.screen.width,
        height: Engine.screen.height,
        alignment: Alignment.center,
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

  static Widget buildPanelStore(){
    return watch(GamePlayer.storeItems, (List<int> weapons){
      if (weapons.isEmpty) return SizedBox();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              container(child: "PURCHASE"),
              container(child: SizedBox()),
              container(child: "CLOSE", action: GameNetwork.sendClientRequestStoreClose),
            ],
          ),
          // height6,
          // Row(children: EquipmentType.values.map((tab) {
          //   return watch(storeEquipmentType, (active){
          //     return container(
          //       child: text(tab.name),
          //       action: () => storeEquipmentType.value = tab,
          //       color: tab == storeEquipmentType.value ? greyDark : grey,
          //     );
          //   });
          // }).toList()),
          height6,
        ],
      );
    });
  }

}