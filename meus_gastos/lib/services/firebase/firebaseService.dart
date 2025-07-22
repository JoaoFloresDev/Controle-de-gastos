import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_core/firebase_core.dart';
import 'package:meus_gastos/firebase_options.dart';

class FirebaseService {
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Habilitar cache offline para Firestore
    firestore.FirebaseFirestore.instance.settings = const firestore.Settings(
      persistenceEnabled: true, // Ativa o cache offline
    );

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
  }
}
