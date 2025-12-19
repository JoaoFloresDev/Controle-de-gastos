// DELETAR
import "package:firebase_auth/firebase_auth.dart";
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _userId;
  String? get userId => _userId;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Login cancelado
      }

      // Obtém as credenciais do Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Cria credenciais para o Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz o login no Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      _userId = userCredential.user!.uid;

      return userCredential.user;
    } catch (e) {
      print('Erro durante login com Google: $e');
      return null;
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();

    _userId = null;
  }
}
