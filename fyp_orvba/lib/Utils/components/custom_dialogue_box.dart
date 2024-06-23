import 'package:flutter/material.dart';
import 'package:fyp_orvba/Utils/styles/textStyles.dart';
import 'package:gap/gap.dart';

Dialog CustomDialog(BuildContext context){
  Size _size = MediaQuery.of(context).size;
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),

    //this right here
    child: Container(
      height: _size.height/4.8,
      width: _size.width*0.8,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(offset: Offset(0, -1), color: Colors.grey, spreadRadius: 1, blurRadius: 4)
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Confirm",style: bold18Black,),
            ),
          ),
          const Gap(30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Text("All your data will be lost",style: bold14Black,),
                Text("All you sure?",style: bold14Black,),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.zero))),
                            onPressed: (){
                              Navigator.pop(context,true);
                            }, child: Text("Yes",style: bold13White,)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.zero))),
                            onPressed: (){
                              Navigator.pop(context,false);
                            }, child: Text("No",style: bold13White,)),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}