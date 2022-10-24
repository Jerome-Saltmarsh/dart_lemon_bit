import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/actions/sign_in_with_facebook.dart';

class AccountService {

  static bool get premiumAccountAuthenticated {
    final account = GameWebsite.account.value;
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
    final account = GameWebsite.account.value;
    if (account == null) {
      GameWebsite.setError("Account is null");
      return;
    }
    value = value.trim();

    if (value == account.publicName){
      return;
    }

    if (value.isEmpty) {
      GameWebsite.setError("Name entered is empty");
      return;
    }
    GameWebsite.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      GameWebsite.setError(error.toString());
      throw error;
    });
    GameWebsite.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        updateAccount();
        website.actions.showDialogAccount();
        GameWebsite.setError("Name Changed successfully");
        break;
      case ChangeNameStatus.Taken:
        GameWebsite.setError("'$value' already taken");
        break;
      case ChangeNameStatus.Too_Short:
        GameWebsite.setError("Too short");
        break;
      case ChangeNameStatus.Too_Long:
        GameWebsite.setError("Too long");
        break;
      case ChangeNameStatus.Other:
        GameWebsite.setError("Something went wrong");
        break;
    }
  }

  static void cancelSubscription() async {
    print("actions.cancelSubscription()");
    website.actions.showDialogAccount();
    final account = GameWebsite.account.value;
    if (account == null) {
      GameWebsite.setError('Account is null');
      return;
    }
    GameWebsite.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await firestoreService.cancelSubscription(account.userId);
    await updateAccount();
    GameWebsite.operationStatus.value = OperationStatus.None;
  }

  static Future updateAccount() async {
    print("refreshAccountDetails()");
    final account = GameWebsite.account.value;
    if (account == null){
      return;
    }

    GameWebsite.operationStatus.value = OperationStatus.Updating_Account;
    GameWebsite.account.value = await firestoreService.findUserById(account.userId).catchError((error){
      return null;
    });
    GameWebsite.operationStatus.value = OperationStatus.None;
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
    GameWebsite.operationStatus.value = OperationStatus.Authenticating;
    final account = await firestoreService.findUserById(userId).catchError((error){
      throw error;
    });
    if (account == null){
      print("No account found. Creating new account");
      GameWebsite.operationStatus.value = OperationStatus.Creating_Account;
      await firestoreService.createAccount(userId: userId, email: email, privateName: privateName);
      GameWebsite.operationStatus.value = OperationStatus.Authenticating;
      GameWebsite.account.value = await firestoreService.findUserById(userId);
      if (GameWebsite.account.value == null){
        throw Exception("failed to find new account");
      }
      // TODO Illegal reference to website
      // Website.dialog.value = WebsiteDialog.Account_Created;
    }else{
      print("Existing Account found");
      GameWebsite.account.value = account;
    }
    GameWebsite.operationStatus.value = OperationStatus.None;
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
    GameWebsite.error.value = null;
  }

  // static void exitGame() => webSocket.disconnect();
}