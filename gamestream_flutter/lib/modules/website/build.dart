
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_website.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/instances/engine.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/ui/widgets.dart';


class WebsiteBuild {

  Widget buttonRegion(){
    return Tooltip(
      message: "Change Region",
      child: button(
        text(engine.enumString(GameWebsite.region.value),
            color: GameIsometricColors.white80),
            website.actions.showDialogChangeRegion,
        borderColor: GameIsometricColors.none,
        fillColor: GameIsometricColors.black20,
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
                  children: games.map((mapName) => margin(
                    bottom: 16,
                    child: button(text(mapName, color: GameIsometricColors.white618), (){
                      // connect to custom game
                      website.actions.connectToCustomGame(mapName);
                    },
                        alignment: Alignment.centerLeft,
                        fillColor: GameIsometricColors.white05, fillColorMouseOver: GameIsometricColors.white10, borderColor: GameIsometricColors.none, borderColorMouseOver: GameIsometricColors.none),
                  )).toList(),
                ),
              ],
            ),
          )
      );
    },);
  }
}