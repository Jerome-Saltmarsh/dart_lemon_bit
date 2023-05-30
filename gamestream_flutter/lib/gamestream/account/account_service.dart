import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/gamestream/account/sign_in_with_facebook.dart';

import '../enums/operation_status.dart';
import 'data_authentication.dart';

class AccountService {

  static bool get premiumAccountAuthenticated {
    final account = gamestream.games.gameWebsite.account.value;
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
    final account = gamestream.games.gameWebsite.account.value;
    if (account == null) {
      gamestream.games.gameWebsite.setError("Account is null");
      return;
    }
    value = value.trim();

    if (value == account.publicName){
      return;
    }

    if (value.isEmpty) {
      gamestream.games.gameWebsite.setError("Name entered is empty");
      return;
    }
    gamestream.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      gamestream.games.gameWebsite.setError(error.toString());
      throw error;
    });
    gamestream.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        updateAccount();
        gamestream.games.gameWebsite.showDialogAccount();
        gamestream.games.gameWebsite.setError("Name Changed successfully");
        break;
      case ChangeNameStatus.Taken:
        gamestream.games.gameWebsite.setError("'$value' already taken");
        break;
      case ChangeNameStatus.Too_Short:
        gamestream.games.gameWebsite.setError("Too short");
        break;
      case ChangeNameStatus.Too_Long:
        gamestream.games.gameWebsite.setError("Too long");
        break;
      case ChangeNameStatus.Other:
        gamestream.games.gameWebsite.setError("Something went wrong");
        break;
    }
  }

  static void cancelSubscription() async {
    print("actions.cancelSubscription()");
    gamestream.games.gameWebsite.showDialogAccount();
    final account = gamestream.games.gameWebsite.account.value;
    if (account == null) {
      gamestream.games.gameWebsite.setError('Account is null');
      return;
    }
    gamestream.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await firestoreService.cancelSubscription(account.userId);
    await updateAccount();
    gamestream.operationStatus.value = OperationStatus.None;
  }

  static Future updateAccount() async {
    print("refreshAccountDetails()");
    final account = gamestream.games.gameWebsite.account.value;
    if (account == null){
      return;
    }

    gamestream.operationStatus.value = OperationStatus.Updating_Account;
    gamestream.games.gameWebsite.account.value = await firestoreService.findUserById(account.userId).catchError((error){
      return null;
    });
    gamestream.operationStatus.value = OperationStatus.None;
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
    gamestream.operationStatus.value = OperationStatus.Authenticating;
    final account = await firestoreService.findUserById(userId).catchError((error){
      throw error;
    });
    if (account == null){
      print("No account found. Creating new account");
      gamestream.operationStatus.value = OperationStatus.Creating_Account;
      await firestoreService.createAccount(userId: userId, email: email, privateName: privateName);
      gamestream.operationStatus.value = OperationStatus.Authenticating;
      gamestream.games.gameWebsite.account.value = await firestoreService.findUserById(userId);
      if (gamestream.games.gameWebsite.account.value == null){
        throw Exception("failed to find new account");
      }
      // TODO Illegal reference to website
      // Website.dialog.value = WebsiteDialog.Account_Created;
    }else{
      print("Existing Account found");
      gamestream.games.gameWebsite.account.value = account;
    }
    gamestream.operationStatus.value = OperationStatus.None;
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
    WebsiteState.error.value = null;
  }
}
