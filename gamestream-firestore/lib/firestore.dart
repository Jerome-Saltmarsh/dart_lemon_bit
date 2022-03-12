import 'dart:async';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

final firestore = _Firestore();

class _Collections {
  final users = "users";
  final maps = "maps";
  final characters = "characters";
}

class _Firestore {

  final _projectId = "gogameserver";
  final collections = _Collections();

  FirestoreApi? _firestoreApi;

  // https://github.com/dart-lang/samples/tree/master/server/google_apis
  void init() async {
    print("firestore.init()");
    _getAuthClient().then((authClient){
      _firestoreApi = FirestoreApi(authClient);
      print("_firestoreApi set");
    });
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() {
    return auth.clientViaMetadataServer();
  }

  ProjectsDatabasesDocumentsResource get documents => _firestoreApi!.projects.databases.documents;

  Future<Document?> findCharacterById(String id) async {
    return findDocumentById(collection: collections.characters, id: id);
  }

  Future<Document?> findUserById(String id) async {
    return findDocumentById(collection: collections.users, id: id);
  }

  Future<Document?> findMapById(String id) {
     return findDocumentById(collection: collections.maps, id: id);
  }

  Future<Document?> findDocumentById({required String collection, required String id}) async {
    var tries = 0;
    final int maxTries = 10;
    while(_firestoreApi == null){
      tries++;
      if (tries > maxTries){
        throw Exception("exceeded max tries: $maxTries");
      }
      print("firestoreApi is null, waiting 1 second for it to load, try: $tries");
      await Future.delayed(_oneSecond);
    }
    final documentName =  getDocumentName(collection: collection, value: id);

    return documents.get(documentName)
        .then<Document?>((value) => Future.value(value))
        .catchError((error) {
      if (error is DetailedApiRequestError && error.status == 404) {
        return null;
      }
      throw error;
    });
  }


  Future<List<String>> getMapIds() async {
    print("firestore.getMapIds()");
    final list = await documents.list(parent, "maps");
    final docs = list.documents;
    if (docs == null) return [];
    List<String> names = [];
    for(var doc in docs){
      final docName = doc.name;
      if (docName == null) continue;
      final segments = docName.split('/');
      names.add(segments.last);
    }
    return names;
  }

  String getDocumentName({required String collection, required String value}){
    return '${buildDocumentName(projectId: _projectId, collection: collection)}/$value';
  }

  Future<Document> patchPublicName({
    required String userId,
    required String publicName
  }) async {

    print("firestore.patchPublicName($publicName)");
    final user = await findUserById(userId);
    if (user == null){
      throw Exception("user not found");
    }
    final fields = user.fields;

    if (fields == null){
      throw Exception("user fields null");
    }

    fields[fieldNames.public_name] = Value(stringValue: publicName);
    await saveUser(user);
    print("public_named patched successfully");
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

  Future saveDocument({
    required String userId,
    required int x,
    required int y
  }) async {
    final document = Document(
        name: getDocumentName(collection: collections.characters, value: userId),
        createTime: _getTimestampNow(),
        fields: {
          'user-id': Value(stringValue: userId),
          'x': Value(integerValue: x.toString()),
          'y': Value(integerValue: y.toString()),
        }
    );
    await documents.patch(document, getDocumentName(collection: collections.characters, value: userId));
    print("saveDocument() Finished");
  }

  Future saveUser(Document userDocument) async {
    if (userDocument.name == null){
      throw Exception("Cannot save because user document.name is null");
    }
    await documents.patch(userDocument, userDocument.name!);
  }

  Future<Document?> findUserByPublicName(String publicName) async {
    print("firestore.findUserByPublicName('$publicName')");
    final query = RunQueryRequest(
        structuredQuery: StructuredQuery(
          from: [
            CollectionSelector(
              collectionId: collections.users
            )
          ],
          where: Filter(
              fieldFilter: FieldFilter(
                 field: FieldReference(fieldPath: fieldNames.public_name),
                     op: 'EQUAL',
                value: Value(stringValue: publicName),
              )
          )
        )
    );
    final responses = await documents.runQuery(query, parent);
    for (var response in responses.toList()) {
      final doc = response.document;
      if (doc == null) continue;
      final docFields = doc.fields;
      if (docFields == null) continue;
      final publicNameField = docFields[fieldNames.public_name];
      if (publicNameField == null) continue;
      final publicNameString = publicNameField.stringValue;
      if (publicNameString == null) continue;
      if (publicNameString.toLowerCase() != publicName.toLowerCase()) continue;
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

  Future patchMap({
    required Document document,
    required String data
  }) async {
    print("firestore.patchMap()");
    if (document.fields == null){
      document.fields = {};
    }
    final documentName = document.name;
    if (documentName == null){
      throw Exception("Map document name is null");
    }
    document.fields!['data'] = Value(stringValue: data);
    await documents.patch(document, documentName);
  }

  Future<Document> createMap({
    required String mapId,
    required String data,
  }) async {
    print("firestore.createMap('$mapId')");
    if (mapId.isEmpty){
      throw Exception("mapId is null");
    }
    final document = Document(
        createTime: _getTimestampNow(),
        fields: {
          'data': Value(stringValue: data),
        }
    );

    return await documents.createDocument(
      document,
      parent,
      'maps',
      documentId: mapId,
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
String _getTimeStampOneMonth() => DateTime.now().add(Duration(hours: _hoursPerMonth)).toUtc().toIso8601String();

const _hoursPerMonth = _hoursPerYear ~/ _monthsPerYear;
const _monthsPerYear = 12;
const _hoursPerYear = 8760;

const _oneSecond = Duration(seconds: 1);

final _FieldNames fieldNames = _FieldNames();

class _FieldNames {
  final String subscriptionId = "subscription_id";
  final String account_creation_date = "account_creation_date";
  final String creation_date = "creation_date";
  final String subscriptionExpirationDate = "subscription_expiration_date";
  final String subscriptionCreatedDate = "subscription_created_date";
  final String subscriptionStatus = "subscription_status";
  final String subscriptionStartDate = "subscription_start_date";
  final String subscriptionEndedAt = "subscription_ended_at";
  final String subscriptionLiveMode = "subscription_live_mode";
  final String subscriptionCurrentPeriodStart = "subscription_current_period_start";
  final String subscriptionCurrentPeriodEnd = "subscription_current_period_end";
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
