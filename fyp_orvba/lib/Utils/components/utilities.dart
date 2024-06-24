import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:gradient_circular_progress_indicator/gradient_circular_progress_indicator.dart';



class CustomRating extends StatefulWidget {
  double value;
  double size;
  bool valueLabel;
   CustomRating({super.key, required this.value, this.size = 14, this.valueLabel = false});

  @override
  State<CustomRating> createState() => _CustomRatingState();
}

class _CustomRatingState extends State<CustomRating> {
  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: widget.value,
      onValueChanged: (v) {

      },
      starBuilder: (index, color) => Icon(
        Icons.star,
        color: color,
        size: widget.size,
      ),
      starCount: 5,
      starSize: widget.size,
      valueLabelColor: Colors.white,
      valueLabelTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          fontSize: 16.0),
      valueLabelRadius: 10,
      maxValue: 5,
      starSpacing: 2,
      maxValueVisibility: true,
      valueLabelVisibility: widget.valueLabel,
      animationDuration: Duration(milliseconds: 1000),
      valueLabelPadding:const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      valueLabelMargin: const EdgeInsets.only(right: 8),
      starOffColor: const Color(0xffe7e8ea),
      starColor: Colors.yellow,
    );
  }
}

class CustomGradientProgressBar extends StatelessWidget {
  Color first;
  Color second;
  double value;

  Text text;
  CustomGradientProgressBar({super.key, required this.first, required this.second, required this.value, required this.text});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
        width: 95,
        height: 95,
        child: GradientCircularProgressIndicator(
          stroke: 12,
          progress: value,
          gradient: LinearGradient(
              colors: [first, second]),
          backgroundColor: Colors.grey,
          child: Center(child: text),

        )
    );
  }
}


class CustomTextField extends StatelessWidget {
  TextEditingController? controller = TextEditingController();
  TextInputType keyoardType;
  VoidCallback? onChanges;
  String hint;
  bool shadow;
  CustomTextField({super.key,  this.controller, this.keyoardType = TextInputType.text,this.hint = "",this.shadow = true, this.onChanges });

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration:  BoxDecoration(
          boxShadow: shadow==true?[
            BoxShadow(
                offset: Offset(2, 3),
                color: Color(0xFFD2C9C9),
                blurRadius: 5
            ),
            BoxShadow(
                offset: Offset(-1, -1),
                color: Color(0xFFD2C9C9),
                blurRadius: 5
            ),
          ]:[],
      ),
      child:  TextField(
        controller: controller,
        keyboardType: keyoardType,
        decoration:  InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: hint,
            border: const OutlineInputBorder(
                borderSide: BorderSide.none
            )
        ),
      ),
    );
  }
}


SnackBar ToastBar(String content){
  return SnackBar(
    content: Text(content)
  );
}




