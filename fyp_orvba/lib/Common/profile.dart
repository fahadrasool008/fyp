import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Common/auth/login_screen.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../Utils/components/custom_dialogue_box.dart';
import '../Utils/components/utilities.dart';
import '../Utils/styles/textStyles.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

class ProfileScreen extends StatefulWidget {
  String? userTitle;
  ProfileScreen({super.key, this.userTitle});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController monthController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> currentServices = [];
  List<Map<String, dynamic>> currentReviews = [];
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic>? currentUser;
  String url = "";
  final _database = FirebaseDatabase.instance.ref();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  ImagePicker imagePicker = ImagePicker();
  XFile? image;

  pickImage() async {
    XFile? img = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  Future<Map<String, dynamic>> uploadImageToFirebase(String imagePath) async {
    String tempPath = 'profilePhotos/${Path.basename(imagePath)}';
    try {
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(tempPath);
      firebase_storage.UploadTask uploadTask = ref.putFile(File(imagePath));
      await uploadTask.whenComplete(() => print('Image Uploaded'));
      String tempURl = await ref.getDownloadURL();
      Map<String, dynamic> pathObj = {"url": tempURl, "path": tempPath};
      return pathObj;
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<void> fetchCustomers() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child(widget.userTitle!);
    _databaseReference.onValue.listen((event) {
      setState(() {
        users.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              users.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    if (widget.userTitle == "mechanics") {
      await fetchServices();
    }
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
    String email = FirebaseAuth.instance.currentUser!.email.toString();
    await fetchCustomers();
    await Future.delayed(Duration(seconds: 1));
    users.forEach((Map<String, dynamic> user) {
      if (user["email"] == email) {
        setState(() {
          currentUser = user;
        });
      }
    });
    services.forEach((Map<String, dynamic> service) {
      if (service["mechanicId"] == currentUser!["id"]) {
        setState(() {
          currentServices.add(service);
        });
      }
    });

    currentServices.forEach((Map<String, dynamic> service) {
      reviews.forEach((Map<String, dynamic> review) {
        if (service["id"] == review["serviceId"]) {
          setState(() {
            currentReviews.add(review);
          });
        }
      });
    });
    loadData();
  }

  Future<void> DeleteUserAndData(BuildContext context) async {
    // print(currentReviews.toString()+"Current Reviews peeche");
    // print(currentServices.toString()+"Current Services peeche");
    // print(currentUser.toString()+"Current user peeche");

    currentReviews.forEach((Map<String, dynamic> review) async {
      await deleteItem(review, "reviews");
    });
    currentServices.forEach((Map<String, dynamic> service) async {
      await deleteItemWithPath(service, "services");
    });

    await deleteItemWithPath(currentUser!, widget.userTitle.toString());
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        print('User deleted successfully.');
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('Failed to delete user: $e');
      // Handle the exception appropriately
    }
    await Future.delayed(const Duration(seconds: 3));
    if (widget.userTitle! == "mechanics") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => userLogin(
                  isAdmin: true,
                )),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => userLogin(
                  isAdmin: false,
                )),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> deleteItem(Map<String, dynamic> item, String doc) async {
    final DatabaseReference _database = FirebaseDatabase.instance.ref();
    try {
      await _database.child(doc).child(item["id"]).remove();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting data: $e')));
    }
  }

  Future<void> deleteItemWithPath(Map<String, dynamic> item, String doc) async {
    final DatabaseReference _database = FirebaseDatabase.instance.ref();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(item["path"]);
    try {
      await _database.child(doc).child(item["id"]).remove();
      await ref.delete();
      print('Image deleted successfully');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting data: $e')));
    }
  }

  void deleteImage(String path) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(path);
    await ref.delete();
    print('Image deleted successfully');
  }

  void UpdateData() async {
    final DatabaseReference _database2 = FirebaseDatabase.instance.ref();
    Map<String, dynamic> obj = {};
    if (image != null) {
      obj = await uploadImageToFirebase(image!.path);
      if(currentUser!["path"] != null){
        deleteImage(currentUser!["path"]);
      }
    }
    String dob =
        "${dayController.text}/${monthController.text}/${yearController.text}";
    Map<String, dynamic> data = {
      'fullname': fNameController.text.toString(),
      'username': lNameController.text.toString(),
      'dob': dob,
      'email': emailController.text.toString(),
      'contact': phoneController.text.toString(),
      'url': obj["url"] ??= currentUser!["url"],
      'path': obj["path"] ?? currentUser!["path"]
    };
    await _database2
        .child(widget.userTitle!)
        .child(currentUser!["id"])
        .update(data)
        .then((_) {
      print("Data updated successfully");
    }).catchError((error) {
      print("Failed to update data: $error");
    });
    ;
  }

  void loadData() {
    String date = currentUser!["dob"];
    List<String> dateList = date.split('/');

    fNameController.text = currentUser!["fullname"];
    lNameController.text = currentUser!["username"];
    emailController.text = currentUser!["email"];
    phoneController.text = currentUser!["contact"];
    dayController.text = dateList[0];
    monthController.text = dateList[1];
    yearController.text = dateList[2];
    url = currentUser!["url"];
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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: Text(
          "Profile",
          style: bold18White,
        ),
      ),
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: 250,
          color: const Color(0xff3F54BE),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const Gap(30),
              Center(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      radius: 130,
                      backgroundColor: Colors.white,
                      child: image != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(image!.path)),
                              radius: 125,
                            )
                          : CircleAvatar(
                              radius: 125,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(url),
                            ),
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          radius: 30,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 25,
                          )),
                    )
                  ],
                ),
              ),
              // CircleAvatar(
              //   radius: 130,
              //   backgroundColor: Colors.white,
              //   child: CircleAvatar(
              //     backgroundImage: NetworkImage(url),
              //     radius: 125,
              //   ),
              // ),
              const Gap(40),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: CustomTextField(
                      controller: fNameController,
                    )),
                    Gap(30),
                    Expanded(
                        child: CustomTextField(
                      controller: lNameController,
                    )),
                  ],
                ),
              ),
              const Gap(30),
              CustomTextField(
                controller: emailController,
              ),
              const Gap(30),
              CustomTextField(
                controller: phoneController,
              ),
              const Gap(30),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: CustomTextField(
                      controller: dayController,
                    )),
                    const Gap(30),
                    Expanded(
                        child: CustomTextField(
                      controller: monthController,
                    )),
                    const Gap(30),
                    Expanded(
                        child: CustomTextField(
                      controller: yearController,
                    )),
                  ],
                ),
              ),
              const Gap(30),
              SizedBox(
                  height: 60,
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff3F54BE),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                      onPressed: () {
                        UpdateData();
                      },
                      child: Text(
                        "Update Profile",
                        style: bold13White,
                      ))),
              const Gap(15),
              SizedBox(
                height: 60,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero))),
                    onPressed: () async {
                      final res = await showDialog(
                          context: context,
                          builder: (context) => CustomDialog(context));
                      if (res == true) {
                        await DeleteUserAndData(context);
                      }
                    },
                    child: Text(
                      "Delete This Account",
                      style: bold13White,
                    )),
              )
            ],
          ),
        )
      ]),
    );
  }
}
