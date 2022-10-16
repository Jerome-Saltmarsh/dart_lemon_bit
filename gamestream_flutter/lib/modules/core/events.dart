

import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/classes/websocket.dart';
import 'package:gamestream_flutter/network/instance/websocket.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';

import 'exceptions.dart';

class CoreEvents {


  CoreEvents(){
    Website.region.onChanged(_onServerTypeChanged);
    Website.account.onChanged(_onAccountChanged);
    // webSocket.connection.onChanged(onConnectionChanged);
    sub(_onLoginException);
  }


  Future _onLoginException(LoginException error) async {
    print("onLoginException()");

    Future.delayed(Duration(seconds: 1), (){
      // game.dialog.value = Dialogs.Login_Error;
      Website.error.value = error.cause.toString();
    });
  }

  void _onAccountChanged(Account? account) {
    print("events.onAccountChanged($account)");
    if (account == null) return;
    final flag = 'subscription_status_${account.userId}';
    if (storage.contains(flag)){
      final storedSubscriptionStatusString = storage.get<String>(flag);
      final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
      if (storedSubscriptionStatus != account.subscriptionStatus){
        website.actions.showDialogSubscriptionStatusChanged();
      }
    }
    core.actions.store(flag, enumString(account.subscriptionStatus));
    website.actions.showDialogGames();
  }

  void _onServerTypeChanged(Region serverType) {
    storage.saveServerType(serverType);
  }
}

void onChangedRegion(Region region){
  print("onChangedRegion(${region.name})");
  setDialogVisibleCustomRegion(region == Region.Custom);
}

void setDialogVisibleCustomRegion(bool value){
  isVisibleDialogCustomRegion.value = value;
}

void setRegion(Region value){
  Website.region.value = value;
}
