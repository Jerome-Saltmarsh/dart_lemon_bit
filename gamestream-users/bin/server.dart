
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

  // print('Current GCP project id: $projectId');

  // final authClient = await clientViaApplicationDefaultCredentials(
  //   scopes: [FirestoreApi.datastoreScope],
  // );
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
    default:
      return Response.ok('Cannot handle request "${request.url}"');
  }
}

