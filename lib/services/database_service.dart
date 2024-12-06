import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String name, String team) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'team': team,
    });
  }

  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }
}
