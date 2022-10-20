
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_colors.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/ui/widgets.dart';
import 'package:gamestream_flutter/game_website.dart';


class WebsiteBuild {

  Widget buttonRegion(){
    return Tooltip(
      message: "Change Region",
      child: button(
        text(enumString(GameWebsite.region.value),
            color: GameColors.white80),
            website.actions.showDialogChangeRegion,
        borderColor: GameColors.none,
        fillColor: GameColors.black20,
      ),
    );
  }

  Widget buttonCustomMap(){
    return buildMenuButton("Custom", website.actions.showDialogCustomMaps);
  }

  Widget dialogCustomMaps() {
    print("website.builders.dialogCustomMaps()");

    return FutureBuilder(future: firestoreService.getMapNames(), builder: (context, snapshot){

      if (snapshot.hasError){
        buildErrorDialog(snapshot.error.toString());
      }

      if (snapshot.connectionState == ConnectionState.waiting){
        return buildDialogMessage("Loading Games");
      }

      final games = snapshot.data;

      if (games == null){
        return buildDialogMessage("No games found");
      }

      final mapNames = games as List<String>;

      return buildDialog(
          width: style.dialogWidthMedium,
          height: style.dialogHeightLarge,
          bottomRight: closeDialogButton,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buttonRegion(),
                height16,
                Column(
                  children: mapNames.map((mapName) => margin(
                    bottom: 16,
                    child: button(text(mapName, color: GameColors.white618), (){
                      // connect to custom game
                      website.actions.connectToCustomGame(mapName);
                    },
                        alignment: Alignment.centerLeft,
                        fillColor: GameColors.white05, fillColorMouseOver: GameColors.white10, borderColor: GameColors.none, borderColorMouseOver: GameColors.none),
                  )).toList(),
                ),
              ],
            ),
          )
      );
    },);
  }
}