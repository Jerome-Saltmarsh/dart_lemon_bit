
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';


class WebsiteBuild {

  Widget buttonRegion(){
    return Tooltip(
      message: "Change Region",
      child: button(
        text(enumString(core.state.region.value),
            color: colours.white80),
            website.actions.showDialogChangeRegion,
        borderColor: colours.none,
        fillColor: colours.black20,
      ),
    );
  }

  Widget mainMenu() {
    return watchAccount((Account? account){
      if (account == null) {
        return Column(
          crossAxisAlignment: axis.cross.end,
          children: [
            buttons.signInWithGoogleButton,
            height8,
            buttons.signInWithFacebookButton,
          ],
        );
      }

      return Row(
        crossAxisAlignment: axis.cross.start,
        mainAxisAlignment: axis.main.end,
        children: [
          mouseOver(builder: (BuildContext context, bool mouseOver) {
            return mouseOver ? Column(
              children: [
                buttons.buildAccount(mouseOver),
                buttons.buttonAccount,
                buttons.buttonGames,
                buttonEditor(),
                buttonCustomMap(),
                buttons.buttonLogout,
              ],
            ) : buttons.account;
          }),
        ],
      );
    });
  }

  Widget buttonCustomMap(){
    return buildMenuButton("Custom", website.actions.showDialogCustomMaps);
  }

  Widget buttonEditor(){
    return buildMenuButton("Map Editor", core.actions.openMapEditor);
  }


  Widget dialogCustomMaps() {
    print("website.build.dialogCustomMaps()");

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
                    child: button(text(mapName, color: colours.white618), (){
                      // connect to custom game
                      website.actions.connectToCustomGame(mapName);
                    },
                        alignment: Alignment.centerLeft,
                        fillColor: colours.white05, fillColorMouseOver: colours.white10, borderColor: none, borderColorMouseOver: none),
                  )).toList(),
                ),
              ],
            ),
          )
      );
    },);
  }
}