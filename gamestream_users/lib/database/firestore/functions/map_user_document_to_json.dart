
import 'package:gamestream_users/database/firestore/extensions/document_extensions.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:typedef/json.dart';

import 'get_characters_json_from_user_document.dart';


Json mapUserDocumentToJson(Document document) => {
    'username' : document.getFieldString('username'),
    'characters': getCharactersJsonFromUserDocument(document)
};



