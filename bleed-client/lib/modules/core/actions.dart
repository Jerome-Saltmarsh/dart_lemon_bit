
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

  void showErrorMessage(String message){
    core.state.errorMessage.value = message;
  }

  void changeAccountPublicName(String value) async {
    print("actions.changePublicName('$value')");
    final account = core.state.account.value;
    if (account == null) {
      showErrorMessage("Account is null");
      return;
    }
    value = value.trim();

    if (value == account.publicName){
      return;
    }

    if (value.isEmpty) {
      showErrorMessage("Name entered is empty");
      return;
    }
    core.state.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      showErrorMessage(error.toString());
      throw error;
    });
    core.state.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        core.actions.updateAccount();
        website.actions.showDialogAccount();
        showErrorMessage("Name Changed successfully");
        break;
      case ChangeNameStatus.Taken:
        showErrorMessage("'$value' already taken");
        break;
      case ChangeNameStatus.Too_Short:
        showErrorMessage("Too short");
        break;
      case ChangeNameStatus.Too_Long:
        showErrorMessage("Too long");
        break;
      case ChangeNameStatus.Other:
        showErrorMessage("Something went wrong");
        break;
    }
  }

  void cancelSubscription() async {
    print("actions.cancelSubscription()");
    website.actions.showDialogAccount();
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