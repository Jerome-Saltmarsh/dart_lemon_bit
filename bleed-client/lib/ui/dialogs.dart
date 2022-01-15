import 'package:bleed_client/actions.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/constants.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../flutterkit.dart';


Widget buildDialogAccount(){

  return watchAccount((account){
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

    return buildDialog(
        width: style.dialogMediumWidth,
        height: style.dialogMediumWidth * goldenRatio_1618,
        // bottomLeft: margin(child: _buildSubscriptionStatus(account.subscriptionStatus), bottom: 32),
        bottomRight: margin(child: widgets.closeButton, bottom: 32),
        child:
    Column(
      crossAxisAlignment: axis.cross.start,
      children: [
        height32,
        text("MY ACCOUNT",
            size: 30,
            weight: bold,
            color: colours.white85
        ),
        height32,
        _buildRow("Private Name", account.privateName),
        height8,
        onPressed(
            child: _buildRow(
                "Public Name",
                Row(
                  mainAxisAlignment: axis.main.apart,
                  children: [
                    buildIconEdit(),
                    text(account.publicName,
                        color: colours.white60, size: 16)
                  ],
                )),
            callback: actions.showDialogChangePublicName),
        height8,
        _buildRow("Email", account.email),
        height8,
        _buildRow("Joined", formatDate(account.accountCreationDate)),
        height50,
        _buildSubscriptionPanel(account),
      ],
    )
    );
  });
}

Widget _buildSubscriptionPanel(Account account){

  final subscriptionStarted = account.subscriptionCreationDate;
  final subscriptionEnds = account.subscriptionExpirationDate;

  return border(
      padding: padding16,
      alignment: Alignment.centerLeft,
      fillColor: colours.white05,
      color: none,
      child: Column(
        crossAxisAlignment: axis.cross.start,
        children: [
          Row(
            mainAxisAlignment: axis.main.apart,
            children: [
              text("MY SUBSCRIPTION", bold: true, color: colours.white80),
              if (!account.subscriptionActive)
              widgets.textUpgrade,
              if (account.subscriptionActive)
                text("Cancel", color: colours.white80, onPressed: actions.showDialogConfirmCancelSubscription, italic: true),
            ],
          ),
          height16,
          _buildRow("Status", account.subscriptionNone ? "Not Active" : account.subscriptionActive ? text("ACTIVE", color: green) : text("EXPIRED", color: colours.red)),
          height8,
          _buildRow("Started", subscriptionStarted == null ? "-" : formatDate(subscriptionStarted)),
          height8,
          _buildRow(subscriptionEnds == null ? "Ends" : account.subscriptionExpired ? "Ended" : "Renews", subscriptionEnds == null ?  "-" : formatDate(subscriptionEnds)),
        ],
      )
  );
}

Widget _buildRow(String title, dynamic value){
  return Row(
    mainAxisAlignment: axis.main.apart,
    children: [
      text(title, color: colours.white85),
      Container(
        height: 40,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8),
          width: style.dialogMediumWidth * goldenRatio_0618,
          decoration: BoxDecoration(
            color: colours.black382,
            borderRadius: borderRadius4,
          ),
          child: value is Widget ? value : text(value, color: colours.white60, size: 16)),
    ],
  );
}

Widget buildDialog({
  required Widget child,
  required double width,
  required double height,
  Widget? bottomRight,
  Widget? bottomLeft,
}){
  return dialog(
      color: colours.white05,
      borderColor: none,
      padding: 16,
      width: width,
      height: height,
      child: layout(
          child: child,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight ?? backButton
      )
  );
}

Widget buildDialogMedium({required Widget child, Widget? bottomLeft}){
  return buildDialog(
      width: style.dialogMediumWidth,
      height: style.dialogMediumHeight,
      bottomLeft: bottomLeft,
      child: child
  );
}

Widget buildDialogLarge({required Widget child, Widget? bottomLeft, Widget? bottomRight}){
  return buildDialog(
      width: style.dialogLargeWidth,
      height: style.dialogLargeHeight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      child: child,
  );
}

Widget buildDialogMax({required Widget child, Widget? bottomLeft, Widget? bottomRight}){
  return buildDialog(
    width: style.dialogLargeWidth,
    height: double.infinity,
    bottomLeft: bottomLeft,
    bottomRight: bottomRight,
    child: child,
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
  return text(value.toUpperCase(), size: style.dialogTitleSize, color: colours.white85);
}

Widget buildDialogSubscriptionSuccessful(){
  return watchAccount((account){
    return buildDialogLarge(
        bottomLeft: widgets.buttonChangeDisplayName,
        bottomRight: widgets.closeButton,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: axis.main.apart,
              children: [
                Row(
                  children: [
                    buildDialogTitle("Inbox"),
                    width16,
                    icons.mail,
                  ],
                ),
                border(
                    padding: padding16,
                    color: none,
                    fillColor: colours.black15,
                    child: buildDialogTitle("Subscription Activated")),
              ],
            ),
            height16,
            buildInfo(child: Column(
              crossAxisAlignment: axis.cross.start,
              children: [
                text("Dear ${account != null ? account.privateName : "Anonymous"}", color: colours.white618),
                height32,
                text("Congratulations! Your premium account has officially been activated.", color: colours.white618),
                height16,
                text("This means you have access to all the games in the library plus a ton more", color: colours.white618),
                height16,
                Row(
                  children: [
                    text("such as ", color: colours.white618),
                    text("Change your in game name", color: colours.green, onPressed: actions.showDialogChangePublicName),
                  ],
                ),
                height32,
                text("You can cancel your subscription any time via the account dialog", color: colours.white618),
                height32,
                text("Kind regards,", color: colours.white618),
                height16,
                text("From Jerome (founder and ceo)", color: colours.white618),
              ],
            ))
          ],
        )
    );
  });
}

Widget buildDialogWelcome(){

  return watchAccount((account){
    return buildDialogLarge(
        bottomLeft: widgets.subscribeButton,
        bottomRight: widgets.closeButton,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: axis.main.apart,
              children: [
                Row(
                  children: [
                    buildDialogTitle("Inbox"),
                    width16,
                    icons.mail,
                  ],
                ),
                border(
                    padding: padding16,
                    color: none,
                    fillColor: colours.black15,
                    child: buildDialogTitle("welcome to gamestream")),
              ],
            ),
            height16,
            buildInfo(child: Column(
              crossAxisAlignment: axis.cross.start,
              children: [
                if (account != null)
                  text("Dear ${account.privateName}", color: colours.white618),
                  height32,
                  text("Thank you for joining gamestream :)", color: colours.white618),
                height16,
                Row(
                  children: [
                    text("Simply ", color: colours.white618),
                    onHover((hov){
                      return text("purchase an active subscription", color: colours.green, bold: true, onPressed: actions.openStripeCheckout, underline: hov);
                    }),
                    text(" for \$9.99 per month", color: colours.white618),
                  ],
                ),
                height16,
                text("to unlock all the games within our library.", color: colours.white618),
                height24,
                text("Boundless adventure awaits!", color: colours.white618),
                height32,
                text("Kind regards,", color: colours.white618),
                height16,
                text("From Jerome (founder and ceo)", color: colours.white618),
              ],
            ))
          ],
        )
    );

  });

}

final _nameController = TextEditingController();

Widget buildDialogChangePublicName() {
  return NullableWatchBuilder<Account?>(game.account, (Account? account) {
    if (account == null) {
      return buildDialogMessage("Account required to change public name");
    }

    if (!account.subscriptionActive) {
      return buildDialogMedium(
          bottomLeft: widgets.subscribeButton,
          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              buildDialogTitle("OOPS!"),
              height32,
              border(
                fillColor: colours.white05,
                color: none,
                padding: padding16,
                child: Column(
                  crossAxisAlignment: axis.cross.start,
                  children: [
                    Row(
                      children: [
                        text("An ", color: colours.white618),
                        text("active subscription", color: colours.green, bold: true, onPressed: actions.openStripeCheckout),
                        text(" is needed to change", color: colours.white618),
                      ],
                    ),
                    text("your public name", color: colours.white618),
                  ],
                ),
              ),
            ],
          ));
    }

    return dialog(
      child: layout(
        child: TextField(
          controller: _nameController,
        ),
        bottomLeft: button("Save", () {}),
        bottomRight: button("Cancel", setDialogGames, borderColor: none),
      ),
    );
  });
}

Widget buildDialogMessage(String message) {
  return buildDialogMedium(child: text(message));
}

Widget buildDialogConfirmCancelSubscription(){
  return buildDialogMedium(child: text("Are you sure you want to cancel your subscription?"),
    bottomLeft: button(text("CONFIRM", color: colours.red), actions.cancelSubscription, fillColor: none, borderColor: colours.red)
  );
}


