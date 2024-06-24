import 'package:flutter/material.dart';
import 'package:fyp_orvba/Customer%20Screens/search_results.dart';
import 'package:fyp_orvba/Utils/components/Buttons.dart';
import 'package:fyp_orvba/Utils/components/containers.dart';
import 'package:fyp_orvba/Utils/styles/textStyles.dart';
import 'package:latlong2/latlong.dart';

import 'customer_dashboard.dart';


class BreakdownModel{
  String title,key;
  String path;
  bool checked;
  BreakdownModel({required this.title, required this.path, this.checked = false, this.key =""});
}
class BreakdownScreen extends StatefulWidget {
  VehicleModel? vehicleType,vehicleMode;
  LatLng? latLng;
   BreakdownScreen({super.key, this.vehicleType, this.vehicleMode, this.latLng});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {

  List<BreakdownModel> titleAndPathList = [
    BreakdownModel(title: "car battery issue",path: "assets/car-battery.png",checked: false,key: "carBatteryIssue"),
    BreakdownModel(title: "tyre damage",path: "assets/flat-tire.png",checked: false,key:"tyreDamage"),
    BreakdownModel(title: "out of fuel",path: "assets/fuel.png",checked: false,key: "outOfFuel"),
    BreakdownModel(title: "lost key",path: "assets/car-key.png",checked: false,key: "lostKey"),
    BreakdownModel(title: "engine overheating",path: "assets/overheat.png",checked: false,key: "engineOverheating"),
    BreakdownModel(title: "exhaust smoke",path: "assets/exhaust-pipe.png",checked: false,key: "exhaustSmoke"),
    BreakdownModel(title: "low ac cooling",path: "assets/air-conditioner.png",checked: false,key: "lowAcCooling"),
    BreakdownModel(title: "others",path: "assets/man.png",checked: false,key: "others"),
  ];

  reset(){
    for(int i =0; i<titleAndPathList.length; i++){
      setState(() {
        titleAndPathList[i].checked = false;
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.vehicleType!.checked.toString());
    print(widget.vehicleMode!.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select your breakdown", style: bold18White,),
        backgroundColor: const Color(0xFF3F54BE),
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(8),
        children: List.generate(titleAndPathList.length, (index){

          return Expanded(child: GestureDetector(
              onTap: (){
                setState(() {
                  titleAndPathList[index].checked = true;
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchResults(vehicleMode: widget.vehicleMode,vehicleType: widget.vehicleType,breakDownItem: titleAndPathList[index],latLng: widget.latLng,)));
                });
              },
              child: BreakDownContainer(title: titleAndPathList[index].title,path: titleAndPathList[index].path,)));
        })
      ),
    );
  }
}
