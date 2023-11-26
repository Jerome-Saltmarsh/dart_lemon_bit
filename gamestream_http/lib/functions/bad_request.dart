

import 'package:gamestream_users/consts/headers.dart';
import 'package:shelf/shelf.dart';

Response badRequest(String body) => Response.badRequest(
    headers: headersAcceptText,
    body: body,
  );

