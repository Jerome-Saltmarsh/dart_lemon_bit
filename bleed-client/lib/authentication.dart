import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lemon_watch/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

// final Watch<UserCredential?> userCredentials = Watch(null);

final Watch<Authorization?> authorization = Watch(null);

// User? get user => userCredentials.value?.user;

bool get authenticated => authorization != null;

// String? name = "";
// String? imageUrl = "";
final FirebaseAuth _auth = FirebaseAuth.instance;


// void signInWithJwtToken(String jwtToken) async {
//   print('signInWithJwtToken()');
//   final credentials = await _auth.signInWithCustomToken(jwtToken).catchError((error){
//     print("failed to create credentials with jwt token");
//     throw error;
//   });
//   print("user credentials created");
//   userCredentials.value = credentials;
// }

String? uid = "";
String? userEmail = "";

Future<String> registerWithEmailPassword(String email, String password) async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final User? user = userCredential.user;

  if (user != null) {
    // checking if uid or email is null
    assert(user.uid != null);
    assert(user.email != null);

    uid = user.uid;
    userEmail = user.email!;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    return 'Successfully registered, User UID: ${user.uid}';
  }

  throw Exception();
}

Future<String> signInWithEmailPassword(String email, String password) async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final User? user = userCredential.user;

  if (user == null){
    throw Exception();
  }

    // checking if uid or email is null
    assert(user.uid != null);
    assert(user.email != null);

    uid = user.uid;
    userEmail = user.email!;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser!;
    assert(user.uid == currentUser.uid);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', true);

    return 'Successfully logged in, User UID: ${user.uid}';
}

void signOut() async {
  print("signOut()");
  authorization.value = null;
  await _auth.signOut();
}

Future<FirebaseApp> _buildFirebaseApp(){
  return Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyBvLdB53px2cU4_5QvQQLPRz18y-MvsLJE',
          appId: '1:351101922003:web:82ec8f4a98667c31a58226',
          messagingSenderId: '351101922003',
          projectId: 'zombie-survivor-24bf1'
      )
  );
}

void signInWithGoogle() async {
  print("signInWithGoogle()");
  await _buildFirebaseApp();

  final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

  if (googleSignInAccount == null) throw Exception("googleSignInAccount == null");

  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  print("setting user credentials");
  final credentials = await _auth.signInWithCredential(credential);

  if (credentials.user == null){
    throw Exception('credentials.user is null');
  }

  print("user credentials set");
  authorization.value = Authorization(
      userId: credentials.user!.uid,
      displayName: credentials.user!.displayName,
      email: credentials.user!.email
  );
}

void signOutGoogle() async {
  await _googleSignIn.signOut();
  await _auth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);

  uid = null;
  userEmail = null;
  print("User signed out of Google account");
}

class Authorization {
  final String userId;
  final String? email;
  final String? displayName;
  Authorization({
    required this.userId,
    this.displayName,
    this.email = "",
  });
}