
import 'dart:async';
import 'dart:convert';

import 'package:gamestream_users/firestore.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;


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
  print("handleRequest(path: '$path', method: '${request.method}', host: '${request.url.host}')");
  final Json response = Json();


  switch(path){

    case 'hello':
      return Response.ok('world', headers: headersTextPlain);

      case "stripe_event":
      request.readAsString().then(handleStripeEvent);
      return Response.ok('', headers: headersTextPlain);

      case "users":
      final params = request.requestedUri.queryParameters;

      final method = params['method']?.toUpperCase();
      if (method == null){
        return error(response, 'method_required');
      }

      if (method == 'FIND'){
        print("(server) handling find request");
        final displayName = params[fieldNames.displayName];
        if (displayName == null){
          return error(response, 'display_name_required');
        }
        final result = await firestore.findUser(displayName: displayName);
        if (result == null){
          return error(response, 'not_found');
        }
        return ok(result.fields);
      }


      final id = params['id'];
      if (id == null) {
        return error(response, 'id_required');
      }

      response['id'] = id;
      final user = await firestore.findUserById(id);

      if (request.method == 'PATCH'){

        var displayName = params[fieldNames.displayName];

        if (displayName == null){
          response['fieldName'] = 'display_name';
          return error(response, 'field_missing');
        }

        displayName = displayName.trim();
        displayName = displayName.replaceAll(" ", "_");

        if (displayName.length < 4){
          return error(response, 'display_name_too_short');
        }

        await firestore.patchDisplayName(userId: id, displayName: displayName);
        response['status'] = 'success';
        response['request'] = 'patch';
        response['field'] = 'display_name';
        response['value'] = displayName;
        return ok(response);
      }

      if (method == "GET"){

        if (user == null){
          return error(response, 'not_found');
        }

        final fields = user.fields;

        if (fields == null){
          return error(response, 'fields_null');
        }

        if (fields.isEmpty){
          return error(response, 'fields_empty');
        }

        final displayName = fields[fieldNames.displayName];
        if (displayName != null){
          response[fieldNames.displayName] = displayName.stringValue;
        }

        final subscriptionExpires = fields[fieldNames.subscriptionExpirationDate];
        if (subscriptionExpires == null){
          response[fieldNames.subscriptionStatus] = 'not_subscribed';
          return ok(response);
        }

        final timestampValue = subscriptionExpires.timestampValue;
        if (timestampValue == null) {
          return error(response, 'subscription_expiration_timestamp_is_null');
        }

        response[fieldNames.subscriptionExpirationDate] = timestampValue;

        final date = DateTime.tryParse(timestampValue);
        if (date == null) {
          return error(response, 'subscription_timestamp_parse_error');
        }

        response[fieldNames.subscriptionStatus] = isExpired(date) ? 'expired' : 'active';
        return ok(response);
      } // GET

      if (method == "POST"){

        if (user != null){
          return error(response, 'already_exists');
        }

        final email = params['email'];

        if (email == null){
          error(response, 'email_required');
        }

        final newUser = await firestore.createUser(
            userId: id,
            email: email,
            displayName: generateRandomName()
        );

        return ok(newUser);
      } // POST
      break;

    default:
      break;
  }

  return Response.notFound("Cannot handle request: {url: '${request.url}', method: '${request.method}'}", headers: headersTextPlain);
}

bool isExpired(DateTime value){
  return DateTime.now().toUtc().isAfter(value);
}

Response ok(response){
  return Response.ok(jsonEncode(response), headers: headersJson);
}

Response error(response, String error){
  response['error'] = error;
  return Response.ok(jsonEncode(response), headers: headersJson);
}

typedef Json = Map<String, dynamic>;

final headersJson = (){
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'application/json';
  _headers['Access-Control-Allow-Headers'] = "Access-Control-Allow-Origin, Accept";
  _headers['Access-Control-Allow-Origin'] = "*";
  return _headers;
}();

final headersTextPlain = (){
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'text/plain';
  _headers['Access-Control-Allow-Headers'] = "Access-Control-Allow-Origin, Accept";
  _headers['Access-Control-Allow-Origin'] = "*";
  return _headers;
}();


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

    final userId = obj['client_reference_id'];
    final stripeCustomerId = obj['customer'];
    final stripePaymentEmail = obj['customer_email'];

    firestore.subscribe(
        userId: userId,
        stripeCustomerId: stripeCustomerId,
        stripePaymentEmail: stripePaymentEmail
    );
  }
}

