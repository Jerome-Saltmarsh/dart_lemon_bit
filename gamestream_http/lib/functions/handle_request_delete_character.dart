
import 'package:gamestream_users/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:typedef/json.dart';
import 'package:gamestream_users/utils/get_body.dart';
import 'package:shelf/shelf.dart';

import 'bad_request.dart';

Future<Response> handleRequestDeleteCharacter(
    Request request, 
    GamestreamFirestore database,
) async {
  
  final requestJson = await getBody(request);
  final userId = requestJson.tryGetString('userId');
  final characterId = requestJson.tryGetString('characterId');
  
  if (userId == null) {
    return badRequest('userId required');
  }
  
  if (characterId == null){
    return badRequest('characterId required');
  }
  await database.deleteCharacter(
    userId: userId,
    characterId: characterId,
  );
  return Response(204);
}