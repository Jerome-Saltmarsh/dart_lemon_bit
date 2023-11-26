
import 'state.dart';

class CoreProperties {

  final CoreState state;

  CoreProperties(this.state);

  bool get premiumAccountAuthenticated {
    final account = state.account.value;
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