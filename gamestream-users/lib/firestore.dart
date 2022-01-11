import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart' as http;

final _Firestore firestore = _Firestore();

class _Firestore {

  String _projectId = "";
  FirestoreApi? _firestoreApi;

  // https://github.com/dart-lang/samples/tree/master/server/google_apis
  void init() async {
    print("firestore.init()");
    _projectId = await _getProjectId();
    final authClient = await _getAuthClient();
    _firestoreApi = FirestoreApi(authClient);
    print("firestore initialized");
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() {
    return clientViaApplicationDefaultCredentials(
      scopes: [FirestoreApi.datastoreScope],
    );
  }

  Future<String> _getProjectId() async {
    for (var envKey in _gcpProjectIdEnvironmentVariables) {
      final value = Platform.environment[envKey];
      if (value != null) return value;
    }

    const host = 'http://metadata.google.internal/';
    final url = Uri.parse('$host/computeMetadata/v1/project/project-id');

    try {
      final response = await http.get(
        url,
        headers: {'Metadata-Flavor': 'Google'},
      );

      if (response.statusCode != 200) {
        throw HttpException(
          '${response.body} (${response.statusCode})',
          uri: url,
        );
      }

      return response.body;
    } on SocketException {
      stderr.writeln(
        '''
Could not connect to $host.
If not running on Google Cloud, one of these environment variables must be set
to the target Google Project ID:
${_gcpProjectIdEnvironmentVariables.join('\n')}
''',
      );
      rethrow;
    }
  }

  ProjectsDatabasesDocumentsResource get documents => _firestoreApi!.projects.databases.documents;

  Future<Document?> findUserById(String id) async {
    int tries = 0;
    while(_firestoreApi == null){
      tries++;
      if (tries > 10){
        throw Exception("tries greater than 5");
      }
      print("firestoreApi is null, waiting 1 second for it to load, try: $tries");
      await Future.delayed(_oneSecond);
    }

    print("database.findUserById('$id')");
    return documents.get(_name('users/$id'))
        .then<Document?>((value) => Future.value(value))
        .catchError((error) {
      if (error is DetailedApiRequestError && error.status == 404) {
        return null;
      }
      throw error;
    });
  }


  String _name(String value){
    return 'projects/$_projectId/databases/(default)/documents/$value';
  }

  Future<CommitResponse> commit(CommitRequest request) {
    return documents.commit(
      request,
      'projects/$_projectId/databases/(default)',
    );
  }

  Future<Document> createUser({
    required String userIdGameStream,
    required String userIdStripe,
    String? email,
  }) async {
    print("database.createUser('$userIdGameStream')");
    if (userIdGameStream.isEmpty){
      throw Exception("userId is null");
    }

    final document = Document(
        createTime: _getTimestampNow(),
        fields: {
          fieldNames.stripeCustomerId: Value(stringValue: userIdStripe),
          fieldNames.subscriptionExpirationDate: Value(timestampValue: _getTimeStampOneMonth()),
          if (email != null)
            fieldNames.email: Value(stringValue: email),
        }
    );


    final parent = 'projects/$_projectId/databases/(default)/documents';
    return await documents.createDocument(
      document,
      parent,
      'users',
      documentId: userIdGameStream,
      // $fields:
    );
  }
}

const _gcpProjectIdEnvironmentVariables = {
  'GCP_PROJECT',
  'GCLOUD_PROJECT',
  'CLOUDSDK_CORE_PROJECT',
  'GOOGLE_CLOUD_PROJECT',
};

String _getTimestampNow() => DateTime.now().toUtc().toIso8601String();
String _getTimeStampOneMonth() => DateTime.now().add(Duration(hours: _hoursPerMonth)).toUtc().toIso8601String();

const _hoursPerMonth = _hoursPerYear ~/ _monthsPerYear;
const _monthsPerYear = 12;
const _hoursPerYear = 8760;

const _oneSecond = Duration(seconds: 1);


final _FieldNames fieldNames = _FieldNames();

class _FieldNames {
  final String subscriptionExpirationDate = "subscription_expiration_date";
  final String subscriptionStatus = "subscription_status";
  final String error = "error";
  final String stripeCustomerId = 'stripe_customer_id';
  final String email = 'email';
}