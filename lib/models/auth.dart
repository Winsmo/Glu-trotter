import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      print("Début de la connexion Google...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print("Utilisateur Google sélectionné: ${googleUser?.email}");

      if (googleUser == null) {
        print("L'utilisateur a annulé la connexion.");
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'La connexion a été annulée par l\'utilisateur.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      print("Authentification Google réussie.");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      print("Connexion Firebase réussie.");
    } on FirebaseAuthException catch (e) {
      print("Erreur FirebaseAuth: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur inattendue: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut(); // Déconnexion de Google également
  }
}