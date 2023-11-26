import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../control/classes/authentication.dart';


bool _initialized = false;

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

const _apiKey = 'AIzaSyBvLdB53px2cU4_5QvQQLPRz18y-MvsLJE';
const _appId = '1:351101922003:web:82ec8f4a98667c31a58226';
const _messagingSenderId = '351101922003';
const _projectid = 'zombie-survivor-24bf1';

Future _initFirebaseApp() async {
  if (_initialized) return;
  _initialized = true;
  return Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: _apiKey,
          appId: _appId,
          messagingSenderId: _messagingSenderId,
          projectId: _projectid,
      )
  );
}

Future<Authentication> getGoogleAuthentication() async {
  print("signInWithGoogle()");
  await _initFirebaseApp();

  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount == null) throw Exception("googleSignInAccount == null");

  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final credentials = await firebaseAuth.signInWithCredential(credential).catchError((error){
    print(error);
  });

  final user = credentials.user;
  if (user == null){
    throw Exception('credentials.user is null');
  }

  final displayName = user.displayName;
  if (displayName == null){
    throw Exception("user.displayName is null");
  }

  final email = user.email;
  if (email == null){
    throw Exception("user.email is null");
  }
  return Authentication(
      userId: user.uid,
      name: displayName,
      email: email,
  );
}


//
// Future<String> registerWithEmailPassword(String email, String password) async {
//   // Initialize Firebase
//   await Firebase.initializeApp();
//
//   final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
//     email: email,
//     password: password,
//   );
//
//   final User? user = userCredential.user;
//
//   if (user != null) {
//     // checking if uid or email is null
//     assert(user.uid != null);
//     assert(user.email != null);
//
//     uid = user.uid;
//     userEmail = user.email!;
//
//     assert(!user.isAnonymous);
//     assert(await user.getIdToken() != null);
//
//     return 'Successfully registered, User UID: ${user.uid}';
//   }
//
//   throw Exception();
// }
//
// Future<String> signInWithEmailPassword(String email, String password) async {
//   // Initialize Firebase
//   await Firebase.initializeApp();
//
//   final UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
//     email: email,
//     password: password,
//   );
//
//   final User? user = userCredential.user;
//
//   if (user == null){
//     throw Exception();
//   }
//
//   // checking if uid or email is null
//   assert(user.uid != null);
//   assert(user.email != null);
//
//   uid = user.uid;
//   userEmail = user.email!;
//
//   assert(!user.isAnonymous);
//   assert(await user.getIdToken() != null);
//
//   final User currentUser = firebaseAuth.currentUser!;
//   assert(user.uid == currentUser.uid);
//
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setBool('auth', true);
//
//   return 'Successfully logged in, User UID: ${user.uid}';
// }
