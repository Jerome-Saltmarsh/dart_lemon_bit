
import 'modules/modules.dart';


final _Getters getters = _Getters();

class _Getters {
  bool get authenticated => core.state.account.isNotNull;

  bool get premiumAccountAuthenticated {
    final account = core.state.account.value;
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