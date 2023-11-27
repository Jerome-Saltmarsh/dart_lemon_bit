// import 'package:firestore_client/firestoreService.dart';
// import 'package:amulet_flutter/gamestream/gamestream.dart';
// import 'package:amulet_flutter/gamestream/account/sign_in_with_facebook.dart';
//
// import '../operation_status.dart';
// import 'data_authentication.dart';
//
// class AccountService {
//
//   final Gamestream gamestream;
//
//   AccountService(this.gamestream);
//
//   bool get premiumAccountAuthenticated {
//     final account = gamestream.account.value;
//     if (account == null){
//       return false;
//     }
//     final subscriptionEndDate = account.subscriptionEndDate;
//     if (subscriptionEndDate == null) {
//       return false;
//     }
//     return subscriptionEndDate.isAfter(DateTime.now());
//   }
//
//   void changeAccountPublicName(String value) async {
//     print("actions.changePublicName('$value')");
//     final account = gamestream.account.value;
//     if (account == null) {
//       gamestream.games.website.setError('Account is null');
//       return;
//     }
//     value = value.trim();
//
//     if (value == account.publicName){
//       return;
//     }
//
//     if (value.isEmpty) {
//       gamestream.games.website.setError('Name entered is empty');
//       return;
//     }
//     gamestream.operationStatus.value = OperationStatus.Changing_Public_Name;
//     final response = await firestoreService
//         .changePublicName(userId: account.userId, publicName: value)
//         .catchError((error) {
//       gamestream.games.website.setError(error.toString());
//       throw error;
//     });
//     gamestream.operationStatus.value = OperationStatus.None;
//
//     switch (response) {
//       case ChangeNameStatus.Success:
//         updateAccount();
//         gamestream.games.website.showDialogAccount();
//         gamestream.games.website.setError('Name Changed successfully');
//         break;
//       case ChangeNameStatus.Taken:
//         gamestream.games.website.setError("'$value' already taken");
//         break;
//       case ChangeNameStatus.Too_Short:
//         gamestream.games.website.setError('Too short');
//         break;
//       case ChangeNameStatus.Too_Long:
//         gamestream.games.website.setError('Too long');
//         break;
//       case ChangeNameStatus.Other:
//         gamestream.games.website.setError('Something went wrong');
//         break;
//     }
//   }
//
//   void cancelSubscription() async {
//     print('actions.cancelSubscription()');
//     gamestream.games.website.showDialogAccount();
//     final account = gamestream.account.value;
//     if (account == null) {
//       gamestream.games.website.setError('Account is null');
//       return;
//     }
//     gamestream.operationStatus.value = OperationStatus.Cancelling_Subscription;
//     await firestoreService.cancelSubscription(account.userId);
//     await updateAccount();
//     gamestream.operationStatus.value = OperationStatus.None;
//   }
//
//   Future updateAccount() async {
//     print('refreshAccountDetails()');
//     final account = gamestream.account.value;
//     if (account == null){
//       return;
//     }
//
//     gamestream.operationStatus.value = OperationStatus.Updating_Account;
//     gamestream.account.value = await firestoreService.findUserById(account.userId).catchError((error){
//       return null;
//     });
//     gamestream.operationStatus.value = OperationStatus.None;
//   }
//
//   Future login(DataAuthentication authentication){
//     print('actions.login()');
//     // storage.rememberAuthorization(authentication);
//     return signInOrCreateAccount(
//         userId: authentication.userId,
//         email: authentication.email,
//         privateName: authentication.name
//     );
//   }
//
//   Future signInOrCreateAccount({
//     required String userId,
//     required String email,
//     required String privateName
//   }) async {
//     print('actions.signInOrCreateAccount()');
//     gamestream.operationStatus.value = OperationStatus.Authenticating;
//     final account = await firestoreService.findUserById(userId).catchError((error){
//       throw error;
//     });
//     if (account == null){
//       print('No account found. Creating new account');
//       gamestream.operationStatus.value = OperationStatus.Creating_Account;
//       await firestoreService.createAccount(userId: userId, email: email, privateName: privateName);
//       gamestream.operationStatus.value = OperationStatus.Authenticating;
//       gamestream.account.value = await firestoreService.findUserById(userId);
//       if (gamestream.account.value == null){
//         throw Exception('failed to find new account');
//       }
//       // TODO Illegal reference to website
//       // Website.dialog.value = WebsiteDialog.Account_Created;
//     }else{
//       print('Existing Account found');
//       gamestream.account.value = account;
//     }
//     gamestream.operationStatus.value = OperationStatus.None;
//   }
//
//   void openStripeCheckout() {
//     throw Exception('No longer supported');
//     // print("actions.openStripeCheckout()");
//     // final account = Website.account.value;
//     // if (account == null){
//     //   core.actions.setError("Account is null");
//     //   return;
//     // }
//     // if (account.subscriptionActive){
//     //   core.actions.setError("Premium subscription already active");
//     //   return;
//     // }
//     //
//     // Website.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
//     // stripeCheckout(
//     //     userId: account.userId,
//     //     email: account.email
//     // );
//   }
//
//   void loginWithFacebook() async {
//     final facebookAuthentication = await getAuthenticationFacebook();
//     if (facebookAuthentication == null){
//       return;
//     }
//     login(facebookAuthentication);
//   }
// }
