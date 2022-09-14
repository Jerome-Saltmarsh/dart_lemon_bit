
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/init.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/module.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/widgets.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../isometric/ui/build_hud.dart';
import '../network/classes/websocket.dart';
import '../network/instance/websocket.dart';
import 'build.dart';

final nameController = TextEditingController();

Widget buildWatchErrorMessage(){
  return WatchBuilder(core.state.error, (String? message){
    if (message == null) return empty;
    return buildErrorDialog(message);
  });
}

Widget buildErrorDialog(String message, {Widget? bottomRight}){
  return dialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightVerySmall,
      color: colours.brownDark,
      borderColor: colours.none,
      child: buildLayout(
          child: Center(
            child: text(message, color: colours.white),
          ),
          bottomRight: bottomRight ?? text("okay", onPressed: core.actions.clearError)
      )
  );
}

Widget buildAccount(Account? account) {
  return buildWatchConnection(account);
}

WatchBuilder<Connection> buildWatchConnection(Account? account) {
  return WatchBuilder(webSocket.connection, (Connection connection) {
    switch (connection) {
      case Connection.Connecting:
        return ui.layouts.buildLayoutLoading();
      case Connection.Connected:
        return buildHud();
      case Connection.None:
        return buildPageWebsite();
      default:
        return buildConnection(connection);
    }
  });
}

Widget buildConnection(Connection value) => center(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text(connectionMessage[value], size: FontSize.Normal),
        height32,
        text("Back", onPressed: (){
          core.actions.exitGame();
          webSocket.disconnect();
        }),
      ],
    ));

Widget buildDialogChangeRegion() {
  return dialog(
      height: 500,
      padding: 16,
      borderColor: colours.none,
      color: colours.white05,
      child: buildLayout(
          bottomRight: widgets.buttonClose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...selectableRegions.map((region) {
                return button(enumString(region), () {
                  core.state.region.value = region;
                  modules.website.actions.showDialogGames();
                },
                    fillColor: region == core.state.region.value
                        ? colours.black20
                        : colours.white05,
                    borderColor: colours.none,
                    fillColorMouseOver: colours.green,
                    borderColorMouseOver: colours.green,
                    margin: const EdgeInsets.only(bottom: 8));
              }).toList()
            ],
          )));
}

final Map<Connection, String> connectionMessage = {
  Connection.Done: "Connection to the server was lost",
  Connection.Error: "An error occurred with the connection to the server",
  Connection.Connected: "Connected to server",
  Connection.Connecting: "Connecting to server",
  Connection.Failed_To_Connect: "Unable to establish a connection",
  Connection.None: "There is no connection to the server",
};

Widget? dev(Widget child){
  return isLocalHost ? child : null;
}

Widget margin({
  required Widget child,
  double left = 0,
  double top = 0,
  double right = 0,
  double bottom = 0
}){
  return Container(
    child: child,
    margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom
    )
  );
}


Widget watchAccount(Widget builder(Account? value)) {
  return WatchBuilder(core.state.account, (Account? account) {
    return builder(account);
  });
}

Widget buildTopMessage(){
  print("buildTopMessage()");
  return watchAccount((account) {
    return WatchBuilder(website.state.dialog, (dialog){

      if (dialog != WebsiteDialog.Games) return empty;

      if (account == null){
        return onHover((hovering){
          return margin(
            top: 10,
            child: Row(
              children: [
                text("Sign in and subscribe", color: colours.green, underline: hovering, onPressed: website.actions.showDialogLogin),
                text(" to unlock all games", color: colours.white618, onPressed: website.actions.showDialogLogin, underline: hovering),
              ],
            ),
          );
        });
      }

      if (account.subscriptionActive) {
        return margin(
          top: 10,
          child: text("Premium",
              color: colours.green,
              size: 18,
              onPressed: website.actions.showDialogAccount),
        );
      }

      if (account.subscriptionNone) {
        return button(
            Row(
              children: [
                text("Subscribe", color: colours.green, bold: true, size: 20),
                onPressed(
                    child: text(" for \$9.99 per month to unlock all games",
                        color: colours.white80, size: 20),
                    action: core.actions.openStripeCheckout),
              ],
            ),
            core.actions.openStripeCheckout,
            fillColorMouseOver: none,
            borderColor: none,
            borderColorMouseOver: colours.white80);
      }

      if (account.subscriptionEnded) {
        return Row(
          children: [
            onPressed(
              action: core.actions.openStripeCheckout,
              child: text(
                  "Your subscription expired on ${formatDate(account.subscriptionEndDate!)}",
                  color: colours.red),
            ),
            width16,
            button(text("Renew", color: green), core.actions.openStripeCheckout,
                borderColor: colours.green),
          ],
        );
      }

      if (account.subscriptionStatus == SubscriptionStatus.Canceled){
        final subscriptionEndDate = account.subscriptionEndDate;
        if (subscriptionEndDate != null){
          return margin(
            top: 10,
              child:                   text("Premium subscription cancelled : ends ${formatDate(subscriptionEndDate)}", color: colours.white618,
                  onPressed: website.actions.showDialogAccount
              ));
        }
      }

      return empty;
    });
  });
}

Widget buildDialogGameFinished(){
  return buildDialogMedium(
      child: Center(
          child: text("Game Over")),
          bottomRight: buildButton("Exit", core.actions.exitGame),
  );
}

bool isAccountName(String publicName){
  final account = core.state.account.value;
  if (account == null) return false;
  return account.publicName == publicName;
}

Widget statefulBuilder(Widget Function(Function rebuild) build) {
  return StatefulBuilder(builder: (context, setState){
    Function rebuild = (){
      setState((){});
    };
    return build(rebuild);
  });
}
