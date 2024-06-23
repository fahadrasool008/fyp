import 'package:flutter/material.dart';

import '../Utils/components/Buttons.dart';


class SetLocation extends StatelessWidget {
  const SetLocation({super.key});

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
      ),
      body: Stack(
        children: [
          Image(image: AssetImage("assets/map.png"),height: 950, fit: BoxFit.fitHeight,),
          Positioned(
            bottom: 20,
            left: 6,
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width/1.05,
                child: SmoothButton(title: "Use Current Location")),
          ),
        ],
      ),
    );
  }
}
