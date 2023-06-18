
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';


Widget buildColumnQuests(List<Quest> quests) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: quests.isEmpty ? [buildText("No active quests")] : quests.map(buildQuest).toList(),
    );

Widget buildQuest(Quest quest) =>
    Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildText(questName[quest], bold: true),
          height8,
          Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: buildText(questDescription[quest])),
        ],
      ),
    );

enum QuestTab {
  Current,
  Done,
}