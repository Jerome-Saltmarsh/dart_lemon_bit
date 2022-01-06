
import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:googleapis/firestore/v1.dart';

import '../lib/firestore.dart';

// https://stripe.com/docs/webhooks
// https://github.com/dart-lang/samples/tree/master/server/google_apis
void main() async {
  initFirestore();
  initServer();
}

void initServer({String address = '0.0.0.0', int port = 8080}) async {
  print("initServer({address: '$address', port: '$port'})");
  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(handleRequest);
  var server = await shelf_io.serve(handler, address, port);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

final _Responses _responses = _Responses();

class _Responses {
  final firestoreIsNull = Response.internalServerError(body: 'firestore is null');
}

FutureOr<Response> handleRequest(Request request) async {
  final path = request.url.path;
  print("handleRequest($path)");

  switch(path){
    case "stripe_event":
      request.readAsString().then(handleStripeEvent);
      // final body = await request.readAsString();
      // await handleStripeEvent(body);
      return Response.ok('');
    case "project":
      final projectId = await currentProjectId();
      return Response.ok('project-id: $projectId');
    case "increment":
      final result = await firestoreApi!.projects.databases.documents.commit(
        _incrementRequest(projectId),
        'projects/$projectId/databases/(default)',
      );
      return Response.ok('Success $result');
    case "users":
      if (firestoreApi == null){
        return _responses.firestoreIsNull;
      }

      // if (request.method == 'POST') {
      //   print("request.method == 'POST'");
      //   final bodyString = await request.readAsString();
      //   if (bodyString.isEmpty){
      //     return Response.forbidden('body is empty');
      //   }
      //   final body = jsonDecoder.convert(bodyString);
      //   if (body is Map == false){
      //     return Response.forbidden('body is not map');
      //   }
      //   final bodyMap = body as Map;
      //
      //   if (!bodyMap.containsKey('id')){
      //     return Response.forbidden('body requires field id');
      //   }
      //   final userId = bodyMap['id'];
      //   // final response = await database.createUser(userId);
      //   return Response.ok(response.toString());
      // }

      final params = request.requestedUri.queryParameters;
      if (!params.containsKey('id')) {
        return Response.forbidden('id required');
      }
      final id = params['id'];
      if (id == null) {
        return Response.forbidden('id is empty');
      }
      if (firestoreApi == null){
        throw Exception("firestore is null");
      }
      final user = await database.findUserById(id);
      if (user == null){
        return Response.notFound("user with id $id could not be found");
      }
      final fields = jsonEncode(user.fields);
      return Response.ok(fields);
    default:
      return Response.notFound('Cannot handle request "${request.url}"');
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

typedef Json = Map<String, dynamic>;

Future handleStripeEvent(String eventString) async {
  print("handleStripeEvent()");

  if (eventString.isEmpty){
    throw Exception('event string is empty');
  }

  final event = jsonDecode(eventString) as Json;
  if (!event.containsKey('type')){
    throw Exception("event object does not contain type");
  }

  final type = event['type'];
  print("event.type: '$type'");

  switch(type){
    case 'checkout.session.completed':
      webhooks.checkoutSessionCompleted(event);
      break;
    default:
      print('no handler for stripe event $type');
      break;
  }
}

// stripe webhook handlers
final webhooks = _StripeWebhooks();

class _StripeWebhooks {
  void checkoutSessionCompleted(Json event){

    if (!event.containsKey('data')){
      throw Exception("event does not contain data");
    }

    final data = event['data'] as Json;

    if (!data.containsKey('object')){
      throw Exception("data does not contain object");
    }

    final obj = data['object'] as Json;

    if (!obj.containsKey('client_reference_id')) {
      throw Exception('Object does not contain client_reference_id');
    }

    final userGameStreamId = obj['client_reference_id'];
    final userStripeId = obj['customer'];
    final email = obj['customer_email'];
    database.createUser(
      userIdGameStream: userGameStreamId,
      userIdStripe: userStripeId,
      email: email,
    );
  }
}


