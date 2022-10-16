

import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:gamestream_flutter/website/website.dart';

class CoreEvents {
  CoreEvents(){
    Website.region.onChanged(_onServerTypeChanged);
    Website.account.onChanged(_onAccountChanged);
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
