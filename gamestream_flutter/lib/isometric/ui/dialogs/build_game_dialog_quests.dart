
import 'package:bleed_common/quest.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_watch/watch.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';

final activeQuestTabWatch = Watch(QuestTab.Current, onChanged: (value){
   if (value == QuestTab.Current){
      activeQuests.value = player.questsInProgress.value;
   }else{
      activeQuests.value = player.questsCompleted.value;
   }
});

final activeQuests = Watch<List<Quest>>(player.questsInProgress.value);
final inProgress = watch(player.questsInProgress, buildColumnQuests);

Widget buildGameDialogQuests(){
  return watch(activeQuestTabWatch, (QuestTab activeQuestTabValue){
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    container(child:"Quests"),
                    // container(child:"Inventory"),
                    // container(child:"Map"),
                  ],
                ),
                buildButtonCloseGameDialog(),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   inProgress,
                 ],
                ),
              ),
            )   
          ],
        ),
      ),
    );
  });
}


Widget buildButtonCloseGameDialog() =>
  container(
    child: text("x"),
    alignment: Alignment.center,
    action: actionCloseGameDialog,
  );

void actionCloseGameDialog(){
  player.gameDialog.value = null;
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