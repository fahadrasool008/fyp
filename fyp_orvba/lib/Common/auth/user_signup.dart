import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Common/auth/admin_checker.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../../Utils/components/button.dart';
import '../../Utils/components/textbox.dart';
import '../../Utils/styles/textStyles.dart';
import 'login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

class userSignup extends StatefulWidget {
  const userSignup({super.key});

  @override
  State<userSignup> createState() => _userSignupState();
}

class _userSignupState extends State<userSignup> {
  final _database = FirebaseDatabase.instance.ref();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool isLoading = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController fullname = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController date = TextEditingController();
  ImagePicker imagePicker = ImagePicker();
  XFile? image;
  DateTime selectedDate = DateTime.now();

  pickImage() async {
    XFile? img = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }
  Future<Map<String, dynamic>> uploadImageToFirebase(String imagePath) async {
    String tempPath = 'profilePhotos/${Path.basename(imagePath)}';
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
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: selectedDate,
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        date.text = selectedDate.day.toString();
        date.text += "/" + selectedDate.month.toString();
        date.text += "/" + selectedDate.year.toString();
      });
  }

  void _signUpUser() async {
    // Extract values from text controllers
    String _fullname = fullname.text;
    String _username = username.text;
    String _email = email.text;
    String _password = password.text;
    String _contect = contact.text;
    String _dob = date.text;
    Map<String, dynamic> obj = await uploadImageToFirebase(image!.path);

    Map<String, dynamic> userSignupData = {
      'fullname': _fullname,
      'username': _username,
      'email': _email,
      'contact': _contect,
      'dob': _dob,
      'url': obj["url"],
      'path': obj["path"]
    };

    UserCredential? userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: _email, password: _password);
    if (userCredential.user != null) {
      if (isAdmin()) {
        _database.child('mechanics').push().set(userSignupData);
      } else {
        _database.child('customers').push().set(userSignupData);
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => userLogin())));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The email address is already in use.")));
    }
  }

  validateTextFields() {
    if (username.text.isNotEmpty &&
        contact.text.isNotEmpty &&
        email.text.isNotEmpty &&
        fullname.text.isNotEmpty &&
        password.text.isNotEmpty &&
        date.text.isNotEmpty) {
      int num =
          password.text.toString().compareTo(confirmPassword.text.toString());
      if (num != 0) {
        return 1;
      }
      return 0;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Gap(20),
             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                         CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          child: image !=null? CircleAvatar(
                            backgroundImage: FileImage(File(image!.path)),
                            radius: 75,
                          ):CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            pickImage();
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              radius: 20,
                              child: Icon(Icons.camera_alt_outlined, size: 25,)),
                        )
                      ],
                    )
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      textBox(
                        text: 'Full Name',
                        icon: Icons.person,
                        controller: fullname,
                      ),
                      Gap(15),
                      textBox(
                        text: 'Username',
                        icon: Icons.person,
                        controller: username,
                      ),
                      Gap(15),
                      textBox(
                        text: 'Email',
                        icon: Icons.email,
                        controller: email,
                      ),
                      Gap(15),
                      textBox(
                        text: 'Contact',
                        icon: Icons.phone,
                        controller: contact,
                      ),
                      Gap(15),
                      textBox(
                        text: 'Password',
                        icon: Icons.lock,
                        controller: password,
                      ),
                      Gap(15),
                      textBox(
                        text: 'Confirm Password',
                        icon: Icons.lock,
                        controller: confirmPassword,
                      ),
                      Gap(15),
                      textBox(
                        icon: Icons.date_range_sharp,
                        text: "Date of Birth",
                        controller: date,
                      ),
                      GestureDetector(
                        onTap: () {
                          selectDate(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 30, top: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Select Data of Birth",
                              style: bold13White,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: isLoading
                      ? Container(
                          child: Center(
                              child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.blue,
                          )),
                        )
                      : Button(
                          text: 'Sign Up',
                          onpress: () {
                            setState(() {
                              isLoading = true;
                            });
                            if (validateTextFields() == 0) {
                              _signUpUser();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Password did't match")));
                            }
                          }),
                ),
              ],
            ),
            const Gap(20),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: style13boldBlack,
                  ),
                  Gap(2),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => userLogin()));
                      },
                      child: Text(
                        "Login now",
                        style: style13boldBlue,
                      )),
                ],
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}
