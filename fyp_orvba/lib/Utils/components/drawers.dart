
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_orvba/Utils/components/utilities.dart';
import 'package:gap/gap.dart';

import '../styles/textStyles.dart';

class MyDrawer extends StatefulWidget {
  VoidCallback? onAvatarPressed;
  VoidCallback? onHomePressed;
  VoidCallback? onNotifyPressed;
  String? profilePhoto;
  String? userName;
  BuildContext? myContext;
  MyDrawer({super.key, this.onAvatarPressed, this.onHomePressed,this.onNotifyPressed, this.profilePhoto, this.userName,this.myContext});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Color selectedColor = Colors.blueAccent;
  Color unSelectedColor = const Color(0xff3F54BE);
  bool homeSelected = false;
  bool notifySelected = false;
  bool logoutSelected = false;
  @override
  Widget build(BuildContext context) {
    return  Container(
      color: const Color(0xff3F54BE),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 GestureDetector(
                   onTap: widget.onAvatarPressed,
                   child:  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 32,
                    child: Image(image: AssetImage(widget.profilePhoto??"assets/rm-cartoon.png")),
                                   ),
                 ),
                GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.cancel, color: Colors.white,))
              ],
            ),
            const Gap( 4),
          Text("Welcome!", style: bold18White,),
          Text(widget.userName??"Fahad Rasool",style: bold18White,),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: homeSelected == true? selectedColor:unSelectedColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          homeSelected = true;
                          notifySelected = false;
                          logoutSelected = false;
                        });
                      },
                      child: ListTile(
                        leading: const Icon(Icons.home_outlined,color: Colors.white,),
                        title: Text("Home",style: bold13White,),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: notifySelected == true? selectedColor:unSelectedColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          homeSelected = false;
                          notifySelected = true;
                          logoutSelected = false;
                        });
                      },
                      child: ListTile(
                        leading: const Icon(Icons.notifications_none_outlined,color: Colors.white,),
                        title: Text("Notifications",style: bold13White,),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: logoutSelected == true? selectedColor:unSelectedColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          homeSelected = false;
                          notifySelected = false;
                          logoutSelected = true;
                        });
                      },
                      child: ListTile(
                        leading: const Icon(Icons.logout,color: Colors.white,),
                        title: Text("Logout",style: bold13White,),
                        onTap: () async{
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}