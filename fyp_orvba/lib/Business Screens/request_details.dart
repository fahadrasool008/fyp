import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Utils/components/Buttons.dart';
import 'package:fyp_orvba/Utils/styles/textStyles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class RequestDetails extends StatefulWidget {
  Map<String, dynamic>? request;
  RequestDetails({super.key, this.request});

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {


  List<Map<String,dynamic>> requests =[];
  List<Map<String,dynamic>> customers= [];
  List<Map<String,dynamic>> services= [];
  Map<String,dynamic>? currentRequest;
  Map<String,dynamic>? currentService;
  Map<String,dynamic>? currentCustomer;
  bool isLoading = true;
  late GoogleMapController mapController;
  late Marker _markers;
  LatLng _center = LatLng(0.0, 0.0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> fetchRequests() async {

    final _databaseReference = FirebaseDatabase.instance.ref().child("requests");
    _databaseReference.onValue.listen((event) {
      setState(() {
        requests.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              requests.add(value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchCustomers();
  }
  Future<void> fetchCustomers() async {

    final _databaseReference = FirebaseDatabase.instance.ref().child("customers");
    _databaseReference.onValue.listen((event) {
      setState(() {
        customers.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              customers.add(value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchServices();
  }
  Future<void> fetchServices() async {

    final _databaseReference = FirebaseDatabase.instance.ref().child("services");
    _databaseReference.onValue.listen((event) {
      setState(() {
        services.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              services.add(value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
  }

  RefineData() async{
    await fetchRequests();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
    requests.forEach((Map<String, dynamic>  request){
      setState(() {
        if(request["id"] == widget.request!["id"]){
          currentRequest = request;
        }
      });
    });
    customers.forEach((Map<String, dynamic>  customer){
      setState(() {
        if(customer["email"] == widget.request!["customerEmail"]){
          currentCustomer = customer;
        }
      });
    });
    services.forEach((Map<String, dynamic>  servic){
      setState(() {
        if(currentRequest!["serviceId"] == servic["id"]){
          currentService = servic;
        }
      });
    });
    // Update the marker position, camera position, and zoom level
    setState(() {
      _center = LatLng(currentService!["lat"], currentService!["lon"]);
      _markers = Marker(
        markerId: MarkerId('marker_1'),
        position: _center,
        infoWindow: InfoWindow(
          title: 'Marker',
          snippet: 'This is the marker',
        ),
      );
      CameraPosition  cameraPosition = CameraPosition(target: _center, zoom: 16,);
      mapController.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });

    print("Current Custoemr $currentCustomer");
    print("Current Request $currentRequest");
  }
  updateRequestStatus(String status){
    Map<String, dynamic> updateRequestData = {
      'customerEmail':currentRequest!["customerEmail"],
      'mechanicId':currentRequest!["mechanicId"],
      'serviceId':currentRequest!["serviceId"],
      'status':status,
    };

    DatabaseReference db = FirebaseDatabase.instance.ref().child("requests");
    db.child(currentRequest!["id"]).update(updateRequestData).then((_){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request Status updated")));
    });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    RefineData();
    _markers = Marker(
      markerId: MarkerId('marker_1'),
      position: _center,
      infoWindow: InfoWindow(
        title: 'Marker',
        snippet: 'This is the marker',
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading? Center(child: CircularProgressIndicator()) : Stack(
        children: [
          Expanded(
            child:  GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16.0,
              ),
              markers: {_markers},
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                height: MediaQuery.of(context).size.height*0.2,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: [
                     Padding(
                      padding:  EdgeInsets.all(8.0),
                      child: CircleAvatar(radius: 25,backgroundColor: Colors.blue,
                      backgroundImage: NetworkImage(currentCustomer!["url"]),),
                    ),
                    Text(currentCustomer!["fullname"],style: bold18Black,),
                    Row(
                      children: [
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: (){
                                updateRequestStatus("approved");
                              },
                              child: SmoothButton(title: "Approve",backColor: Colors.green,)),
                        )),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: (){
                                updateRequestStatus("rejected");
                              },
                              child: SmoothButton(title: "Reject",backColor: Colors.redAccent,)),
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
