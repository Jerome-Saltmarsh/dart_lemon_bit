import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart' as http;

String _projectId = "";
FirestoreApi? _firestoreApi;

void initFirestore() async {
  print("initFirestore()");
  print("getAuthClient");
  final authClient = await _getAuthClient();
  print("authClient set");
  print("init firestore api");
  _firestoreApi = FirestoreApi(authClient);
  print("firestore api initialized");
  print("initProjectId()");
  _projectId = await _currentProjectId();
  print("project.id = $_projectId");
}

Future<AutoRefreshingAuthClient> _getAuthClient() {
  return clientViaApplicationDefaultCredentials(
    scopes: [FirestoreApi.datastoreScope],
  );
}

Future<String> _currentProjectId() async {
  for (var envKey in gcpProjectIdEnvironmentVariables) {
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
${gcpProjectIdEnvironmentVariables.join('\n')}
''',
    );
    rethrow;
  }
}


const gcpProjectIdEnvironmentVariables = {
  'GCP_PROJECT',
  'GCLOUD_PROJECT',
  'CLOUDSDK_CORE_PROJECT',
  'GOOGLE_CLOUD_PROJECT',
};



String _getTimestamp() => DateTime.now().toUtc().toIso8601String();

final _Database database = _Database();

class _Database {

  ProjectsDatabasesDocumentsResource get documents => _firestoreApi!.projects.databases.documents;

  Future<Document?> findUserById(String id) {
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
        createTime: _getTimestamp(),
        fields: {
          'stripe_customer_id': Value(stringValue: userIdStripe),
          if (email != null)
            'email': Value(stringValue: email),
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

String _name(String value){
  return 'projects/$_projectId/databases/(default)/documents/$value';
}