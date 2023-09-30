import 'package:gamestream_users/database/classes/database.dart';
import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

import '../../utils/get_body.dart';
import '../consts/headers.dart';

Future<Response> handleRequestPost(Request request, Database database) async {
  final requestBody = await getBody(request);

  final userId = requestBody.tryGetString('userId');
  final name = requestBody.tryGetString('name');
  final complexion = requestBody.tryGetInt('complexion');
  final hairType = requestBody.tryGetInt('hairType');
  final hairColor = requestBody.tryGetInt('hairColor');
  final headType = requestBody.tryGetInt('headType');
  final gender = requestBody.tryGetInt('gender');

  if (
  userId == null ||
      name == null ||
      complexion == null ||
      hairType == null ||
      headType == null ||
      gender == null ||
      hairColor == null
  ){
    return Response.badRequest();
  }

  if (name.isEmpty){
    return Response.badRequest(
      headers: headersAcceptText,
      body: 'Name Required',
    );
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
