
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'helpers.dart';

// https://github.com/dart-lang/samples/tree/master/server/google_apis
final _Project project = _Project();

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
  var server = await shelf_io.serve(handler, '0.0.0.0', 8082);
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

FutureOr<Response> _echoRequest(Request request) async {
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
      final params = request.requestedUri.queryParameters;
      if (!params.containsKey('id')) {
        return Response.forbidden('id required');
      }
      final id = params['id'];
      if (id == null) {
        return Response.forbidden('id is empty');
      }
      if (firestore == null){
        throw Exception("firestore is null");
      }
      final user = await findUserById(id);
      return Response.ok(user.toString());
    default:
      return Response.ok('Cannot handle request "${request.url}"');
  }
}

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

CommitRequest subscribeUser(String userId) => CommitRequest(
  writes: [
    Write(
      transform: DocumentTransform(
        document:
        'projects/${project.id}/databases/(default)/documents/users/$userId',
        fieldTransforms: [
          FieldTransform(
            fieldPath: 'count',
            increment: Value(integerValue: '1'),
          ),
          FieldTransform(
            fieldPath: 'date',
            increment: Value(timestampValue: getTimestamp()),
          )

        ],
      ),
    ),
  ],
);

String getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

ProjectsDatabasesDocumentsResource get documents => firestore!.projects.databases.documents;


Future<Document> findUserById(String id){
  print("findUserById('$id')");
  return documents.get('users/$id');
}