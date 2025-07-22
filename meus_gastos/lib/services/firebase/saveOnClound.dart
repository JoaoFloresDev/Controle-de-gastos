import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Saveonclound {
   String? userId;
  Saveonclound() : userId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
}