import 'package:gamestream_users/database/classes/database.dart';
import 'package:gamestream_users/http/functions/bad_request.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

import '../../utils/get_body.dart';
import '../consts/headers.dart';

Future<Response> handleRequestPostCharacter(Request request, Database database) async {
  final requestBody = await getBody(request);
  final userId = requestBody.tryGetString('userId');
  final name = requestBody.tryGetString('name');
  final complexion = requestBody.tryGetInt('complexion');
  final hairType = requestBody.tryGetInt('hairType');
  final hairColor = requestBody.tryGetInt('hairColor');
  final headType = requestBody.tryGetInt('headType');
  final gender = requestBody.tryGetInt('gender');

  if (userId == null) {
    return badRequest('userId_required');
  }

  if (name == null) {
    return badRequest('name_required');
  }

  if (complexion == null) {
    return badRequest('complexion_required');
  }

  if (hairType == null) {
    return badRequest('hairType_required');
  }

  if (headType == null) {
    return badRequest('headType_required');
  }

  if (gender == null) {
    return badRequest('gender_required');
  }

  if (hairColor == null) {
    return badRequest('hairColor_required');
  }

  if (name.isEmpty) {
    return badRequest('invalid_name');
  }

  final characterId = await database.createCharacter(
    userId: userId,
    name: name,
    complexion: complexion,
    hairType: hairType,
    hairColor: hairColor,
    headType: headType,
    gender: gender,
  );

  return Response(
    200,
    headers: headersAcceptText,
    body: characterId,
  );
}
