
import 'dart:async';
import 'dart:convert';

import 'package:googleapis/bigquery/v2.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'helpers.dart';

// https://github.com/dart-lang/samples/tree/master/server/google_apis
final _Project project = _Project();
final jsonEncoder = JsonEncoder();
final jsonDecoder = JsonDecoder();

FirestoreApi? firestore;

class _Project {
  String id = "";
}

void main() async {
  initFirestore();
  initProjectId();
  initServer();
}

void initServer() async {
  print("initServer()");
  var handler =
  const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);
  var server = await shelf_io.serve(handler, '0.0.0.0', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

void initFirestore() async {
  print("initFirestore()");
  print("getAuthClient");
  final authClient = await getAuthClient();
  print("authClient set");
  print("init firestore api");
  firestore = FirestoreApi(authClient);
  print("firestore api initialized");
}

void initProjectId() async {
  print("initProjectId()");
  project.id = await currentProjectId();
  print("project.id = ${project.id}");
}

Future<AutoRefreshingAuthClient> getAuthClient() {
  return clientViaApplicationDefaultCredentials(
    scopes: [FirestoreApi.datastoreScope],
  );
}

final _Responses _responses = _Responses();

class _Responses {
  final firestoreIsNull = Response.internalServerError(body: 'firestore is null');
}

FutureOr<Response> _echoRequest(Request request) async {
  if (firestore == null){
    return _responses.firestoreIsNull;
  }

  final path = request.url.path;
  switch(path){
    case "webhook":
      print("handling webhook");
      return Response.ok('Request for "${request.url}"');
    case "project":
      final projectId = await currentProjectId();
      return Response.ok('project-id: $projectId');
    case "increment":
      final result = await firestore!.projects.databases.documents.commit(
        _incrementRequest(project.id),
        'projects/${project.id}/databases/(default)',
      );
      return Response.ok('Success $result');
    case "users":

      if (request.method == 'POST') {
        print("request.method == 'POST'");
        final bodyString = await request.readAsString();
        if (bodyString.isEmpty){
          return Response.forbidden('body is empty');
        }
        final body = jsonDecoder.convert(bodyString);
        if (body is Map == false){
          return Response.forbidden('body is not map');
        }
        final bodyMap = body as Map;

        if (!bodyMap.containsKey('id')){
          return Response.forbidden('body requires field id');
        }
        final userId = bodyMap['id'];
        subscribeUser(userId);
      }

      final params = request.requestedUri.queryParameters;
      if (!params.containsKey('id')) {
        final users = await documents.get(_name('users'));
        print(users.toString());
        return Response.ok(users.toString());
      }
      final id = params['id'];
      if (id == null) {
        return Response.forbidden('id is empty');
      }
      if (firestore == null){
        throw Exception("firestore is null");
      }
      final user = await database.findUserById(id);
      if (user == null){
        return Response.notFound("user with id $id could not be found");
      }
      final fields = jsonEncoder.convert(user.fields);
      return Response.ok(fields);
    default:
      return Response.ok('Cannot handle request "${request.url}"');
  }
}

// Future<CommitResponse> commit(CommitRequest request) {
//   return documents.commit(
//     request,
//     'projects/${project.id}/databases/(default)',
//   );
// }



CommitRequest _incrementRequest(String projectId) => CommitRequest(
  writes: [
    Write(
      transform: DocumentTransform(
        document:
        'projects/$projectId/databases/(default)/documents/users/count',
        fieldTransforms: [
          FieldTransform(
            fieldPath: 'count',
            increment: Value(integerValue: '1'),
          )
        ],
      ),
    ),
  ],
);

Future<CommitResponse> subscribeUser(String userId){
  print("subscribeUser('$userId'");
  final request = CommitRequest(
    writes: [
      Write(
        transform: DocumentTransform(
          document: _name('users/$userId'),
          fieldTransforms: [
            FieldTransform(
              fieldPath: 'date',
              increment: Value(timestampValue: _getTimestamp()),
            ),
          ],
        ),
      ),
    ],
  );
  return database.commit(request);
}

String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

ProjectsDatabasesDocumentsResource get documents => firestore!.projects.databases.documents;

final _Database database = _Database();

class _Database {
  Future<Document?> findUserById(String id) {
    print("findUserById('$id')");
    return _findUserById(id)
        .then<Document?>((value) => Future.value(value))
        .catchError((error) {
      if (error is DetailedApiRequestError && error.status == 404) {
        return null;
      }
      throw error;
    });
  }

  Future<Document?> _findUserById(String id){
    return documents.get(_name('users/$id'));
  }

  Future<CommitResponse> commit(CommitRequest request) {
    return documents.commit(
      request,
      'projects/${project.id}/databases/(default)',
    );
  }

}

String _name(String value){
  return 'projects/${project.id}/databases/(default)/documents/$value';
}