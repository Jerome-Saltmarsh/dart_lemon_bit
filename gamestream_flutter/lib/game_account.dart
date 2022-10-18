import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/data/data_authentication.dart';
import 'package:gamestream_flutter/enums/operation_status.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/actions/sign_in_with_facebook.dart';
import 'package:gamestream_flutter/website/website.dart';

class AccountService {

  static bool get premiumAccountAuthenticated {
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

  static void changeAccountPublicName(String value) async {
    print("actions.changePublicName('$value')");
    final account = Website.account.value;
    if (account == null) {
      Website.setError("Account is null");
      return;
    }
    value = value.trim();

    if (value == account.publicName){
      return;
    }

    if (value.isEmpty) {
      Website.setError("Name entered is empty");
      return;
    }
    Website.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      Website.setError(error.toString());
      throw error;
    });
    Website.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        updateAccount();
        website.actions.showDialogAccount();
        Website.setError("Name Changed successfully");
        break;
      case ChangeNameStatus.Taken:
        Website.setError("'$value' already taken");
        break;
      case ChangeNameStatus.Too_Short:
        Website.setError("Too short");
        break;
      case ChangeNameStatus.Too_Long:
        Website.setError("Too long");
        break;
      case ChangeNameStatus.Other:
        Website.setError("Something went wrong");
        break;
    }
  }

  static void cancelSubscription() async {
    print("actions.cancelSubscription()");
    website.actions.showDialogAccount();
    final account = Website.account.value;
    if (account == null) {
      Website.setError('Account is null');
      return;
    }
    Website.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await firestoreService.cancelSubscription(account.userId);
    await updateAccount();
    Website.operationStatus.value = OperationStatus.None;
  }

  static Future updateAccount() async {
    print("refreshAccountDetails()");
    final account = Website.account.value;
    if (account == null){
      return;
    }

    Website.operationStatus.value = OperationStatus.Updating_Account;
    Website.account.value = await firestoreService.findUserById(account.userId).catchError((error){
      return null;
    });
    Website.operationStatus.value = OperationStatus.None;
  }

  static Future login(DataAuthentication authentication){
    print("actions.login()");
    // storage.rememberAuthorization(authentication);
    return signInOrCreateAccount(
        userId: authentication.userId,
        email: authentication.email,
        privateName: authentication.name
    );
  }

  static Future signInOrCreateAccount({
    required String userId,
    required String email,
    required String privateName
  }) async {
    print("actions.signInOrCreateAccount()");
    Website.operationStatus.value = OperationStatus.Authenticating;
    final account = await firestoreService.findUserById(userId).catchError((error){
      throw error;
    });
    if (account == null){
      print("No account found. Creating new account");
      Website.operationStatus.value = OperationStatus.Creating_Account;
      await firestoreService.createAccount(userId: userId, email: email, privateName: privateName);
      Website.operationStatus.value = OperationStatus.Authenticating;
      Website.account.value = await firestoreService.findUserById(userId);
      if (Website.account.value == null){
        throw Exception("failed to find new account");
      }
      // TODO Illegal reference to website
      // Website.dialog.value = WebsiteDialog.Account_Created;
    }else{
      print("Existing Account found");
      Website.account.value = account;
    }
    Website.operationStatus.value = OperationStatus.None;
  }

  static void openStripeCheckout() {
    throw Exception("No longer supported");
    // print("actions.openStripeCheckout()");
    // final account = Website.account.value;
    // if (account == null){
    //   core.actions.setError("Account is null");
    //   return;
    // }
    // if (account.subscriptionActive){
    //   core.actions.setError("Premium subscription already active");
    //   return;
    // }
    //
    // Website.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
    // stripeCheckout(
    //     userId: account.userId,
    //     email: account.email
    // );
  }

  static void loginWithFacebook() async {
    final facebookAuthentication = await getAuthenticationFacebook();
    if (facebookAuthentication == null){
      return;
    }
    login(facebookAuthentication);
  }

  static void closeErrorMessage(){
    print("actions.closeErrorMessage()");
    Website.error.value = null;
  }

  // static void exitGame() => webSocket.disconnect();
}