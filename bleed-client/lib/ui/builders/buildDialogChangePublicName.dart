import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/buildDialog.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../actions.dart';
import '../../flutterkit.dart';
import '../../styles.dart';
import '../widgets.dart';

final nameController = TextEditingController();

Widget buildDialogChangePublicName() {
  return NullableWatchBuilder<Account?>(game.account, (Account? account) {
    if (account == null) {
      return buildDialogMessage("Account required to change public name");
    }

    if (!account.subscriptionActive) {
      return buildDialogMedium(
          bottomLeft: widgets.subscriptionButton,
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
          controller: nameController,
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
