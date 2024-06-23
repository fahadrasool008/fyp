import 'package:flutter/material.dart';

import '../../Utils/components/button.dart';
import 'login_screen.dart';


class verifiedUser extends StatefulWidget {
  String? title;
  String? subtitle;
  VoidCallback? onPress;
  verifiedUser({super.key, this.title="Congratulations!", this.subtitle="You are now verified user!", this.onPress});

  @override
  State<verifiedUser> createState() => _verifiedUserState();
}

class _verifiedUserState extends State<verifiedUser> {

  void _letsGo(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>userLogin()));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const Expanded(
            flex: 4,
            child: Flexible(child: Image(image: AssetImage('assets/check.jpg'))),
          ),
           Expanded(
            flex: 5,
            child: Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.title!,style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),),
                  Text(widget.subtitle!,textAlign: TextAlign.center,style: TextStyle(fontSize: 20),),
                ],
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            child: Flexible(
              child: Column(
                children: [
                  Button(
                    text: "Let's Go",
                    onpress: widget.onPress == null? _letsGo:widget.onPress!
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
