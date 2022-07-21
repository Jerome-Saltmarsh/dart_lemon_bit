
import 'package:bleed_common/quest.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/screen.dart';

import 'game_dialog_tab.dart';


Widget buildGameDialogPowers() {
  return Container(
    width: screen.width,
    height: screen.height,
    alignment: Alignment.center,
    child: Container(
      color: brownLight,
      width: screen.width * goldenRatio_0618,
      height: screen.height * goldenRatio_0618,
      child: Column(
        children: [
          gameDialogTab,
          text("Powers"),
         ],
      ),
    ),
  );
}

Widget buildColumnQuests(List<Quest> quests) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: quests.isEmpty ? [text("No active quests")] : quests.map(buildQuest).toList(),
    );

Widget buildQuest(Quest quest) =>
    Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(questName[quest], bold: true),
          height8,
          Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: text(questDescription[quest])),
        ],
      ),
    );

enum QuestTab {
  Current,
  Done,
}