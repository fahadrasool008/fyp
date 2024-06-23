import 'package:flutter/material.dart';
import 'package:fyp_orvba/Utils/components/utilities.dart';
import 'package:gap/gap.dart';
import '../styles/textStyles.dart';


class ModeContainer extends StatelessWidget {
  final String title;
  bool checked;
  ModeContainer({super.key , required this.title, this.checked = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: checked? const Color(0xff3F54BE):Color(0xffECEFF8),
          borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(offset: Offset(2, 3), blurRadius: 5, spreadRadius: -3 ,color: Color(0xffB6B4B4FF)),
            ]
        ),
        child: Center(child: Text(title.toUpperCase(),style:checked?bold13White:bold13Black,)),
      ),
    );
  }
}

class CategoryContainer extends StatelessWidget {
  bool selected;
  String path, title;
  double width;
  CategoryContainer({super.key, this.selected = false, this.path ="", this.title = "", this.width = 60});

  selectItem(){
    if(selected == true){
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(Icons.check_circle, color: Colors.green, size: 30,),
      );
    }
    else{
      return Text("");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
              color: Color(0xffECEFF8),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(offset: Offset(2, 3), blurRadius: 5, spreadRadius: -3 ,color: Color(0xffB6B4B4FF)),
              ]

          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(path != "")
              Image(image: AssetImage(path),width: width,),
              Text(title.toUpperCase(),style: width !=60? bold9Black:bold13Black,textAlign: TextAlign.center,)
            ],
          ),
        ),
        selectItem(),


      ],
    );
  }
}

class ReviewContainer extends StatelessWidget {
  double value;
  String customerName,comment;
  ReviewContainer({super.key, this.value = 0, required this.customerName, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              customerName,
              style: bold13Black,
            ),
            Gap(10),
            CustomRating(
              value: value,
              size: 16,
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: Text(
            comment,
            style: Normal13Black,
            textAlign: TextAlign.justify,
          ),
        ),
        Divider(),
      ],
    );
  }
}

class ServicesContainer extends StatelessWidget {
  String url;
  String title;
  VoidCallback? onPressed;
  bool isNetworkImage;
  ServicesContainer({super.key, required this.url, required this.title, this.onPressed, this.isNetworkImage = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color:  Colors.white,
            boxShadow: const [
              BoxShadow(
                  offset: Offset(2, 3),
                  blurRadius: 5,
                  spreadRadius: -1,
                  color: Color(0xffB6B4B4))
            ]),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            isNetworkImage?Image(image: NetworkImage(url)):Image(image: AssetImage(url), width: 100,),
            Text(title,style: bold14Black,),
          ],
        ),
      ),
    );
  }
}


class ServicesContainer2 extends StatelessWidget {
  String url;
  String title;
  VoidCallback? onPressed;
  String min;
  String max;
  ServicesContainer2({super.key, required this.url, required this.title, this.onPressed, this.min="0",this.max ="0"});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:  1.0, vertical: 0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color:  Colors.white,
              boxShadow: const [
                BoxShadow(
                    offset: Offset(2, 3),
                    blurRadius: 5,
                    spreadRadius: -1,
                    color: Color(0xffB6B4B4))
              ]),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image(image: NetworkImage(url),width: double.infinity, fit: BoxFit.cover,),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,style: bold14Black,),
                    Gap(10),
                    Text("Rs. $min - Rs. $max",style: bold16Red,)
                  ],
                )

              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BreakDownContainer extends StatelessWidget {
  String title;
  String path;
  BreakDownContainer({super.key, required this.title, required this.path});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color:  Color(0xFFDAE2F1),
        ),
        child: Column(
          children: [
            Gap(20),
            Image.asset(path, width: size.width*0.2,),
            Spacer(),
            Container(
              height: size.height*0.06,
              color: Color(0xFF3F54BE),
              child:  Center(
                child: Text(title, style: bold13White,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

