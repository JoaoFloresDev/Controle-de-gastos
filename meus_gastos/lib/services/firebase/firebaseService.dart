import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meus_gastos/firebase_options.dart';

class FirebaseService {
  String? _userId;
  late FirebaseFirestore _firestore;

  String? get userId => _userId;
  FirebaseFirestore get firestore => _firestore;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);

    FirebaseService();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _firestore = FirebaseFirestore.instance;
  }
}
