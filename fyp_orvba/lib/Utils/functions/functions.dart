import 'package:firebase_database/firebase_database.dart';

Future<List<Map<String, dynamic>>> fetchDataOnce(String path) async {
  List<Map<String, dynamic>> registeredUsers = [];
  final _databaseReference = FirebaseDatabase.instance.ref().child(path);
  _databaseReference.onValue.listen((event) {
      registeredUsers.clear();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            value['id'] = key;
            registeredUsers.add(value.cast<String, dynamic>()); // Cast to the correct type
          });
        }
      }
  });
  return registeredUsers;
}