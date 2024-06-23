import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Business%20Screens/create_business.dart';
import 'package:fyp_orvba/Common/location_details.dart';
import 'package:fyp_orvba/Common/profile.dart';
import 'package:fyp_orvba/Common/welcome_screen.dart';
import 'package:fyp_orvba/Customer%20Screens/customer_dashboard.dart';

import 'Common/auth/login_screen.dart';
import 'Common/auth/user_signup.dart';
import 'Customer Screens/breakdown_screen.dart';


final FirebaseDatabase database = FirebaseDatabase.instance;
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDcHMX8hyVJpgBWhe__zIdb9rW568HZbgQ",
      authDomain: "persuasive-feat-415112.firebaseapp.com",
      projectId: "persuasive-feat-415112",
      storageBucket: "persuasive-feat-415112.appspot.com",
      messagingSenderId: "688802085513",
      appId: "1:688802085513:android:617cd4533cc94f79c16458",
      databaseURL: "https://persuasive-feat-415112-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>const WelcomeScreen(),
        '/login': (context) =>  userLogin(),
        '/register': (context) => const userSignup(),
        '/profile': (context) => ProfileScreen(),
        '/breakdown': (context)=> BreakdownScreen(),
        '/customer': (context)=>const CustomerDashboard(),
        '/createBusiness': (context)=> CreateBusiness(),
        '/location': (context)=> LocationDetails(),
      },
    );
  }
}
