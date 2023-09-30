import 'package:gamestream_users/http/consts/headers.dart';
import 'package:shelf/shelf.dart';

Future<Response> handleRequestOptions() async {
  return Response(
      200,
      headers: headersAcceptJson
  );
}
