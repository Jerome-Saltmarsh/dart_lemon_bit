
import 'package:bleed_client/actions.dart';
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:lemon_dispatch/instance.dart';

class CoreActions {

  void operationCompleted(){
    core.state.operationStatus.value = OperationStatus.None;
  }

  void cancelSubscription() async {
    print("actions.cancelSubscription()");
    actions.showDialogAccount();
    final account = core.state.account.value;
    if (account == null) {
      actions.showErrorMessage('Account is null');
      return;
    }
    core.state.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await firestoreService.cancelSubscription(account.userId);
    await updateAccount();
    core.state.operationStatus.value = OperationStatus.None;
  }

  Future updateAccount() async {
    print("refreshAccountDetails()");
    final account = core.state.account.value;
    if (account == null){
      return;
    }

    core.state.operationStatus.value = OperationStatus.Updating_Account;
    core.state.account.value = await firestoreService.findUserById(account.userId).catchError((error){
      pub(LoginException(error));
      return null;
    });
    core.state.operationStatus.value = OperationStatus.None;
  }

  void logout() {
    print("actions.logout()");
    core.state.operationStatus.value = OperationStatus.Logging_Out;

    firebaseAuth.signOut().catchError(print);
    googleSignIn.signOut().catchError((error){
      print(error);
    });

    storage.forgetAuthorization();
    core.state.account.value = null;
    Future.delayed(Duration(seconds: 1), (){
      core.state.operationStatus.value = OperationStatus.None;
    });
  }

}