import "package:firebase_auth/firebase_auth.dart";

class Authentication {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
