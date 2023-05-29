
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_status.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/style.dart';


final nameController = TextEditingController();

Widget buildErrorDialog(String message, {Widget? bottomRight}){
  return dialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightVerySmall,
      color: GameIsometricColors.brownDark,
      borderColor: GameIsometricColors.none,
      child: buildLayout(
          child: Center(
            child: text(message, color: GameIsometricColors.white),
          ),
          bottomRight: bottomRight ?? text("okay", onPressed: () => WebsiteState.error.value = null)
      )
  );
}

Widget buildConnectionStatus(ConnectionStatus connectionStatus) {
  switch (connectionStatus) {
    case ConnectionStatus.Connected:
      return GameIsometricUI.buildUI();
    case ConnectionStatus.Connecting:
      return gamestream.games.gameWebsite.buildPageConnectionStatus(connectionStatus.name);
    default:
      return gamestream.games.gameWebsite.buildNotConnected();
  }
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
  return WatchBuilder(gamestream.games.gameWebsite.account, (Account? account) {
    return builder(account);
  });
}

// Widget buildTopMessage(){
//   print("buildTopMessage()");
//   return watchAccount((account) {
//     return WatchBuilder(website.state.dialog, (dialog){
//
//       if (dialog != WebsiteDialog.Games) return empty;
//
//       if (account == null){
//         return onHover((hovering){
//           return margin(
//             top: 10,
//             child: Row(
//               children: [
//                 text("Sign in and subscribe", color: GameIsometricColors.green, underline: hovering, onPressed: website.actions.showDialogLogin),
//                 text(" to unlock all games", color: GameIsometricColors.white618, onPressed: website.actions.showDialogLogin, underline: hovering),
//               ],
//             ),
//           );
//         });
//       }
//
//       if (account.subscriptionActive) {
//         return margin(
//           top: 10,
//           child: text("Premium",
//               color: GameIsometricColors.green,
//               size: 18,
//               onPressed: website.actions.showDialogAccount),
//         );
//       }
//
//       if (account.subscriptionNone) {
//         return button(
//             Row(
//               children: [
//                 text("Subscribe", color: GameIsometricColors.green, bold: true, size: 20),
//                 onPressed(
//                     child: text(" for \$9.99 per month to unlock all games",
//                         color: GameIsometricColors.white80, size: 20),
//                     action: AccountService.openStripeCheckout),
//               ],
//             ),
//             AccountService.openStripeCheckout,
//             fillColorMouseOver: GameIsometricColors.none,
//             borderColor: GameIsometricColors.none,
//             borderColorMouseOver: GameIsometricColors.white80);
//       }
//
//       if (account.subscriptionEnded) {
//         return Row(
//           children: [
//             onPressed(
//               action: AccountService.openStripeCheckout,
//               child: text(
//                   "Your subscription expired on ${GameWebsite.formatDate(account.subscriptionEndDate!)}",
//                   color: GameIsometricColors.red),
//             ),
//             width16,
//             button(text("Renew", color: GameIsometricColors.green), AccountService.openStripeCheckout,
//                 borderColor: GameIsometricColors.green),
//           ],
//         );
//       }
//
//       if (account.subscriptionStatus == SubscriptionStatus.Canceled){
//         final subscriptionEndDate = account.subscriptionEndDate;
//         if (subscriptionEndDate != null){
//           return margin(
//             top: 10,
//               child:                   text("Premium subscription cancelled : ends ${GameWebsite.formatDate(subscriptionEndDate)}", color: GameIsometricColors.white618,
//                   onPressed: website.actions.showDialogAccount
//               ));
//         }
//       }
//
//       return empty;
//     });
//   });
// }

bool isAccountName(String publicName){
  final account = gamestream.games.gameWebsite.account.value;
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
