import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp_orvba/Business%20Screens/create_business.dart';
import 'package:fyp_orvba/Business%20Screens/manage_requests.dart';
import 'package:fyp_orvba/Business%20Screens/servicesList.dart';
import 'package:fyp_orvba/Common/profile.dart';
import 'package:fyp_orvba/Utils/components/drawers.dart';
import 'package:gap/gap.dart';
import '../Utils/components/containers.dart';
import '../Utils/components/utilities.dart';
import '../Utils/styles/textStyles.dart';

class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({super.key});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> approvedRequest = [];
  List<Map<String, dynamic>> mechanics = [];
  Map<String, dynamic>? currentMechanic;
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> currentServices = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> currentReviews = [];
  int num = 0;
  double avg = 0.0;
  bool isLoading = false;

  Future<void> fetchrequests() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child("requests");
    _databaseReference.onValue.listen((event) {
      setState(() {
        requests.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              requests.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child("mechanics");
    _databaseReference.onValue.listen((event) {
      setState(() {
        mechanics.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              print("Key: $key Value: $value");
              value['id'] = key;
              mechanics.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchServices();
  }

  Future<void> fetchServices() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child("services");
    _databaseReference.onValue.listen((event) {
      setState(() {
        services.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              print("Key: $key Value: $value");
              value['id'] = key;
              services.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchReviews();
  }

  Future<void> fetchReviews() async {
    final _databaseReference = FirebaseDatabase.instance.ref().child("reviews");
    _databaseReference.onValue.listen((event) {
      setState(() {
        reviews.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              print("Key: $key Value: $value");
              value['id'] = key;
              reviews.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
  }

  void RefineData() async {
    String currentEmail = FirebaseAuth.instance.currentUser!.email.toString();
    await fetchrequests();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
    requests.forEach((Map<String, dynamic> request) {
      if (request["status"] == "approved") {
        setState(() {
          approvedRequest.add(request);
        });
      }
    });

    mechanics.forEach((Map<String, dynamic> mac) {
      if (mac["email"] == currentEmail) {
        setState(() {
          currentMechanic = mac;
        });
      }
    });

    services.forEach((Map<String, dynamic> service) {
      if (currentMechanic!["id"] == service["mechanicId"]) {
        setState(() {
          currentServices.add(service);
        });
      }
    });

    services.forEach((Map<String, dynamic> service) {
      reviews.forEach((Map<String, dynamic> review) {
        if(service["id"] == review["serviceId"]){
          setState(() {
            currentReviews.add(review);
          });
        }
      });
    });
    List<int> rating = [];
    currentReviews.forEach((Map<String,dynamic> review){
      setState(() {
        rating.add(review["rating"]);
      });
    });

    if(rating.length != 0){
      for(int i=0; i<rating.length; i++){
        setState(() {
          num +=rating[i];
        });
      }
      avg = num/rating.length;
    }

    print(currentReviews);
  }

  double normalizeToRange(int number) {
    return (number / number.toDouble().abs() + 1) / 2;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: Text(
          "Dashboard",
          style: bold18White,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Icon(
                Icons.logout,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Gap(10)
        ],
      ),
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: 250,
          color: const Color(0xFF3F54BE),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: ListView(
              children: [
                const Gap(50),
                Text(
                  "General Report",
                  style: bold18White,
                ),
                const Gap(10),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(2, 3),
                            blurRadius: 5,
                            spreadRadius: -1,
                            color: Color(0xffB6B4B4))
                      ]),
                  height: 200,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomGradientProgressBar(
                              first: const Color(0xFFFFC700),
                              second: const Color(0xFFFCA53E),
                              value: normalizeToRange(approvedRequest.length) ,
                              text: Text(approvedRequest.length.toString(),style: TextStyle(fontSize: 13,color: const Color(0xFFFFC700),fontWeight: FontWeight.bold),),

                            ),
                            Text(
                              "Total Sales",
                              style: bold14Black,
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomGradientProgressBar(
                              first: const Color(0xFF16DF7F),
                              second: const Color(0xFF6AF6C7),
                              value: normalizeToRange(avg.toInt()),
                              text: Text(avg.toString(),style: TextStyle(fontSize: 13,color: const Color(0xFF6AF6C7),fontWeight: FontWeight.bold),),
                            ),
                            Text(
                              "Total Rating",
                              style: bold14Black,
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomGradientProgressBar(
                              first: const Color(0xFFEC343F),
                              second: const Color(0xFFFEA4A9),
                              value: normalizeToRange(currentReviews.length),
                              text: Text(currentReviews.length.toString(),style: TextStyle(fontSize: 13,color: const Color(0xFFEC343F),fontWeight: FontWeight.bold),),
                            ),
                            Text(
                              "Total Reviews",
                              style: bold14Black,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(40),
                Text(
                  "Manage Services",
                  style: bold18Black,
                ),
                const Gap(20),
                GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      ServicesContainer(
                        url: "assets/rocket.png",
                        title: "Create Service",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateBusiness(
                                        edit: false,
                                      )));
                        },
                      ),
                      ServicesContainer(
                        url: "assets/edit.png",
                        title: "Edit Service",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Serviceslist()));
                        },
                      ),
                      ServicesContainer(
                        url: "assets/sos.png",
                        title: "View Request",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageRequests()));
                        },
                      ),
                      ServicesContainer(
                        url: "assets/info.png",
                        title: "About Me",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                        userTitle: "mechanics",
                                      )));
                        },
                      ),
                    ])
              ],
            )),
      ]),
    );
  }
}
