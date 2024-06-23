import "package:flutter/material.dart";
import 'package:gap/gap.dart';

import '../Utils/components/button.dart';
import 'auth/admin_checker.dart';
import 'auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            const Expanded(
              flex: 2,
              child: Flexible(child: Image(image: AssetImage('assets/car.jpg'))),
            ),
            const Expanded(
              flex: 2,
              child: Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome',style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(textAlign: TextAlign.center,'To continue please select your role that best define your interest',style: TextStyle(fontSize: 20),),
                    ),
                  ],
                ),
              ),
            ),
            Gap(260),
            Expanded(
              child: Flexible(
                child: Column(
                  children: [
                    Button(
                      text: 'User',
                      onpress: () {
                        setState(() {
                          setAdmin(false);
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>  userLogin(isAdmin: false,)),
                        );
                      },
                    ),
                    const Gap(12),
                    GestureDetector(
                        onTap: (){
                          setState(() {
                            setAdmin(true);
                          });
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> userLogin(isAdmin: true,)));
                        },
                        child: const uniqueButton(text: 'Mechanic'))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
