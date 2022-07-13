
import 'package:bleed_common/quest.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:lemon_watch/watch.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';

final activeQuestTab = Watch(QuestTab.In_Progress);

Widget buildGameDialogQuests(){
   return Column(
     children: [
       text("Quests"),
       Row(
         children: QuestTab.values.map((questTab) =>
             container(child: questTab.name, action: ()=> activeQuestTab.value = questTab, color: brownLight, hoverColor: brownDark)
         ).toList(),
       ),
       watch(activeQuestTab, (QuestTab activeQuestTab) {
          switch (activeQuestTab){
            case QuestTab.Completed:
              return watch(player.questsCompleted, (List<Quest> completed){
                return Column(
                  children: completed.map(text).toList(),
                );
              });
            case QuestTab.In_Progress:
              return watch(player.questsInProgress, (List<Quest> completed){
                return Column(
                  children: completed.map(text).toList(),
                );
              });
          }
       })
     ],
   );
}

enum QuestTab {
   Completed,
   In_Progress,
}