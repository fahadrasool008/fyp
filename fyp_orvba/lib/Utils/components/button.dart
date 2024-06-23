import 'package:flutter/material.dart';

import '../styles/textStyles.dart';

class Button extends StatefulWidget {
  final String text;
  final VoidCallback onpress;
  const Button({super.key,required this.text, required this.onpress});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: widget.onpress,
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff3F54BE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(widget.text, style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),)),
        ),
      ),
    );
  }
}

class uniqueButton extends StatefulWidget {
  final String text;
  const uniqueButton({super.key, required this.text});

  @override
  State<uniqueButton> createState() => _uniqueButtonState();
}

class _uniqueButtonState extends State<uniqueButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Flexible(
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xff3F54BE),),
          ),
          child: Center(child: Text(widget.text, style: const TextStyle(color:  Color(0xff3F54BE),fontWeight: FontWeight.bold,fontSize: 20),)),
        ),
      ),
    );
  }
}


class MyTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
   MyTextButton({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff3F54BE),
        ),
        child: Center(child: Text(title, style: style13boldWhite,)),
      ),
    );
  }
}
