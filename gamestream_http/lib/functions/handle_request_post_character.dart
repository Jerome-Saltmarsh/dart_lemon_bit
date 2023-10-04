import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

import '../../utils/get_body.dart';
import '../consts/headers.dart';
import 'bad_request.dart';

Future<Response> handleRequestPostCharacter(Request request, GamestreamFirestore database) async {
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
