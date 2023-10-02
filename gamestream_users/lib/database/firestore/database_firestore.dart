
import 'dart:async';
import 'dart:convert';

import 'package:gamestream_users/database/firestore/functions/map_user_document_to_json.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:typedef/json.dart';
import 'package:uuid/v4.dart';

import '../classes/database.dart';
import 'consts/parent_name.dart';
import 'consts/project_id.dart';

class DatabaseFirestore implements Database {

  final connecting = Completer();
  final uuid = UuidV4();

  late final FirestoreApi firestoreApi;
  late final ProjectsDatabasesDocumentsResource documents;

  DatabaseFirestore(){
    print('DatabaseFirestore()');
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

  @override
  Future<Json> getUser(String id) async {
    final document = await getUserDocument(id);
    return mapUserDocumentToJson(document);
  }

  @override
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
      'level': 1,
    })));

    arrayValue.values = values;

    await patchUserDocument(userDocument, userId);
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
    final userId = userDocument.fields?['documentId']?.stringValue ?? (throw Exception());

    await patchUserDocument(userDocument, userId);
  }

  Future patchUserDocument(Document document, String documentId) async {
    await ensureConnected();
    documents.patch(
        document,
        getDocumentName(collection: 'users', value: documentId),
    );
  }

  @override
  Future<String> createUser({
    required String username,
    required String password,
  }) async {

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

  @override
  Future saveCharacter(String userId, Json characterJson) async {
    print('saveCharacter(userId: $userId)');
    final userDocument = await getUserDocument(userId);
    print('userFound: $userId');
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

    print("patching");
    await documents.patch(userDocument, userDocument.name ?? buildDocumentName(collection: 'users'));
    print("patching complete");
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

  Future ensureConnected() async {
    if (!connecting.isCompleted) {
      await connecting;
    }
  }

  @override
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
}

