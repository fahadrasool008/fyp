import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_orvba/Common/location_details.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../Customer Screens/breakdown_screen.dart';
import '../Customer Screens/customer_dashboard.dart';
import '../Utils/components/Buttons.dart';
import '../Utils/components/containers.dart';
import '../Utils/components/controllers_class.dart';
import '../Utils/components/utilities.dart';
import '../Utils/styles/textStyles.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;



class MajorServicesModel{
  String serviceName;
  bool checked;
  MajorServicesModel({required this.serviceName, required this.checked});

}

class CreateBusiness extends StatefulWidget {
  Map<String, dynamic>? service;
  bool edit;
  CreateBusiness({super.key, this.service, this.edit= false});

  @override
  State<CreateBusiness> createState() => _CreateBusinessState();
}

class _CreateBusinessState extends State<CreateBusiness> {
  List<Widget> businessWidgetList = [];
  List<Map<String, dynamic>> registeredUsers = [];
  late DatabaseReference _databaseReference;
  FirebaseAuth auth = FirebaseAuth.instance;
  Uint8List? _imageBytes;
  User? currentUser;
  double lat =0,lon = 0;
  ImagePicker imagePicker = ImagePicker();
  int counter = 0;
  XFile? image;
  String imgPath = "";
  Controllers? controllers;
  String mechanicId = "";
  LatLng latlng = LatLng(0.0, 0.0);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  List<VehicleModel> vehicleTypeList = [
    VehicleModel(title: "bike",path: "assets/sportbike.png",checked: false),
    VehicleModel(title: "car",path: "assets/sedanCar.png",checked: false),
    VehicleModel(title: "truck",path: "assets/cargo-truck.png",checked: false),
  ];
  List<VehicleModel> vehicleModeList = [
    VehicleModel(title: "petrol",path: "",checked: false),
    VehicleModel(title: "cng",path: "",checked: false),
    VehicleModel(title: "electric",path: "",checked: false),
  ];
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


  void loadData(){
    if(widget.edit){
      titleController.text = widget.service!["title"]??"";
      descriptionController.text = widget.service!["description"]??"";
      minPriceController.text = widget.service!["minPrice"]??"";
      maxPriceController.text = widget.service!["maxPrice"]??"";
      imgPath = widget.service!["thumbnail"]??"";
      titleAndPathList[0].checked = widget.service!["carBatteryIssue"]??"";
      titleAndPathList[1].checked = widget.service!["tyreDamage"]??"";
      titleAndPathList[2].checked = widget.service!["outOfFuel"]??"";
      titleAndPathList[3].checked = widget.service!["lostKey"]??"";
      titleAndPathList[4].checked = widget.service!["engineOverheating"]??"";
      titleAndPathList[5].checked = widget.service!["exhaustSmoke"]??"";
      titleAndPathList[6].checked = widget.service!["lowAcCooling"]??"";
      titleAndPathList[7].checked = widget.service!["others"]??"";
      lat =  widget.service!["lat"];
      lon = widget.service!["lon"];


    }
  }
  Future<Map<String, dynamic>> uploadImageToFirebase(String imagePath) async {
    String tempPath = 'images/${Path.basename(imagePath)}';
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(tempPath);
      firebase_storage.UploadTask uploadTask = ref.putFile(File(imagePath));
      await uploadTask.whenComplete(() => print('Image Uploaded'));
      String tempURl = await ref.getDownloadURL();
      Map<String, dynamic> pathObj = {
        "url": tempURl,
        "path": tempPath
      };
      return pathObj;
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  pickImage() async {
    XFile? img = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  void getMechanicId(){
  fetchDataOnce("mechanics");
  currentUser = auth.currentUser;
  for(int i = 0; i<registeredUsers.length; i++){
    Map<String, dynamic> user = registeredUsers[i];
    if(currentUser!.email == user["email"]){
      setState(() {
        print(user["id"]);
        mechanicId = user["id"];
        print(mechanicId);
      });
    }
  }
}

  void fetchDataOnce(String path) async {
    final _databaseReference = FirebaseDatabase.instance.ref().child(path);
    _databaseReference.onValue.listen((event) {
      setState(() {
        registeredUsers.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              print("Key: $key Value: $value");
              value['id'] = key;
              registeredUsers.add(value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }

      });

    });

    print("This is data"+registeredUsers.toString());
  }
  void deleteImage(String path) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(path);
    await ref.delete();
    print('Image deleted successfully');
  }
  void createService() async{
    _databaseReference = FirebaseDatabase.instance.ref();
    String url ="";
    Map<String, dynamic> obj= {};
    if(image != null){
      obj = await uploadImageToFirebase(image!.path);
      url = obj["url"];
      if(widget.edit== true){
        deleteImage(widget.service!["path"]);
      }
    }else{
      url = imgPath;
    }
    getMechanicId();
    Map<String,dynamic> serviceData ={
      'mechanicId': mechanicId,
      'thumbnail':url,
      'title': titleController.text,
      'minPrice':minPriceController.text,
      'maxPrice':maxPriceController.text,
      'description': descriptionController.text,
      'carBatteryIssue': titleAndPathList[0].checked,
      'tyreDamage': titleAndPathList[1].checked,
      'outOfFuel': titleAndPathList[2].checked,
      'lostKey': titleAndPathList[3].checked,
      'engineOverheating': titleAndPathList[4].checked,
      'exhaustSmoke': titleAndPathList[5].checked,
      'lowAcCooling': titleAndPathList[6].checked,
      'others': titleAndPathList[7].checked,
      'bike':vehicleTypeList[0].checked,
      'car':vehicleTypeList[1].checked,
      'truck':vehicleTypeList[2].checked,
      'petrol':vehicleModeList[0].checked,
      'cng':vehicleModeList[1].checked,
      'electric':vehicleModeList[2].checked,
      'lat': latlng.latitude,
      'lon': latlng.longitude,
      'path':obj["path"],
    };

    if(widget.edit){
      _databaseReference.child("services").child(widget.service!["id"]).update(serviceData).then((_){

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service Updated Successfully")));
        reset();
      }).catchError((error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Updated Service")));
      });
    }else{
      _databaseReference.child("services").push().set(serviceData).then((_){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service Created Successfully")));
        reset();
      }).catchError((error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Create Service")));
      });
    }
  }

  reset(){
    titleController.clear();
    descriptionController.clear();
    minPriceController.clear();
    maxPriceController.clear();
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
    loadData();
    getMechanicId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: image == null&&imgPath==""
                ? Container(
                    width: double.infinity,
                    color: const Color(0xFF3F54BE),
                    child: Center(
                        child: GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF3F54BE),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      imgPath==""? Image.file(
                        File(image!.path),
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ):Image.network(imgPath,width: double.infinity,height: 300,fit: BoxFit.cover,),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pickImage();
                          });
                        },
                        child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color.fromARGB(100, 0, 0, 0),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 50,
                            )),
                      )
                    ],
                  ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 1.4,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  children: [
                    const Gap( 20),
                    Text(
                      "Add Service Details",
                      style: bold14Black,
                      textAlign: TextAlign.center,
                    ),
                    const Gap( 20),
                    CustomTextField(
                      controller: titleController,
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: minPriceController,
                          ),
                        ),
                        Gap(20),
                        Expanded(
                          child: CustomTextField(
                            controller: maxPriceController,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller:descriptionController,
                          )),
                    ),
                    const Gap(10),
                    const Divider(),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select major Services",
                          style: bold14Black,
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              for(int i=0; i<titleAndPathList.length; i++){
                                titleAndPathList[i].checked = true;
                              }
                            });
                          },
                          child: Text(
                            "Select All",
                            style: bold14BlueAccent,
                          ),
                        ),
                      ],
                    ),
                     GridView.count(
                       physics: NeverScrollableScrollPhysics(),
                       padding: EdgeInsets.zero,
                       shrinkWrap: true,
                       crossAxisCount: 4,
                       children: List.generate(titleAndPathList.length, (index){
                         return Padding(
                           padding: const EdgeInsets.all(4.0),
                           child: Expanded(child: GestureDetector(
                               onTap: (){
                                 setState(() {
                                   titleAndPathList[index].checked = !titleAndPathList[index].checked;
                                 });
                               },
                               child: CategoryContainer(width: 40, selected: titleAndPathList[index].checked, title: titleAndPathList[index].title,path: titleAndPathList[index].path,))),
                         );
                       }),

                     ),
                    Gap(10),
                    Text("Vehicle Type",style: bold14Black,),
                    const Gap( 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.18,
                      width: double.infinity,
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                          crossAxisCount: 3,
                      children: List.generate(vehicleTypeList.length, (index){
                        return GestureDetector(
                            onTap: (){
                              setState(() {
                                // resetSelected(vehicleModeList);
                                // vehicleModeList[index].checked = true;
                              });
                            },
                            child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    vehicleTypeList[index].checked = !vehicleTypeList[index].checked;
                                  });
                                },
                                child: CategoryContainer(title: vehicleTypeList[index].title,  selected: vehicleTypeList[index].checked, path: vehicleTypeList[index].path,)));
                      }),
                      )
                    ),
                    Gap(10),
                    Text("Vehicle Mode",style: bold14Black,),
                    const Gap( 10),
                    SizedBox(
                        height: MediaQuery.of(context).size.height*0.18,
                        width: double.infinity,
                        child: GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 3,
                          children: List.generate(vehicleModeList.length, (index){
                            return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    vehicleModeList[index].checked = !vehicleModeList[index].checked;
                                  });
                                },
                                child: CategoryContainer(title: vehicleModeList[index].title,  selected: vehicleModeList[index].checked, path: vehicleModeList[index].path,));
                          }),
                        )
                    ),
                    const Gap( 20),
                    Text(
                      "Your Location",
                      style: bold14Black,
                    ),
                    const Gap( 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        Text(
                          "Latitude: ${lat} Longitude: ${lon}",
                          style: bold14Black,
                        ),
                      ],
                    ),
                    const Gap( 20),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LocationDetails(latLng: LatLng(lat, lon),))).then((value){
                           setState(() {
                             latlng = value;
                             lat = latlng.latitude;
                             lon = latlng.longitude;
                           });

                        });
                      },
                      child: SmoothButton(
                        iconData: Icons.add_circle_outline,
                        title: "add",
                      ),
                    ),
                    const Gap(20),
                    GestureDetector(
                      onTap: (){
                        createService();
                        // getMechanicId();
                      },
                      child: SmoothButton(

                        title: "Save",
                      ),
                    ),
                    const Gap( 20),
                  ]),
            ),
          ),
          // Container(
          //   child: Image.memory(_imageBytes!),
          // )
        ],
      ),
    );
  }
}
