import 'package:bleed_client/actions.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/constants.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../flutterkit.dart';


Widget buildDialogAccount(){
  return NullableWatchBuilder<Account?>(game.account, (Account? account){
    if (account == null) {
      return layout(
        bottomLeft: buttons.login,
        bottomRight: button("Close", actions.showDialogGames),
        child: dialog(
            child: Column(
              crossAxisAlignment: axis.cross.start,
              children: [
                border(child: text("ACCOUNT")),
                height16,
                text("Authentication Required"),
              ],
            )
        ),
      );
    }

    return dialog(
      color: white05,
      borderColor: none,
      padding: 16,
      height: style.dialogMediumHeight,
      width: style.dialogMediumWidth,
      child: layout(
          bottomLeft: _buildSubscriptionStatus(account.subscriptionStatus),
          bottomRight: account.subscriptionNone
              ? button(text("back", color: colours.white80), actions.showDialogGames, fillColor: none, borderColor: none)
              : button(text('back', weight: bold), actions.showDialogGames, fillColor: none,
          ),
          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              text("MY ACCOUNT",
                  size: 30,
                  weight: bold,
                  color: colours.white85
              ),
              height32,
              _buildRow("Private Name", account.privateName),
              height8,
              onPressed(child: _buildRow("Public Name", account.publicName), callback: actions.showDialogChangePublicName),
              height8,
              _buildRow("Email", account.email),
              height8,
              _buildRow("Joined", formatDate(account.accountCreationDate)),
              height8,
              if (!account.subscriptionNone)
                border(
                  child: Column(
                    crossAxisAlignment: axis.cross.start,
                    children: [
                      if (account.subscriptionActive) text("Subscription Active", color: colours.green),
                      height16,
                      if (account.subscriptionActive) text("Automatically Renews"),
                      if (account.subscriptionExpired)
                        Row(
                          children: [
                            text("Expired", color: colours.red),
                            width8,
                            button("Renew", () {},
                                fillColor: colours.green)
                          ],
                        ),
                      if (account.subscriptionActive)
                        text(dateFormat.format(account.subscriptionExpirationDate!), color: colours.white60),
                    ],
                  ),
                ),
            ],
          )),
    );
  });
}


Widget _buildSubscriptionStatus(SubscriptionStatus status){
  switch(status){
    case SubscriptionStatus.None:
      return button(Row(
        children: [
          icons.creditCard,
          width4,
          text("SUBSCRIBE", bold: true),
          width4,
        ],
      ),  actions.openStripeCheckout, fillColor: colours.green, borderColor: colours.none,
          fillColorMouseOver: colours.green
      );
    case SubscriptionStatus.Active:
      return button("Cancel Subscription", actions.cancelSubscription,
        fillColor: colours.red,
        borderColor: colours.none,
      );
    case SubscriptionStatus.Expired:
      return text("Renew Subscription");
  }
}

Widget _buildRow(String title, String value){
  return Row(
    mainAxisAlignment: axis.main.apart,
    children: [
      text(title, color: colours.white85),
      Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8),
          width: style.dialogMediumWidth * goldenRatio_0618,
          decoration: BoxDecoration(
            color: colours.black382,
            borderRadius: borderRadius4,
          ),
          child: text(value, color: colours.white60, size: 16)),
    ],
  );
}

Widget buildDialog({
  required Widget child,
  required double width,
  required double height
}){
  return dialog(
      color: colours.white05,
      borderColor: none,
      padding: 16,
      width: width,
      height: height,
      child: layout(
          child: child,
          bottomRight: backButton
      )
  );
}

Widget buildDialogMedium({required Widget child, Widget? bottomLeft}){
  return buildDialog(
      width: style.dialogMediumWidth,
      height: style.dialogMediumHeight,
      child: layout(
          child: child,
          bottomLeft: bottomLeft,
          bottomRight: backButton
      )
  );
}

Widget buildDialogSmall({required Widget child, Widget? bottomLeft}){
  return buildDialog(
      width: style.dialogSmallWidth,
      height: style.dialogSmallHeight,
      child: layout(
          child: child,
          bottomLeft: bottomLeft,
          bottomRight: backButton
      )
  );
}

Widget buildDialogTitle(String value){
  return text(value, size: style.dialogTitleSize, color: colours.white85);
}