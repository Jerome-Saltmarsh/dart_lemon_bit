
import 'package:bleed_client/exceptions.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';

final _Getters getters = _Getters();

class _Getters {
  bool get authenticated => game.account.isNotNull;

  bool get premiumAccountAuthenticated {
    final account = game.account.value;
    if (account == null){
      return false;
    }
    final subscriptionEndDate = account.subscriptionEndDate;
    if (subscriptionEndDate == null) {
      return false;
    }
    return subscriptionEndDate.isAfter(DateTime.now());
  }
}