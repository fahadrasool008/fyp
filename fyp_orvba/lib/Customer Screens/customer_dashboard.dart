import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Customer%20Screens/breakdown_screen.dart';
import 'package:fyp_orvba/Customer%20Screens/search_results.dart';
import 'package:fyp_orvba/Utils/functions/functions.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../Common/profile.dart';
import '../Utils/components/Buttons.dart';
import '../Utils/components/containers.dart';
import '../Utils/components/drawers.dart';
import '../Utils/styles/textStyles.dart';


class VehicleModel{
  String title, path;
  bool checked;
  VehicleModel({required this.title,  required this.path, required this.checked});
}
class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {

  List<Map<String,dynamic>> customers =[];
  Map<String,dynamic>? currentCustomer;
  bool isLoading = false;
  bool disabled = false;
  bool disabledTruck = false;
  List<VehicleModel> vehicleTypeList = [
    VehicleModel(title: "bike",path: "assets/sportbike.png",checked: true),
    VehicleModel(title: "car",path: "assets/sedanCar.png",checked: false),
    VehicleModel(title: "truck",path: "assets/cargo-truck.png",checked: false),
  ];
  List<VehicleModel> vehicleModeList = [
    VehicleModel(title: "petrol",path: "",checked: false),
    VehicleModel(title: "cng",path: "",checked: false),
    VehicleModel(title: "electric",path: "",checked: false),
  ];
  List<VehicleModel> vehicleCategoryList = [
    VehicleModel(title: "Automatic Cars",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "Family Cars",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "5 Seater",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "Small Cars",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "Big Cars",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "4 Door",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "Old Cars",path: "assets/sedan.png",checked: false),
    VehicleModel(title: "Others",path: "assets/sedan.png",checked: false),
  ];

  resetSelected(List<VehicleModel> list){
    for(int i=0; i<list.length; i++){
      list[i].checked = false;
    }
  }

  int checkSelected(List<VehicleModel> list){
    for(int i=0; i<list.length; i++){
      if(list[i].checked == true)
        return i;
    }
    return 0;
  }
  bool checkSelectedbool(List<VehicleModel> list){
    for(int i=0; i<list.length; i++){
      if(list[i].checked == true)
        return true;
    }
    return false;
  }

  Future<void> fetchData() async {
    final _databaseReference = FirebaseDatabase.instance.ref().child("customers");
    _databaseReference.onValue.listen((event) {
      setState(() {
        customers.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              print("Key: $key Value: $value");
              value['id'] = key;
              customers.add(value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }

      });

    });
  }
  void RefineData()async{
    String email = FirebaseAuth.instance.currentUser!.email.toString();

    await fetchData();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
    isLoading = false;
    });
    customers.forEach((Map<String,dynamic> customer){
      if(customer["email"] == email){
        setState(() {
          currentCustomer = customer;
        });
      }
    });

  }

  LatLng? currentLocation;
  Future<void> _determinePosition() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      currentLocation =
          LatLng(_locationData.latitude!, _locationData.longitude!);
    });
    print(currentLocation!.longitude);
    print(currentLocation!.latitude);
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    RefineData();
    _determinePosition();
    if(vehicleTypeList[1].checked == false){
        disabled = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(children: [
        Container(
          width: double.infinity,
          height: 190,
          color: const Color(0xff3F54BE),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: isLoading? Center(child: CircularProgressIndicator(),) : ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap:(){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  userTitle: "customers",
                                )));
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.orange,
                        backgroundImage: NetworkImage(currentCustomer!["url"]),
                      ),
                    ),
                    GestureDetector(
                        onTap: () async{
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Icon(Icons.logout,color: Colors.white,size: 30,))
                  ],
                ),
              ),
              const Gap(30),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffECEFF8),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Get Services from \n your location",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),
                          SizedBox(
                              width: 100, height: 40, child: RoundedButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchResults(latLng: currentLocation, showAll: true,) ));
                            },
                            title: "Find Services",)),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -50,
                    right: -30,
                    child: Image(
                      image: AssetImage("assets/rm-cartoon.png"),
                      height: 290
                      ,
                    ),
                  )
                ],
              ),
              const Gap(20),
              Text(
                "Vehicle Type",
                style: bold14Black,
              ),
              const Gap(5),
              SizedBox(
                height: 120,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicleTypeList.length,
                    itemBuilder: (context, index) {
                      return  Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GestureDetector(
                            onTap: (){
                              setState(() {
                                resetSelected(vehicleTypeList);
                                vehicleTypeList[index].checked = true;
                                if(vehicleTypeList[1].checked == true){
                                  setState(() {
                                    disabled = false;
                                  });
                                }
                                else{
                                  setState(() {
                                    disabled = true;
                                  });
                                }
                              });
                            },
                            child: CategoryContainer(title: vehicleTypeList[index].title, selected: vehicleTypeList[index].checked,path: vehicleTypeList[index].path)),
                      );
                    }),
              ),
              const Gap(20),
              Text(
                "Vehicle Category",
                style: bold14Black,
              ),
              const Gap( 5),
                SizedBox(
                height: 120,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicleCategoryList.length,
                    itemBuilder: (context, index) {
                      VehicleModel item = vehicleCategoryList[index];
                      return  Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GestureDetector(
                            onTap: disabled == true? (){} :(){
                              setState(() {
                                resetSelected(vehicleCategoryList);
                                vehicleCategoryList[index].checked = true;
                              });
                            },
                            child: CategoryContainer(title: item.title,path: item.path,selected: item.checked, disabled:  disabled,)),
                      );
                    }),
              ),
              const Gap( 20),
              Text(
                "Vehicle Mode",
                style: bold14Black,
              ),
              const Gap( 5),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.18,
                child: ListView.builder(
                    itemCount: vehicleTypeList[2].checked?1:3,
                    itemBuilder: (context,index){
                  return GestureDetector(
                      onTap: (){
                        setState(() {
                          resetSelected(vehicleModeList);
                          vehicleModeList[index].checked = true;
                        });
                      },
                      child: ModeContainer(title: vehicleModeList[index].title,  checked: vehicleModeList[index].checked ));
                }),
              ),
              const Gap( 20),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 140.0),
                    child: RoundedButton(title: "Next", onPressed: (){
                      if(checkSelectedbool(vehicleTypeList)  && checkSelectedbool(vehicleModeList) )
                      {
                        if(vehicleTypeList[1].checked ){
                          if(checkSelectedbool(vehicleCategoryList)){
                            int one = checkSelected(vehicleTypeList);
                            int three = checkSelected(vehicleModeList);

                            Navigator.push(context, MaterialPageRoute(builder: (context)=> BreakdownScreen(vehicleType: vehicleTypeList[one],vehicleMode: vehicleModeList[three],latLng: currentLocation,)));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                                width: MediaQuery.of(context).size.width*0.9,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 400),
                                backgroundColor:const Color(0xff3F54BE),
                                content: Text("Please select all fields",style: bold13White,)));
                          }
                        }
                        else{
                          int one = checkSelected(vehicleTypeList);
                          int three = checkSelected(vehicleModeList);

                          Navigator.push(context, MaterialPageRoute(builder: (context)=> BreakdownScreen(vehicleType: vehicleTypeList[one],vehicleMode: vehicleModeList[three],latLng: currentLocation,)));
                        }

                      }else{
                        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                            width: MediaQuery.of(context).size.width*0.9,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(milliseconds: 400),
                            backgroundColor:const Color(0xff3F54BE),
                            content: Text("Please select all fields",style: bold13White,)));
                      }
                    },),
                  ))
            ],
          ),
        ),
      ]),
    );
  }
}
