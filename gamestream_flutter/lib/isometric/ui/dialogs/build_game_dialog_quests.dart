
import 'package:bleed_common/quest.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'game_dialog_tab.dart';

final activeQuests = Watch<List<Quest>>(GameState.player.questsInProgress.value);
final inProgress = watch(GameState.player.questsInProgress, buildColumnQuests);

Widget buildGameDialogQuests() =>
  Container(
    width: Engine.screen.width,
    height: Engine.screen.height,
    alignment: Alignment.center,
    child: Container(
      color: brownLight,
      width: Engine.screen.width * goldenRatio_0618,
      height: Engine.screen.height * goldenRatio_0618,
      child: Column(
        children: [
          watch(GameState.player.gameDialog, buildGameDialog),
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

Widget buildButtonCloseGameDialog() =>
  container(
    toolTip: "(Press T)",
    child: text("x"),
    alignment: Alignment.center,
    action: actionCloseGameDialog,
  );

void actionCloseGameDialog(){
  GameState.player.gameDialog.value = null;
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