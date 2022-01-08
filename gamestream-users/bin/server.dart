
import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../firestore/firestore.dart';

// gcloud builds submit --tag gcr.io/gogameserver/rest-server
// https://stripe.com/docs/webhooks
void main() async {
  firestore.init();
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

FutureOr<Response> handleRequest(Request request) async {
  final path = request.url.path;
  print("handleRequest($path)");
  switch(path){
    case "hello":
      return Response.ok('world', headers: headersTextPlain);
    case "stripe_event":
      request.readAsString().then(handleStripeEvent);
      return Response.ok('', headers: headersTextPlain);
    case "users":
      final params = request.requestedUri.queryParameters;
      if (!params.containsKey('id')) {
        return Response.forbidden('id required', headers: headersTextPlain);
      }
      final id = params['id'];
      if (id == null) {
        return Response.forbidden('id is empty', headers: headersTextPlain);
      }
      final user = await firestore.findUserById(id);
      final Json response = Json();
      if (user == null){
        response['status'] = 'error';
        response['message'] = 'user with id $id could not be found';
        return ok(response);
      }
      final fields = user.fields;

      if (fields == null){
        response['status'] = 'error';
        response['message'] = 'user with id $id was found however had no fields';
        return ok(response);
      }

      final subExp = fields['sub_exp'];
      if (subExp == null){
        response['status'] = 'error';
        response['message'] = 'user with id $id was found does not have a sub_exp field';
        return ok(response);
      }

      response['sub_exp'] = subExp.timestampValue;
      response['status'] = 'success';
      return ok(response);
    default:
      return Response.notFound('Cannot handle request "${request.url}"', headers: headersTextPlain);
  }
}

Response ok(response){
  return Response.ok(jsonEncode(response), headers: headersJson);
}

typedef Json = Map<String, dynamic>;

Map<String, Object> get headersJson {
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'application/json';
  _headers['Access-Control-Allow-Headers'] = "Access-Control-Allow-Origin, Accept";
  _headers['Access-Control-Allow-Origin'] = "*";
  return _headers;
}

Map<String, Object> get headersTextPlain {
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'text/plain';
  _headers['Access-Control-Allow-Headers'] = "Access-Control-Allow-Origin, Accept";
  _headers['Access-Control-Allow-Origin'] = "*";
  return _headers;
}


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
    print("stripe.checkoutSessionCompleted()");

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
    firestore.createUser(
      userIdGameStream: userGameStreamId,
      userIdStripe: userStripeId,
      email: email,
    );
  }
}


