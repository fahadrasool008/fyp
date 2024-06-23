import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../Utils/components/button.dart';
import 'finish.dart';

class OTP extends StatefulWidget {
  const OTP({super.key});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
                child: Container(
                  width: double.infinity,
              decoration: BoxDecoration(color: Color(0xff7159E3)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Phone Verification',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                    Text(textAlign: TextAlign.center,'Enter your OTP Code here',style: TextStyle(color: Colors.white,fontSize: 25),),
                  ],
                ),
              ),
            )),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: PinCodeTextField(
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(selectedColor: const Color(0xff7159E3)),
                      cursorColor: const Color(0xff7159E3),
                      obscureText: true,
                      appContext: context,
                      length: 5,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                children: [
                  Button(text: 'Verify Now', onpress: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>verifiedUser()));
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
