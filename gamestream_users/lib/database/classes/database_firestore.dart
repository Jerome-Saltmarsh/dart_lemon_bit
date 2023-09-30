
import 'dart:async';
import 'dart:convert';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:typedef/json.dart';
import 'package:uuid/v4.dart';

import 'database.dart';

class DatabaseFirestore implements Database {

  static const collectionId = "highscore";
  static const projectId = "gogameserver";
  static const parentName = 'projects/$projectId/databases/(default)/documents';

  late final FirestoreApi firestoreApi;
  late final ProjectsDatabasesDocumentsResource documents;


  DatabaseFirestore(){
    print('DatabaseFirestore()');
  }

  final uuid = UuidV4();

  Future<Document> get documentRecord =>  documents.get(
      getDocumentName(collection: collectionId, value: 'record')
  );

  Future<Document> getUserDocument(String userId) {
    return documents.get(
        getDocumentName(
            collection: 'users',
            value: userId,
        )
    );
  }

  String buildDocumentName({
    required String collection
  }) => '$parentName/$collection';

  String buildParentName() => 'projects/$projectId/databases/(default)/documents';

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
      '${buildDocumentName(collection: collection)}/$value';

  @override
  Future connect() async {
    final authClient = await auth.clientViaMetadataServer();
    firestoreApi = FirestoreApi(authClient);
    documents = firestoreApi.projects.databases.documents;
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
  Future<List<Json>> getUser(String userId) async {
    return [];
  }

  @override
  Future<Json> getCharacter(String characterId) {
    // TODO: implement getCharacter
    throw UnimplementedError();
  }

  @override
  Future<String> createCharacter({
    required String userId,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) async {

    final document = Document();
    document.name = uuid.generate();
    document.fields = {
      'data': Value(stringValue: jsonEncode({
        'userId': userId,
        'name': name,
        'complexion': complexion,
        'hairType': hairType,
        'hairColor': hairColor,
        'gender': gender,
        'headType': headType,
      })),
       // 'userId': Value(stringValue: userId),
       // 'name': Value(stringValue: userId),
       // 'complexion': Value(integerValue: complexion.toString()),
       // 'hairType': Value(integerValue: hairType.toString()),
       // 'hairColor': Value(integerValue: hairColor.toString()),
       // 'gender': Value(integerValue: gender.toString()),
       // 'headType': Value(integerValue: headType.toString()),
    };
    await documents.createDocument(document, parentName, 'characters');
    return document.name ?? (throw Exception('name is null'));
  }

  @override
  Future saveCharacter(Json json) async {
    final document = Document();
    document.name = uuid.generate();
    document.fields = {
      'data': Value(stringValue: jsonEncode(json)),
    };
    await documents.patch(document, buildDocumentName(collection: 'characters'));
  }
}
