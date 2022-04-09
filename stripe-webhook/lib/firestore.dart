import 'dart:async';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'package:googleapis_auth/auth_io.dart' as auth;

final _Firestore firestore = _Firestore();

class _Firestore {

  final _projectId = "gogameserver";
  final _collectionName = 'users';

  FirestoreApi? _firestoreApi;

  void init() async {
    _firestoreApi = await getFirestoreApi();
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() {
    return auth.clientViaMetadataServer();
    // return clientViaApplicationDefaultCredentials(
    //   scopes: [FirestoreApi.datastoreScope],
    // );
  }

  Future<FirestoreApi> getFirestoreApi() async {
     if (_firestoreApi != null) return Future.value(_firestoreApi);
     final authClient = await _getAuthClient().catchError((error){
       print("firestore failed to get auth client");
       throw error;
     });
     _firestoreApi = FirestoreApi(authClient);
     return Future.value(_firestoreApi);
  }

  Future<ProjectsDatabasesDocumentsResource> getDocuments() async {
    final api = await getFirestoreApi().catchError((error){
      print("firestore failed to get firestoreApi instance");
      throw error;
    });
    return api.projects.databases.documents;
  }

  Future<Document?> findUserById(String id) async {
    print("firestore.findUserById('$id')");
    final documents = await getDocuments();
    final documentName = getUserDocumentName(id);
    return documents.get(documentName)
        .then<Document?>((value) => Future.value(value))
        .catchError((error) {
      if (error is DetailedApiRequestError && error.status == 404) {
        print("no user could be found with id '$id'");
        return null;
      }
      print("firestore.findUserById failed");
      print(error);
      throw error;
    });
  }

  Future<Document?> safelyFindUserById(String id) async {
    print("safelyFindUserById('$id')");
    for (int attempt = 1; attempt < 10; attempt++){
      bool errorOccurred = false;
      final user = await findUserById(id).catchError((error){
        errorOccurred = true;
        print("safelyFindUser error occurred: Attempt $attempt / 10");
        print(error);
      });
      if (!errorOccurred){
        if (attempt > 1){
          print("find user succeeded on attempt $attempt");
        }
        return user;
      }
    }
    print("Failed to get user after 10 tries");
    throw Exception("safelyFindUserById() failed");
  }

  String getUserDocumentName(String value){
    return '${buildDocumentName(projectId: _projectId, collection: _collectionName)}/$value';
  }

  Future<Document> patchDisplayName({
    required String userId,
    required String displayName
  }) async {

    print("patchDisplayName($displayName)");
    final user = await safelyFindUserById(userId);
    if (user == null){
      throw Exception("user not found");
    }
    final fields = user.fields;

    if (fields == null){
      throw Exception("user fields null");
    }

    fields[fieldNames.public_name] = Value(stringValue: displayName);
    await patchUserDocument(user);
    print("username patched successfully");
    return user;
  }

  Future subscribe({
    required String userId,
    required String stripeCustomerId,
    required String stripePaymentEmail,
    required String subscriptionId,
  }) async {
      print("firestore.subscribe('userId: '$userId', subscriptionId: '$subscriptionId')");
      print("firestore.subscribe.findUserById()");
      final user = await safelyFindUserById(userId);
      if (user == null) throw Exception("user null");
      print("firestore.subscribe.findUserById() - finished");
      final fields = user.fields;

      if (fields == null){
        throw Exception("user.fields null");
      }

      fields[fieldNames.subscriptionId] = Value(stringValue: subscriptionId);
      await patchUserDocument(user);
  }

  Future patchUserDocument(Document userDocument) async {
    print("firestore.patchUserDocument()");
    final documentName = userDocument.name;
    if (documentName == null){
      throw Exception("firestore.patchUserDocument - Cannot patch because user document.name is null");
    }

    final maxAttempts = 10;
    final Duration pauseDuration = Duration(seconds: 1);
    final documents = await getDocuments();

    for(int i = 1; i <= maxAttempts; i++){
      bool saveSucceeded = true;
      await documents.patch(userDocument, documentName).catchError((error) async {
        print("(firestore) patch error attempt: $i");
        saveSucceeded = false;
        await Future.delayed(pauseDuration);
      });
      if (saveSucceeded){
        print("patch user succeeded");
        return;
      }
    }

    // TODO Store this in memory and try again later
    throw Exception("firestore.saveUser() - failed");
  }

  Future<Document?> findUser({required String displayName}) async {
    print("(firestore) findUser(displayName: '$displayName')");

    final query = RunQueryRequest(
        structuredQuery: StructuredQuery(
          from: [
            CollectionSelector(
              collectionId: _collectionName
            )
          ],
          where: Filter(
              fieldFilter: FieldFilter(
                 field: FieldReference(fieldPath: 'display_name'),
                     op: 'EQUAL',
                value: Value(stringValue: displayName),
              )
          )
        )
    );
    final documents = await getDocuments();
    final responses = await documents.runQuery(query, parent);
    for (var response in responses.toList()) {
      return response.document;
    }
    return null;
  }

  Future<Document> createUser({
    required String userId,
    required String privateName,
    required String publicName,
    required String email,
  }) async {
    print("database.createUser('$userId')");
    if (userId.isEmpty){
      throw Exception("userId is null");
    }

    final document = Document(
        createTime: _getTimestampNow(),
        fields: {
          fieldNames.private_name: Value(stringValue: privateName),
          fieldNames.public_name: Value(stringValue: publicName),
          fieldNames.account_creation_date: Value(timestampValue: _getTimestampNow()),
          fieldNames.email: Value(stringValue: email),

        }
    );

    final docs = await getDocuments();
    return await docs.createDocument(
      document,
      parent,
      'users',
      documentId: userId,
      // $fields:
    );
  }

  String get parent => buildParentName(projectId: _projectId);

  Future waitForFirestoreApi() async {
    int tries = 0;
    int maxTries = 10;
    while(_firestoreApi == null){
      tries++;
      if (tries > maxTries){
        throw Exception("exceeded max tries: $maxTries");
      }
      print("firestoreApi is null, waiting 1 second for it to load, try: $tries");
      await Future.delayed(_oneSecond);
    }
  }
}

String _getTimestampNow() => DateTime.now().toUtc().toIso8601String();

const _oneSecond = Duration(seconds: 1);

final _FieldNames fieldNames = _FieldNames();

class _FieldNames {
  final String account_creation_date = "account_creation_date";
  final String subscriptionExpirationDate = "subscription_expiration_date";
  final String subscriptionId = "subscription_id";
  final String subscriptionCreatedDate = "subscription_created_date";
  final String error = "error";
  final String stripeCustomerId = 'stripe_customer_id';
  final String stripePaymentEmail = 'stripe_payment_email';
  final String email = 'email';
  final String public_name = 'public_name';
  final String private_name = 'private_name';
}

String buildDocumentName({
  required String projectId,
  required String collection
}){
  return '${buildParentName(projectId: projectId)}/$collection';
}

String buildParentName({
  required String projectId,
  String databaseName = '(default)'
}){
  return 'projects/$projectId/databases/$databaseName/documents';
}

final JobService jobService = JobService();

class JobService {
  final List<SaveSubscription> todo = [];
  final List<SaveSubscription> completed = [];
}

class SaveSubscription {
  final String subscriptionId;
  final String userId;
  SaveSubscription({
    required  this.subscriptionId,
    required this.userId
  });
}