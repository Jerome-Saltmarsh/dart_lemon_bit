import 'package:gamestream_users/database/classes/database.dart';
import 'package:gamestream_users/http/consts/headers.dart';
import 'package:shelf/shelf.dart';

import 'handle_request_get.dart';
import 'handle_request_options.dart';
import 'handle_request_patch.dart';
import 'handle_request_post.dart';



Future<Response> handleRequest({
  required Database database,
  required Request request
}) async {

  switch (request.method) {
    case 'GET':
      return handleRequestGet(request, database);
    case 'PATCH':
      return handleRequestPatch(request, database);
    case 'POST':
      return handleRequestPost(request, database);
    case 'OPTIONS':
      return handleRequestOptions();
    default:
      return Response.badRequest(
        headers: headersAcceptText,
        body: 'invalid request.method: ${request.method}',
      );
  }
}






