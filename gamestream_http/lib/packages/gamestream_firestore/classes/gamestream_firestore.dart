
import 'dart:async';
import 'dart:convert';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:uuid/v4.dart';
import 'package:typedef/json.dart';

import '../src.dart';

class GamestreamFirestore {

  final connecting = Completer();
  final uuid = UuidV4();

  late final FirestoreApi firestoreApi;
  late final ProjectsDatabasesDocumentsResource documents;

  GamestreamFirestore(){
    print('GamestreamFirestore()');
    connect();
  }

  String buildDocumentName({
    required String collection
  }) => '$parentName/$collection';

  String buildParentName() => 'projects/$projectId/databases/(default)/documents';

  String getDocumentName({required String collection, required String value}) =>
      '${buildDocumentName(collection: collection)}/$value';

  Future connect() async {
    print('databaseFirestore.connect()');
    final authClient = await auth.clientViaMetadataServer();
    firestoreApi = FirestoreApi(authClient);
    documents = firestoreApi.projects.databases.documents;
    connecting.complete(true);
    print('databaseFirestore.connect() - completed');
  }

  Future<Json> getUser(String id) async {
    final document = await getUserDocument(id);
    return mapUserDocumentToJson(document);
  }

  Future<String> getCharacter(String id) async {

    await ensureConnected();

    final documentName =  getDocumentName(
        collection: 'characters',
        value: id,
    );
    final document = await documents.get(documentName);
    final dataField = document.fields?['data'];
    if (dataField == null){
      throw Exception('getCharacter($id) - exception field "data" is missing');
    }
    return dataField.stringValue ?? (throw Exception('getCharacter($id) - exception field "data" is not a string value'));
  }

  Future<String> createCharacter({
    required String userId,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) async {

    final userDocument = await getUserDocument(userId);

    final userDocumentFields = userDocument.fields;
    if (userDocumentFields == null){
      throw Exception('userDocument.fields == null ($userId)');
    }

    final characters = userDocumentFields['characters'];
    if (characters == null){
      throw Exception('userDocument.fields["characters"] == null ($userId)');
    }

    final arrayValue = characters.arrayValue;
    if (arrayValue == null) {
      throw Exception('arrayValue == null ($userId)');
    }

    final values = arrayValue.values ?? [];
    final characterId = generateUuid();

    values.add(Value(stringValue: jsonEncode({
      'uuid': characterId,
      'name': name,
      'complexion': complexion,
      'hairType': hairType,
      'hairColor': hairColor,
      'gender': gender,
      'headType': headType,
      'equipped_body': 1,
      'level': 1,
    })));

    arrayValue.values = values;
    await patchUserDocument(userDocument);
    return characterId;
  }

  String generateUuid() => uuid.generate();

  Future createDocumentCharacters(Document document, String documentId) async {
    await ensureConnected();
    return documents.createDocument(
      document,
      parentName,
      'characters',
      documentId: documentId,
    );
  }

  Future<void> addCharacterIdToUserDocument(
      Document userDocument,
      String characterId,
  ) async {
    final fields = userDocument.fields;

    if (fields == null){
      throw Exception('addCharacterIdToUserDocument() : fields == null');
    }

    final userDocumentId = fields['documentId']?.stringValue;

    if (userDocumentId == null){
      throw Exception('addCharacterIdToUserDocument() : fields[documentId] is null');
    }

    final characters = fields['characters'];
    var added = false;
    if (characters != null) {
      final arrayValue = characters.arrayValue;
      if (arrayValue != null){
        final values = arrayValue.values;
        if (values != null){
          values.add(Value(stringValue: characterId));
          added = true;
        }
      }
    }

    if (!added) {
      fields['characters'] = Value(
          arrayValue: ArrayValue(
              values: [Value(stringValue: characterId)],
          ),
      );
    }

    userDocument.fields = fields;
    // final userId = userDocument.fields?['documentId']?.stringValue ?? (throw Exception());
    //
    await patchUserDocument(userDocument);
  }

  Future patchUserDocument(Document document) async {
    await ensureConnected();
    await documents.patch(
      document,
      document.name ?? buildDocumentName(collection: 'users'),
    );
  }

  Future<String> createUser({
    required String username,
    required String password,
  }) async {
    await ensureConnected();
    final documentId = generateUuid();
    // final encryptedPassword = sha256.convert(utf8.encode(password));
    // final decryptedPassword = sha256.convert(encryptedPassword.bytes);
    final document = Document();
    document.fields = {
      'documentId': Value(stringValue: documentId),
      'username': Value(stringValue: username),
      'password': Value(stringValue: password),
      'characters': Value(arrayValue: ArrayValue()),
    };
    await documents.createDocument(
      document,
      parentName,
      'users',
      documentId: documentId,
    );

    return documentId;
  }

  Future saveCharacter(String userId, Json characterJson) async {
    print('saveCharacter(userId: $userId)');
    final userDocument = await getUserDocument(userId);
    final fields = userDocument.fields;
    final characterId = characterJson.tryGetString('uuid');

    if (characterId == null){
      throw Exception('characterId == null');
    }

    if (fields == null){
      throw Exception('fields == null');
    }

    final characters = fields['characters'];
    if (characters == null){
      throw Exception('characters == null');
    }

    final arrayValue = characters.arrayValue;
    if (arrayValue == null){
      throw Exception('arrayValue == null');
    }

    final values = arrayValue.values;

    if (values == null){
      throw Exception('values == null');
    }

    for (final character in values) {
      final stringValue = character.stringValue;
      if (stringValue != null && stringValue.contains(characterId)) {
        character.stringValue = jsonEncode(characterJson);
        break;
      }
    }

    await patchUserDocument(userDocument);
  }


  Future<Document> getUserDocument(String userId) async {
    await ensureConnected();
    return documents.get(
        getDocumentName(
          collection: 'users',
          value: userId,
        )
    ).catchError((error){
      print("getUserDocument(userId: $userId) - FAILED");
      throw error;
    });
  }

  
  Future<String?> findUserByUsernamePassword(
      String username,
      String password,
  ) async {
    await ensureConnected();

    final query = RunQueryRequest(
        structuredQuery: StructuredQuery(
            from: [
              CollectionSelector(collectionId: 'users')
            ],
            where: Filter(
                compositeFilter: CompositeFilter(
                  op: 'AND',
                  filters: [
                    Filter(
                      fieldFilter: FieldFilter(
                        field: FieldReference(fieldPath: 'username'),
                        op: 'EQUAL',
                        value: Value(stringValue: username),
                      )
                    ),
                    Filter(
                      fieldFilter: FieldFilter(
                        field: FieldReference(fieldPath: 'password'),
                        op: 'EQUAL',
                        value: Value(stringValue: password),
                      )
                    ),
                  ]
                ),

            )
        )
    );

    final responses = await documents.runQuery(query, parentName);
    for (var response in responses.toList()) {
      final doc = response.document;
      if (doc == null) continue;
      final name = doc.name;
      if (name == null){
        throw Exception('name == null');
      }
      return name.split('/').last;
    }
    return null;
  }

  
  Future<String?> findUserByUsername(String username) async {
    await ensureConnected();

    final query = RunQueryRequest(
        structuredQuery: StructuredQuery(
            from: [
              CollectionSelector(collectionId: 'users')
            ],
            where: Filter(
                fieldFilter: FieldFilter(
                  field: FieldReference(fieldPath: 'username'),
                  op: 'EQUAL',
                  value: Value(stringValue: username),
                )
            )        )
    );

    final responses = await documents.runQuery(query, parentName);
    for (var response in responses.toList()) {
      final doc = response.document;
      if (doc == null) continue;
      final name = doc.name;
      if (name == null){
        throw Exception('name == null');
      }
      return name.split('/').last;
    }
    return null;
  }

  
  Future deleteCharacter({
    required String userId,
    required String characterId,
  }) async {
    await ensureConnected();

    final userDocument = await getUserDocument(userId);
    final userJson = mapUserDocumentToJson(userDocument) ;
    final userFieldCharacters = userDocument.getFieldArray('characters');

    if (userFieldCharacters == null){
      throw Exception('userCharacters == null');
    }

    final characterJsons = userJson.getList<Json>('characters');
    characterJsons.removeWhere((element) => element['uuid'] == characterId);

    final characterStrings2 = characterJsons
        .map(jsonEncode)
        .toList(growable: false);

    userFieldCharacters.values = characterStrings2
        .map((e) => Value(stringValue: e))
        .toList(growable: false);

    await patchUserDocument(userDocument);
  }

  Future ensureConnected() async {
    if (!connecting.isCompleted) {
      await connecting;
    }
  }

  
  Future setCharacterLocked({required String userId, required String characterId, required bool locked}) {
    // TODO: implement setCharacterLocked
    throw UnimplementedError();
  }
}

