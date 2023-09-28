
import 'dart:async';

import 'package:gamestream_server/database/classes/database.dart';
import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:typedef/json.dart';

class DatabaseFirestore implements Database {

  static const projectId = "gogameserver";
  static const collectionId = "highscore";
  late final FirestoreApi firestoreApi;

  ProjectsDatabasesDocumentsResource get documents => firestoreApi.projects.databases.documents;

  Future<Document> get documentRecord =>  documents.get(
      getDocumentName(collection: collectionId, value: 'record')
  );

  String buildDocumentName({
    required String projectId,
    required String collection
  }) => '${buildParentName(projectId: projectId)}/$collection';

  String buildParentName({
    required String projectId,
  }) => 'projects/$projectId/databases/(default)/documents';

  @override
  Future<int> getHighScore() async {
    final documentHighScore = await documentRecord;
    final fields = documentHighScore.fields;
    if (fields == null) throw Exception('documentHighScore.fields is null');
    final entryScore = fields['score'];
    if (entryScore == null) throw Exception('entryScore is null');
    final entryScoreValue = entryScore.integerValue;
    if (entryScoreValue == null) throw Exception('entryScoreValue is null');
    return int.parse(entryScoreValue);
  }

  String getDocumentName({required String collection, required String value}) =>
      '${buildDocumentName(projectId: projectId, collection: collection)}/$value';

  @override
  Future connect() async {
    final authClient = await auth.clientViaMetadataServer();
    firestoreApi = FirestoreApi(authClient);
    print ('firestoreApi connected');
  }

  @override
  Future writeHighScore(int value) async {
    print("writeHighScore($value");
    final document = await documentRecord;
    final documentFields = document.fields;
    if (documentFields == null) throw Exception('documentFields == null');
    documentFields['score'] = Value(integerValue: value.toString());
    await documents.patch(document, document.name!);
  }

  @override
  void persist(IsometricPlayer player) {
    // TODO: implement persist
  }

  @override
  Future<List<Json>> getUserCharacters(String userId) async {
    return [];
  }

  @override
  Future<Json> getCharacter(String characterId) {
    // TODO: implement getCharacter
    throw UnimplementedError();
  }
}
