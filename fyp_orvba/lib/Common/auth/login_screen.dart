import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp_orvba/Business%20Screens/business_dashboard.dart';
import 'package:fyp_orvba/Common/auth/user_signup.dart';
import 'package:fyp_orvba/Customer%20Screens/customer_dashboard.dart';
import 'package:fyp_orvba/Utils/components/utilities.dart';
import 'package:gap/gap.dart';
import '../../Utils/components/button.dart';
import '../../Utils/components/textbox.dart';
import '../../Utils/styles/textStyles.dart';


class userLogin extends StatefulWidget {
  bool isAdmin;
  userLogin({super.key, this.isAdmin= true});

  @override
  State<userLogin> createState() => _userLoginState();
}

class _userLoginState extends State<userLogin> {
  final _database = FirebaseDatabase.instance.ref();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  List<Map<String,dynamic>> receivedMechanicData =[];
  List<Map<String,dynamic>> receivedCustomerData =[];
  bool _isLoading = false;


  Future<void> fetchDataOnce(String path, List<Map<String,dynamic>> list) async {
    // await Future.delayed(Duration(seconds: 1));
    final _databaseReference = FirebaseDatabase.instance.ref().child(path);
     _databaseReference.onValue.listen((event) {
      setState(() {
        list.clear();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            value['id'] = key;
            list.add(value.cast<String, dynamic>()); // Cast to the correct type
          });
        }
      }
    });
    });
  }
  Future<void> _login() async {
    if(email.text.isNotEmpty && password.text.isNotEmpty) {
      if (widget.isAdmin == true) {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(Duration(seconds: 3));
        setState(() {
          _isLoading = false;
        });
        receivedMechanicData.forEach((Map<String, dynamic> item) {
          if (email.text == item["email"]) {
            setState(() async {
              await firebaseAuth
                  .signInWithEmailAndPassword(
                  email: email.text, password: password.text)
                  .then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: ((context) => const BusinessDashboard())));
              });
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(ToastBar("No users found"));

      } else {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(Duration(seconds: 3));
        setState(() {
          _isLoading = false;
        });
        receivedCustomerData.forEach((Map<String, dynamic> item) {
          if (email.text == item["email"]) {
            setState(() async {
              await firebaseAuth
                  .signInWithEmailAndPassword(
                  email: email.text, password: password.text)
                  .then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: ((context) => const CustomerDashboard())));
              });
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(ToastBar("No users found"));

      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(ToastBar("Enter email and password"));
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    fetchDataOnce("mechanics", receivedMechanicData);
    fetchDataOnce("customers", receivedCustomerData);
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(100),
              const Image(image: AssetImage('assets/car.jpg')),
             const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Please login to continue',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              const Gap(70),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  textBox(
                    text: 'Email',
                    icon: Icons.email,
                    controller: email,
                  ),
                  Gap(15),
                  textBox(
                    text: 'Password',
                    icon: Icons.lock,
                    controller: password,
                  ),
                  Gap(10),
                ],
              ),
              Column(
                children: [
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: _isLoading? Container(
                      child: Center(child: CircularProgressIndicator(backgroundColor: Colors.white, color: Colors.blue,)),
                    ) :Button(
                        text: 'Login',
                        onpress: () async {
                          await _login();
              
                        }),
                  ),
                  Gap(MediaQuery.of(context).size.height*0.21),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: style13boldBlack,),
                        Gap(2),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>userSignup()));
                          },
                          child: Text("Register now", style: style13boldBlue,)),
                      ],
                    ),
                  ),
                  const Gap(20),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
