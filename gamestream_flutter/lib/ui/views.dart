
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_account.dart';
import 'package:gamestream_flutter/game_colors.dart';
import 'package:gamestream_flutter/game_network.dart';
import 'package:gamestream_flutter/game_ui.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../network/classes/websocket.dart';

final nameController = TextEditingController();

Widget buildWatchErrorMessage(){
  return WatchBuilder(Website.error, (String? message){
    if (message == null) return empty;
    return buildErrorDialog(message);
  });
}

Widget buildErrorDialog(String message, {Widget? bottomRight}){
  return dialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightVerySmall,
      color: GameColors.brownDark,
      borderColor: GameColors.none,
      child: buildLayout(
          child: Center(
            child: text(message, color: GameColors.white),
          ),
          bottomRight: bottomRight ?? text("okay", onPressed: () => Website.error.value = null)
      )
  );
}

Widget buildAccount(Account? account) =>
  watch(GameNetwork.webSocket.connection, buildConnection);

Widget buildConnection(Connection connection) {
  switch (connection) {
    case Connection.Connected:
      return GameUI.build();
    case Connection.Connecting:
      return Website.buildPageConnectionStatus(connection.name);
    default:
      return Website.build();
  }
}

const connectionMessage = {
  Connection.Done: "Connection to the server was lost",
  Connection.Error: "An error occurred with the connection to the server",
  Connection.Connected: "Connected to server",
  Connection.Connecting: "Connecting to server",
  Connection.Failed_To_Connect: "Unable to establish a connection",
  Connection.None: "There is no connection to the server",
  Connection.Invalid_Connection: "Invalid websocket connection string",
};

Widget? dev(Widget child){
  return Engine.isLocalHost ? child : null;
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
  return WatchBuilder(Website.account, (Account? account) {
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
                text("Sign in and subscribe", color: GameColors.green, underline: hovering, onPressed: website.actions.showDialogLogin),
                text(" to unlock all games", color: GameColors.white618, onPressed: website.actions.showDialogLogin, underline: hovering),
              ],
            ),
          );
        });
      }

      if (account.subscriptionActive) {
        return margin(
          top: 10,
          child: text("Premium",
              color: GameColors.green,
              size: 18,
              onPressed: website.actions.showDialogAccount),
        );
      }

      if (account.subscriptionNone) {
        return button(
            Row(
              children: [
                text("Subscribe", color: GameColors.green, bold: true, size: 20),
                onPressed(
                    child: text(" for \$9.99 per month to unlock all games",
                        color: GameColors.white80, size: 20),
                    action: AccountService.openStripeCheckout),
              ],
            ),
            AccountService.openStripeCheckout,
            fillColorMouseOver: GameColors.none,
            borderColor: GameColors.none,
            borderColorMouseOver: GameColors.white80);
      }

      if (account.subscriptionEnded) {
        return Row(
          children: [
            onPressed(
              action: AccountService.openStripeCheckout,
              child: text(
                  "Your subscription expired on ${formatDate(account.subscriptionEndDate!)}",
                  color: GameColors.red),
            ),
            width16,
            button(text("Renew", color: GameColors.green), AccountService.openStripeCheckout,
                borderColor: GameColors.green),
          ],
        );
      }

      if (account.subscriptionStatus == SubscriptionStatus.Canceled){
        final subscriptionEndDate = account.subscriptionEndDate;
        if (subscriptionEndDate != null){
          return margin(
            top: 10,
              child:                   text("Premium subscription cancelled : ends ${formatDate(subscriptionEndDate)}", color: GameColors.white618,
                  onPressed: website.actions.showDialogAccount
              ));
        }
      }

      return empty;
    });
  });
}

bool isAccountName(String publicName){
  final account = Website.account.value;
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
