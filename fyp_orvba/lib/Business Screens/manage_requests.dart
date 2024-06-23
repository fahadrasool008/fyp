import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Business%20Screens/request_details.dart';
import 'package:gap/gap.dart';
import '../Utils/styles/textStyles.dart';


class ManageRequests extends StatefulWidget {
  const ManageRequests({super.key});

  @override
  State<ManageRequests> createState() => _ManageRequestsState();
}

class _ManageRequestsState extends State<ManageRequests> {

  List<Map<String,dynamic>> mechanics = [];
  List<Map<String,dynamic>> requests = [];
  List<Map<String,dynamic>> currentRequests = [];
  List<Map<String,dynamic>> customers =[];
  List<Map<String,dynamic>> services =[];
  List<Map<String,dynamic>> currentServices =[];
  List<Map<String,dynamic>> customerAndRequest= [];
  List<Map<String,dynamic>> pendingRequest= [];
  List<Map<String,dynamic>> approvedRequest= [];
  bool isLoading = true;

  Future<void> fetchMechanics() async {

    final _databaseReference = FirebaseDatabase.instance.ref().child("mechanics");
    _databaseReference.onValue.listen((event) {
      setState(() {
        mechanics.clear();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            value['id'] = key;
            mechanics.add(value.cast<String, dynamic>()); // Cast to the correct type
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
    await fetchrequests();
  }
  Future<void> fetchrequests() async {

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
  }

void fetchData() async{

  String currentEmail = FirebaseAuth.instance.currentUser!.email.toString();
  String mechanicId = "";
   await fetchMechanics();
  setState(() {
    isLoading = true;
  });
  await Future.delayed(Duration(seconds: 3));
  setState(() {
    isLoading = false;
  });

  mechanics.forEach((Map<String, dynamic> mechanic){
    if(mechanic["email"] == currentEmail){
      setState(() {
        mechanicId = mechanic["id"].toString();
      });
    }
  });

  requests.forEach((Map<String, dynamic>  request){
    setState(() {
      if(request["mechanicId"] == mechanicId){
        currentRequests.add(request);
      }
    });
  });

  services.forEach((Map<String, dynamic>  service){
    currentRequests.forEach((Map<String, dynamic> currentRequest){
      setState(() {
        if(service["mechanicId"] == currentRequest["mechanicId"]){
          currentServices.add(service);
        }
      });
    });
  });

  currentRequests.forEach((Map<String,dynamic> currentRequest){
    customers.forEach((Map<String,dynamic> customer2){
      if(currentRequest["customerEmail"]==customer2["email"]){
        currentRequest["fullname"] = customer2["fullname"];
        currentRequest["url"] = customer2["url"];
        customerAndRequest.add(currentRequest);
      }
    });
  });
  customerAndRequest.forEach((Map<String,dynamic> req){
    if(req["status"]=="pending"){
      setState(() {
        pendingRequest.add(req);
      });
    }
    else if(req["status"]=="approved"){
      setState(() {
        approvedRequest.add(req);
      });
    }
  });
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF3F54BE),
          bottomOpacity: 1.0,
          title: Text(
            "Requests",
            style: bold18White,
          ),
          bottom: TabBar(
            labelStyle: bold14White,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.pending_outlined), text: 'Pending'),
              Tab(icon: Icon(Icons.approval), text: 'Approved')
            ],
          ),
        ),

        body: TabBarView(
          children: [
            isLoading?Center(child: CircularProgressIndicator(),) : PendingRequest( customerAndRequest: pendingRequest),
            ApprovedRequest(customerAndRequest: approvedRequest,),
          ],
        ),
      ),
    );
  }
}

class PendingRequest extends StatelessWidget {

  List<Map<String,dynamic>> customerAndRequest;
   PendingRequest({super.key, required this.customerAndRequest});

  @override
  Widget build(BuildContext context) {
    return customerAndRequest.isNotEmpty? ListView.builder(
        shrinkWrap: true,
        itemCount: customerAndRequest.length,
        itemBuilder: (context,index){
          Map<String, dynamic> request = customerAndRequest[index];
          return Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0EDED), width: 1))
            ),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestDetails(request: request,)));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(radius: 30, backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(request["url"]),),
                  title: Text(request["fullname"].toString(), style: bold14Black,),
                  subtitle: Text(request["customerEmail"].toString(), style: bold14Black,),
                  trailing: Text("5km",style: bold14Black,),
                ),
              ),
            ),
          );
        }):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(image: AssetImage("assets/rm-cartoon.png"),width: 150,
        ),
        Text("No new requests fonund", style: bold14Black,)
      ],
    );
  }
}
class ApprovedRequest extends StatelessWidget {
  List<Map<String,dynamic>> customerAndRequest;
  ApprovedRequest({super.key, required  this.customerAndRequest});

  @override
  Widget build(BuildContext context) {
      return customerAndRequest.isEmpty? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Image(image: AssetImage("assets/rm-cartoon.png"),width: 150,
            ),
          Text("No new requests fonund", style: bold14Black,)
        ],
      ):ListView.builder(
          shrinkWrap: true,
          itemCount: customerAndRequest.length,
          itemBuilder: (context,index){
            Map<String, dynamic> request = customerAndRequest[index];
            return Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF0EDED), width: 1))
              ),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestDetails(request: request,)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(radius: 30, backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(request["url"]),),
                    title: Text(request["fullname"].toString(), style: bold14Black,),
                    subtitle: Text(request["customerEmail"].toString(), style: bold14Black,),
                    trailing: Text("5km",style: bold14Black,),
                  ),
                ),
              ),
            );
          });
  }
}


