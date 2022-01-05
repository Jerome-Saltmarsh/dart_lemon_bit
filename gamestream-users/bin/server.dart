
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'helpers.dart';

// https://github.com/dart-lang/samples/tree/master/server/google_apis
void main() async {
  var handler =
  const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);
  var server = await shelf_io.serve(handler, '0.0.0.0', 8080);
  // Enable content compression
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');

  // final projectId = await currentProjectId();
  // print('Current GCP project id: $projectId');

  // final authClient = await clientViaApplicationDefaultCredentials(
  //   scopes: [FirestoreApi.datastoreScope],
  // );
}

Response _echoRequest(Request request){
  final path = request.url.path;
  switch(path){
    case "webhook":
      print("handling webhook");
      return Response.ok('Request for "${request.url}"');
    case "project":
      return Response.ok('Request for "${request.url}"');
    default:
      return Response.ok('Cannot handle request "${request.url}"');
  }
}

