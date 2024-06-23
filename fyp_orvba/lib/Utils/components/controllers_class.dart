import 'package:flutter/cupertino.dart';

class Controllers{
  TextEditingController fieldController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Controllers({ required TextEditingController fieldController, required TextEditingController priceControlle}){
    this.fieldController = fieldController;
    this.priceController = priceControlle;
  }
}