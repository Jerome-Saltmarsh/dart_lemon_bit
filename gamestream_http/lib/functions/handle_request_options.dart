import 'package:gamestream_users/consts/headers.dart';
import 'package:shelf/shelf.dart';

Future<Response> handleRequestOptions() async {
  return Response(
      200,
      headers: headersAcceptJson
  );
}
