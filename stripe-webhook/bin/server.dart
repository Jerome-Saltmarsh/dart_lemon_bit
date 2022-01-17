
import 'dart:async';
import 'dart:convert';

import 'package:gamestream_stripe_webhook/firestore.dart';
import 'package:gamestream_stripe_webhook/stripe.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;


// gcloud builds submit --tag gcr.io/gogameserver/gamestream-stripe-webhook
// https://stripe.com/docs/webhooks
void main() async {
  firestore.init();
  initServer();
}

void initServer({String address = '0.0.0.0', int port = 8080}) async {
  print("initServer({address: '$address', port: '$port'})");
  var handler = const Pipeline()
      // .addMiddleware(logRequests())
      .addHandler(handleRequest);
  var server = await shelf_io.serve(handler, address, port);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

FutureOr<Response> handleRequest(Request request) async {
  request.readAsString().then(handleStripeEvent);
  return Response.ok('', headers: headersTextPlain);
}

typedef Json = Map<String, dynamic>;


final headersTextPlain = (){
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'text/plain';
  _headers['Access-Control-Allow-Headers'] = "Access-Control-Allow-Origin, Accept";
  _headers['Access-Control-Allow-Origin'] = "*";
  return _headers;
}();


Future handleStripeEvent(String eventString) async {
  if (eventString.isEmpty){
    throw Exception('event string is empty');
  }
  final event = jsonDecode(eventString) as Json;
  webhooks.handleEvent(event);
}


