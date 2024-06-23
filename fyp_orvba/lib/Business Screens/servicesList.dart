import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Business%20Screens/create_business.dart';
import 'package:fyp_orvba/Business%20Screens/request_details.dart';
import 'package:fyp_orvba/Utils/styles/textStyles.dart';

import '../Utils/components/containers.dart';

class Serviceslist extends StatefulWidget {
  const Serviceslist({super.key});

  @override
  State<Serviceslist> createState() => _ServiceslistState();
}

class _ServiceslistState extends State<Serviceslist> {
  List<Map<String, dynamic>> allServicesList = [];
  List<Map<String, dynamic>> myServicesList = [];
  List<Map<String, dynamic>> mechanicsList = [];
  Map<String, dynamic>? currentMechanic;
  bool isLoading = false;

  Future<void> fetchServices() async {
    DatabaseReference db = FirebaseDatabase.instance.ref().child("services");

    db.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          allServicesList.clear();
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value["id"] = key;
              allServicesList.add(value.cast<String, dynamic>());
            });
          }
        });
      }
    });
    await fetchMechanics();
  }

  Future<void> fetchMechanics() async {
    DatabaseReference db = FirebaseDatabase.instance.ref().child("mechanics");
    db.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          mechanicsList.clear();
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value["id"] = key;
              mechanicsList.add(value.cast<String, dynamic>());
            });
          }
        });
      }
    });
  }

  void RefineData() async {
    String email = FirebaseAuth.instance.currentUser!.email.toString();
    await fetchServices();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });

    mechanicsList.forEach((Map<String, dynamic> mechanic) {
      if (mechanic["email"] == email) {
        setState(() {
          currentMechanic = mechanic;
        });
      }
    });
    allServicesList.forEach((Map<String, dynamic> service) {
      if (service["mechanicId"] == currentMechanic!["id"]) {
        setState(() {
          myServicesList.add(service);
        });
      }
    });

    allServicesList.clear();
    mechanicsList.clear();
    print(currentMechanic);
    print(myServicesList);
  }

  Future<void> deleteItem(String key) async {
    final DatabaseReference _database = FirebaseDatabase.instance.ref();
    try {
      await _database.child('services').child(key).remove();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting data: $e')));
    }
  }
  Future<void> deleteImage(String imagePath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(imagePath);
    try {
      await ref.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    RefineData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Your services",
          style: bold18White,
        ),
        backgroundColor: const Color(0xFF3F54BE),
      ),
      body: myServicesList.isEmpty? Center(child: Text("You have no Services", style: bold13Black,),) : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          shrinkWrap: true,
            itemCount: myServicesList.length,
            itemBuilder: (context, index) {
              Map<String,dynamic> item = myServicesList[index];

          return Dismissible(
            
            key: Key(item["id"]),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction){

              setState(() async{
                myServicesList.removeAt(index);
                await deleteItem(item["id"]);
                await deleteImage(item["path"]);

              });
            },
            child: ServicesContainer2(
            min: item["minPrice"],
              max: item["maxPrice"],
              url: item["thumbnail"],
              title: item["title"],
              onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateBusiness(service: item,edit: true,)));
              },
              
            ),
          );
        }),
      ),
    );
  }
}
