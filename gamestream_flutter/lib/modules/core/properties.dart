
import 'package:gamestream_flutter/website/website.dart';

class CoreProperties {

  bool get premiumAccountAuthenticated {
    final account = Website.account.value;
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