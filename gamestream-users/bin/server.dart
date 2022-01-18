
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:typedef/json.dart';

import 'package:gamestream_users/firestore.dart';
import 'package:gamestream_users/stripe.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io' show Platform;


final devMode = Platform.localHostname == "Jerome";

// gcloud builds submit --tag gcr.io/gogameserver/rest-server
// https://stripe.com/docs/webhooks
void main() async {
  if (!devMode){
    print("production mode detected: starting firestore service");
    firestore.init();
  }
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
    case 'subscriptions':
      final params = request.requestedUri.queryParameters;
      final subscriptionId = params['id'];
      if (subscriptionId == null) {
        return error(response, 'id is null');
      }
      final subscription = await stripeApi.getSubscription(subscriptionId);
      return ok(subscription);

    case "users":
      final params = request.requestedUri.queryParameters;
      final method = params['method']?.toUpperCase();
      if (method == null){
        return error(response, 'method_required');
      }

      if (method == 'FIND'){
        return _findUser(response);
      }

      final id = params['id'];
      if (id == null) {
        return error(response, 'id_required');
      }

      if (method == 'POST'){
        return _createUser(response, params, id);
      }

      response['id'] = id;
      final user = await firestore.findUserById(id);


      if (user == null){
        return error(response, 'not_found');
      }

      switch(method){
        case 'CANCEL_SUBSCRIPTION':
          return await _cancelSubscription(user, response);

        case 'CHANGE_PUBLIC_NAME':
          var publicName = params[fieldNames.public_name];
          if (publicName == null){
            return errorFieldMissing(response, fieldNames.public_name);
          }
          return await _changePublicName(userId: id, publicName: publicName);

        case 'GET_SUBSCRIPTION':
          final fields = user.fields;
          if (fields == null) {
            throw Exception('user fields are null');
          }
          if (fields.isEmpty) {
            throw Exception('user fields are empty');
          }

          final subscriptionIdField = fields[fieldNames.subscriptionId];
          if (subscriptionIdField == null) {
            response[fieldNames.subscriptionStatus] = 'not_subscribed';
            return ok(response);
          }
          final subscriptionId = subscriptionIdField.stringValue;
          if (subscriptionId == null){
            throw Exception('subscription_id is not a string value');
          }

          final subscription = await stripeApi.getSubscription(subscriptionId);
          return ok(subscription);

        case 'GET':
          return await _getUser(user, response);

        default:
          return error(response, "unknown_method");
      }

    default:
      return error(response, 'unknown_endpoint');
  }
}

Future<Response> _createUser(Json response, Map<String, String> params, String id) async {

  final user = await firestore.findUserById(id);

  if (user != null){
    return error(response, 'already_exists');
  }

  final email = params[fieldNames.email];

  if (email == null){
    return errorFieldMissing(response, fieldNames.email);
  }

  final publicName = generateRandomName();
  final privateName = params[fieldNames.private_name] ?? publicName;
  final newUser = await firestore.createUser(
    userId: id,
    email: email,
    privateName: privateName,
    publicName: publicName,
  );
  return ok(newUser);
}

Future<Response> _getUser(Document user, Json response) async {

  final fields = user.fields;

  if (fields == null) {
    return error(response, 'fields_null');
  }

  if (fields.isEmpty) {
    return error(response, 'fields_empty');
  }

  final subscriptionIdField = fields[fieldNames.subscriptionId];

  if (subscriptionIdField == null){
    response[fieldNames.subscriptionStatus] = 'not_subscribed';
  } else {
    final subscriptionId = subscriptionIdField.stringValue;
    if (subscriptionId == null) {
      return error(response, "subscription_id_not_string");
    }
    final subscriptionString = await stripeApi.getSubscription(subscriptionId);
    final subscription = jsonDecode(subscriptionString);
    final status = subscription['status'];
    if (status == null){
      throw Exception("subscription.status is null");
    }

    response[fieldNames.subscriptionStatus] = status;
    response[fieldNames.subscriptionLiveMode] = subscription['livemode'];
    response[fieldNames.subscriptionCurrentPeriodStart] = subscription['current_period_start'];
    response[fieldNames.subscriptionCurrentPeriodEnd] = subscription['current_period_end'];
    response[fieldNames.subscriptionStartDate] = subscription['start_date'];

    final endedAt = subscription[fieldNames.subscriptionEndedAt];
    if (endedAt != null){
      response[fieldNames.subscriptionEndedAt] = endedAt;
    }
  }

  final email = fields[fieldNames.email];
  if (email != null) {
    response[fieldNames.email] = email.stringValue;
  }

  final publicName = fields[fieldNames.public_name];
  if (publicName != null) {
    response[fieldNames.public_name] = publicName.stringValue;
  }

  final privateName = fields[fieldNames.private_name];
  if (privateName != null) {
    response[fieldNames.private_name] = privateName.stringValue;
  }

  final accountCreationDate = fields[fieldNames.account_creation_date];
  if (accountCreationDate != null) {
    response[fieldNames.account_creation_date] =
        accountCreationDate.timestampValue;
  }

  return ok(response);
}

Future<Response> _changePublicName({
  required String userId,
  required String publicName
}) async {

  publicName = publicName.trim();
  publicName = publicName.replaceAll(" ", "_");

  if (publicName.length < 4){
    return buildError('display_name_too_short');
  }

  final existing = await firestore.findUser(displayName: publicName);
  if (existing != null){
    return buildError('display_name_already_taken');
  }

  await firestore.patchDisplayName(userId: userId, displayName: publicName);
  return ok({
    'status': 'success'
  });
}

Response _findUser(Json response) {
  return error(response, 'disabled');
  // print("(server) handling find request");
  // final displayName = params[fieldNames.displayName];
  // if (displayName == null){
  //   return error(response, 'display_name_required');
  // }
  // final result = await firestore.findUser(displayName: displayName);
  // if (result == null){
  //   return error(response, 'not_found');
  // }
  // return ok(result.fields);
}

Future<Response> _cancelSubscription(Document user, Json response) async {

  final fields = user.fields;
  if (fields == null){
    return error(response, 'fields_null');
  }

  final subscriptionIdField = fields[fieldNames.subscriptionId];
  if (subscriptionIdField == null) {
    return error(response, "user_not_subscribed");
  }

  final subscriptionId = subscriptionIdField.stringValue;
  if (subscriptionId == null){
    return error(response, "subscription_id_not_string");
  }

  final deleteResponse = await stripeApi.deleteSubscription(subscriptionId);
  return ok(deleteResponse.body);
  // final subscription = await stripe.subscription.get(subscriptionId);
  // subscription.status;
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

Response buildError(String error){
  return Response.ok(jsonEncode({'error': error}), headers: headersJson);
}

Response errorFieldMissing(response, String fieldName){
  response['error'] = error;
  response['fieldName'] = fieldName;
  return error(response, 'field_missing');
}

// typedef Json = Map<String, dynamic>;

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


// Generate name serve
final _random = Random();

String generateRandomName(){
  return 'Player_${100000 + _random.nextInt(999999999)}';
}


String formatDate(DateTime date){
  return date.toUtc().toIso8601String();
}