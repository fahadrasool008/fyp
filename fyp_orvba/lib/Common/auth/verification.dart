import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../Utils/components/button.dart';
import '../../Utils/components/textbox.dart';
import 'otp.dart';


class mobileVerification extends StatefulWidget {
  const mobileVerification({super.key});

  @override
  State<mobileVerification> createState() => _mobileVerificationState();
}

class _mobileVerificationState extends State<mobileVerification> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            const Expanded(
              flex: 3,
              child: Flexible(child: Image(image: AssetImage('assets/pin.jpg'))),
            ),
            const Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Align(alignment: Alignment.topLeft,child: Text(textAlign: TextAlign.center,'Please verify your mobile number',style: TextStyle(fontSize: 20),)),
                  ),
                  Gap(10),
                  fullTextbox(text: "Enter your mobile no")
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Button(
                    text: 'Get Code',
                    onpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OTP()),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
