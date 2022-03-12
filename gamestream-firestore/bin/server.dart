
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:gamestream_firestore/firestore.dart';
import 'package:gamestream_firestore/stripe.dart';
import 'package:typedef/json.dart';

import 'package:googleapis/firestore/v1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io' show Platform;

const version = 1;
final devMode = Platform.localHostname == "Jerome";

// gcloud builds submit --tag gcr.io/gogameserver/gamestream-firestore
// https://stripe.com/docs/webhooks
void main() async {
  if (!devMode){
    print("production mode detected: starting firestore service");
    firestore.init();
  }
  initServer();
}

void initServer({String address = '0.0.0.0', int port = 8080}) async {
  var handler = const Pipeline()
      // .addMiddleware(logRequests())
      .addHandler(handleRequest);
  var server = await shelf_io.serve(handler, address, port);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

FutureOr<Response> handleRequest(Request request) async {
  final path = request.url.path;
  final params = request.requestedUri.queryParameters;
  final Json response = Json();

  // https://stackoverflow.com/questions/43871637/no-access-control-allow-origin-header-is-present-on-the-requested-resource-whe
  if (request.method == 'OPTIONS'){
    return Response.ok("", headers: {
      "Access-Control-Allow-Origin": "*",
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
    });
  }

  switch(path) {
    case 'maps':
      if (request.method == "GET"){
        print("(server) maps.get");
        final mapId = params['id'];
        if (mapId == null){
          final ids = await firestore.getMapIds();
          return ok(ids);
        }
        final results = await firestore.findMapById(mapId);
        if (results == null){
          return notFound('no map could be found with id $mapId');
        }
        final fields = results.fields;
        if (fields == null){
          return internalServerError('map $mapId does not have any fields');
        }
        final data = fields['data'];
        if (data == null){
          return internalServerError("map $mapId does not have a 'data' field");
        }
        final dataString = data.stringValue;
        if (dataString == null){
          return internalServerError("map $mapId data field is not of type string");
        }
        return Response.ok(dataString, headers: headersJson);
      }

      if (request.method == "POST"){
        print("(server) maps.post");
        final mapId = params['id'];
        if (mapId == null){
          return notFound("id_required");
        }
        request.readAsString().then((data) async {
          final existingMap = await firestore.findMapById(mapId);
          if (existingMap == null){
            firestore.createMap(mapId: mapId, data: data);
          } else {
            firestore.patchMap(document: existingMap, data: data);
          }
        });
      }
      return ok(response);

    case 'version':
      response['version'] = version;
      return ok(response);

    case 'subscriptions':
      final subscriptionId = params['id'];
      if (subscriptionId == null) {
        return error(response, 'id is null');
      }
      final subscription = await stripeApi.getSubscription(subscriptionId);
      return ok(subscription);

    case "characters":
      if (request.method == "POST"){
        print("Saving Character()");
        request.readAsString().then((data) async {
          final json = jsonDecode(data) as Json;
          final id = json['id'];
          final x = json.getDouble('x');
          final y = json.getDouble('y');
          print("Saving Character (id: $id, x: $x, y: $y)");
        });
      }

      return ok('success');

    case "users":

      final id = params['id'];
      if (id == null) {
        return notFound('param_required__id');
      }

      if (request.method == 'POST'){
        return _createUser(response, params, id);
      }

      response['id'] = id;
      final userDocument = await firestore.findUserById(id);

      if (userDocument == null){
        return notFound('no_user_found');
      }

      final method = params['method']?.toUpperCase();

      if (method == null) {
        return await mapUserDocumentToResponse(userDocument, response);
      }

      switch(method){
        case 'CANCEL_SUBSCRIPTION':
          return await _cancelSubscription(userDocument, response);

        case 'CHANGE_PUBLIC_NAME':
          var publicName = params[fieldNames.public_name];
          if (publicName == null){
            return errorFieldMissing(response, fieldNames.public_name);
          }
          return await changePublicName(userId: id, publicName: publicName);

        case 'GET_SUBSCRIPTION':
          final fields = userDocument.fields;
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

Future<Response> mapUserDocumentToResponse(Document user, Json response) async {

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

Future<Response> changePublicName({
  required String userId,
  required String publicName
}) async {
  publicName = publicName.trim().replaceAll(" ", "_");
  print("server.changePublicName($publicName)");

  if (publicName.length < 8){
    return buildError('too_short');
  }

  if (publicName.length > 15){
    return buildError('too_long');
  }

  final existing = await firestore.findUserByPublicName(publicName);
  if (existing != null){
    final existingName = existing.name;

    if (existingName != null){
       final segments = existingName.split("/");
       final existingUserId = segments.last;
       if (existingUserId == userId){
         return buildError('same_value');
       }
    }

    print("$publicName already taken");
    return buildError('taken');
  }

  print("No existing user with name $publicName found, continuing to patch");

  await firestore.patchPublicName(userId: userId, publicName: publicName);
  return ok({
    'status': 'success'
  });
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
}

bool isExpired(DateTime value){
  return DateTime.now().toUtc().isAfter(value);
}

Response ok(response){
  return Response.ok(jsonEncode(response), headers: headersJson);
}

Response internalServerError(String message){
  return Response.internalServerError(body: message, headers: headersJson);
}

Response notFound(String message){
  return Response.notFound(message, headers: headersTextPlain);
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

final headersJson = (){
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'application/json';
  _headers['Access-Control-Allow-Headers'] = "*";
  _headers['Access-Control-Allow-Origin'] = "*";
  _headers['Access-Control-Allow-Methods'] = 'POST,GET,DELETE,PUT,OPTIONS';
  return _headers;
}();

final headersTextPlain = (){
  final Map<String, Object> _headers = {};
  _headers['Content-Type'] = 'text/plain';
  _headers['Access-Control-Allow-Headers'] = "*";
  _headers['Access-Control-Allow-Origin'] = "*";
  _headers['Access-Control-Allow-Methods'] = 'POST,GET,DELETE,PUT,OPTIONS';
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