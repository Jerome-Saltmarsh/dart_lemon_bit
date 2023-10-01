

import 'package:gamestream_users/http/consts/headers.dart';
import 'package:shelf/shelf.dart';

Response badRequest(String body) => Response.badRequest(
    headers: headersAcceptText,
    body: body,
  );

