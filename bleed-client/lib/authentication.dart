import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lemon_watch/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

final Watch<UserCredential?> userCredentials = Watch(null);

User? get user => userCredentials.value?.user;

// String? name = "";
// String? imageUrl = "";
final FirebaseAuth _auth = FirebaseAuth.instance;

bool authSignedIn = false;
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
  userCredentials.value = null;
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
  userCredentials.value = await _auth.signInWithCredential(credential);
  print("user credentials set");


  // if (user != null) {
  //   // // Checking if email and name is null
  //   // assert(user.uid != null);
  //   // assert(user.email != null);
  //   // assert(user.displayName != null);
  //   // assert(user.photoURL != null);
  //
  //   uid = user.uid;
  //   name = user.displayName;
  //   userEmail = user.email;
  //   imageUrl = user.photoURL;
  //
  //   assert(!user.isAnonymous);
  //   assert(await user.getIdToken() != null);
  //
  //   final User? currentUser = _auth.currentUser;
  //   assert(user.uid == currentUser!.uid);
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('auth', true);
  //
  //   return 'Google sign in successful, User UID: ${user.uid}';
  // }
  //
  // throw Exception();
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

Future getUser() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool authSignedIn = prefs.getBool('auth') ?? false;

  final User? user = _auth.currentUser;

  if (authSignedIn == true) {
    if (user != null) {
      uid = user.uid;
      userEmail = user.email;
    }
  }
}