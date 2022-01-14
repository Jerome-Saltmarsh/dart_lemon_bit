import 'dart:async';
import 'dart:math';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';

final _Firestore firestore = _Firestore();

class _Firestore {

  final _projectId = "gogameserver";
  final _collectionName = 'users';

  FirestoreApi? _firestoreApi;

  // https://github.com/dart-lang/samples/tree/master/server/google_apis
  void init() async {
    print("firestore.init()");

    // _getProjectId().then((value){
    //   _projectId = value;
    //   print("projectId = '$value'");
    // });

    _getAuthClient().then((authClient){
      _firestoreApi = FirestoreApi(authClient);
      print("_firestoreApi set");
    });
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() {
    return clientViaApplicationDefaultCredentials(
      scopes: [FirestoreApi.datastoreScope],
    );
  }

  ProjectsDatabasesDocumentsResource get documents => _firestoreApi!.projects.databases.documents;

  Future<Document?> findUserById(String id) async {
    int tries = 0;
    final int maxTries = 10;
    while(_firestoreApi == null){
      tries++;
      if (tries > maxTries){
        throw Exception("exceeded max tries: $maxTries");
      }
      print("firestoreApi is null, waiting 1 second for it to load, try: $tries");
      await Future.delayed(_oneSecond);
    }

    print("database.findUserById('$id')");
    return documents.get(getUserDocumentName(id))
        .then<Document?>((value) => Future.value(value))
        .catchError((error) {
      if (error is DetailedApiRequestError && error.status == 404) {
        return null;
      }
      throw error;
    });
  }

  String getUserDocumentName(String value){
    return '${buildDocumentName(projectId: _projectId, collection: _collectionName)}/$value';
  }

  Future<Document> patchDisplayName({
    required String userId,
    required String displayName
  }) async {

    print("patchDisplayName($displayName)");
    final user = await findUserById(userId);
    if (user == null){
      throw Exception("user not found");
    }
    final fields = user.fields;

    if (fields == null){
      throw Exception("user fields null");
    }

    fields[fieldNames.public_name] = Value(stringValue: displayName);
    await saveUser(user);
    print("username patched successfully");
    return user;
  }

  Future<Document> subscribe({
    required String userId,
    required String stripeCustomerId,
    required String stripePaymentEmail,
}) async {
      print("subscribing new user(userId: $userId, customerId: $stripePaymentEmail, email: $stripePaymentEmail)");

      final user = await findUserById(userId);
      // TODO Store this information in an errors table
      if (user == null) throw Exception("user null");
      final fields = user.fields;

      if (fields == null){
        throw Exception("user.fields null");
      }

      fields[fieldNames.stripeCustomerId] = Value(stringValue: stripeCustomerId);
      fields[fieldNames.stripePaymentEmail] = Value(stringValue: stripePaymentEmail);
      fields[fieldNames.subscriptionCreatedDate] = Value(timestampValue: _getTimestampNow());
      fields[fieldNames.subscriptionExpirationDate] = Value(timestampValue: _getTimeStampOneMonth());
      saveUser(user);
      return user;
  }

  Future saveUser(Document userDocument) async {
    if (userDocument.name == null){
      throw Exception("Cannot save because user document.name is null");
    }
    await documents.patch(userDocument, userDocument.name!);
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
    print("query created");
    final responses = await documents.runQuery(query, parent);
    print("response received");

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

    return await documents.createDocument(
      document,
      parent,
      'users',
      documentId: userId,
      // $fields:
    );
  }

  String get parent => buildParentName(projectId: _projectId);
}

String _getTimestampNow() => DateTime.now().toUtc().toIso8601String();
String _getTimeStampOneMonth() => DateTime.now().add(Duration(hours: _hoursPerMonth)).toUtc().toIso8601String();

const _hoursPerMonth = _hoursPerYear ~/ _monthsPerYear;
const _monthsPerYear = 12;
const _hoursPerYear = 8760;

const _oneSecond = Duration(seconds: 1);

final _FieldNames fieldNames = _FieldNames();

class _FieldNames {
  final String account_creation_date = "account_creation_date";
  final String subscriptionExpirationDate = "subscription_expiration_date";
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


// Generate name serve
final _random = Random();

String generateRandomName(){
  return 'New_Player_${10000 + _random.nextInt(99999999)}';
}



//   Future<String> _getProjectId() async {
//     for (var envKey in _gcpProjectIdEnvironmentVariables) {
//       final value = Platform.environment[envKey];
//       if (value != null) return value;
//     }
//
//     const host = 'http://metadata.google.internal/';
//     final url = Uri.parse('$host/computeMetadata/v1/project/project-id');
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {'Metadata-Flavor': 'Google'},
//       );
//
//       if (response.statusCode != 200) {
//         throw HttpException(
//           '${response.body} (${response.statusCode})',
//           uri: url,
//         );
//       }
//
//       return response.body;
//     } on SocketException {
//       stderr.writeln(
//         '''
// Could not connect to $host.
// If not running on Google Cloud, one of these environment variables must be set
// to the target Google Project ID:
// ${_gcpProjectIdEnvironmentVariables.join('\n')}
// ''',
//       );
//       rethrow;
//     }
//   }

// const _gcpProjectIdEnvironmentVariables = {
//   'GCP_PROJECT',
//   'GCLOUD_PROJECT',
//   'CLOUDSDK_CORE_PROJECT',
//   'GOOGLE_CLOUD_PROJECT',
// };

