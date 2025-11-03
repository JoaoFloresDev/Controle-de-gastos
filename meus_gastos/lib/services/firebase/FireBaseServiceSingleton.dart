import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meus_gastos/firebase_options.dart';

class FirebaseService {
  static FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseDatabase get database => FirebaseDatabase.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firestore.settings = const Settings(persistenceEnabled: true);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
  }
}
