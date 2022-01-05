
import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'helpers.dart';

// https://github.com/dart-lang/samples/tree/master/server/google_apis
void main() async {
  var handler =
  const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);
  var server = await shelf_io.serve(handler, '0.0.0.0', 8082);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
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
      final authClient = await getAuthClient();
      final api = FirestoreApi(authClient);
      final projectId = await currentProjectId();
      final result = await api.projects.databases.documents.commit(
        _incrementRequest(projectId),
        'projects/$projectId/databases/(default)',
      );
      return Response.ok('Success $result');
    default:
      return Response.ok('Cannot handle request "${request.url}"');
  }
}


CommitRequest _incrementRequest(String projectId) => CommitRequest(
  writes: [
    Write(
      transform: DocumentTransform(
        document:
        'projects/$projectId/databases/(default)/documents/settings/count',
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