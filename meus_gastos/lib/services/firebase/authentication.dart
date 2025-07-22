import "package:firebase_auth/firebase_auth.dart";
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> signupUser(
      {required String name,
      required String email,
      required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return getFirebaseErrorMessage(e.code);
    }
  }

  String getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso. Tente outro.';
      case 'invalid-email':
        return 'E-mail inválido. Verifique o endereço de e-mail.';
      case 'operation-not-allowed':
        return 'Cadastro com e-mail desativado. Contate o suporte.';
      case 'weak-password':
        return 'Senha muito fraca. Escolha uma senha mais forte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Falha na conexão. Verifique sua internet.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<String?> signinUser(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signout() async {
    return _firebaseAuth.signOut();
  }
  Future<User?> signInWithGoogle() async {
    try {
      // Faz login com o Google
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

      return userCredential.user;
    } catch (e) {
      print('Erro durante login com Google: $e');
      return null;
    }
  }


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
