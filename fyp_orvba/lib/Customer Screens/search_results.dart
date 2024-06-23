import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:fyp_orvba/Customer%20Screens/search_results_details.dart';
import 'package:latlong2/latlong.dart';
import '../Utils/styles/textStyles.dart';
import 'breakdown_screen.dart';
import 'customer_dashboard.dart';
import 'package:http/http.dart' as http;

class SearchResults extends StatefulWidget {
  VehicleModel? vehicleType, vehicleCategory, vehicleMode;
  BreakdownModel? breakDownItem;
  LatLng? latLng;
  bool showAll;

  SearchResults(
      {super.key,
      this.vehicleType,
      this.vehicleCategory,
      this.vehicleMode,
      this.breakDownItem,
      this.latLng,
      this.showAll = false
      });

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  double value = 3.5;
  int range = 1200;
  bool isLoading = false;
  List<Map<String, dynamic>> servicesList = [];
  List<Map<String, dynamic>> reviewsList = [];
  List<Map<String, dynamic>> currentServicesList = [];
  List<Map<String, dynamic>> completeServicesList = [];
  List<Map<String, dynamic>> distanceList = [];

  Future<void> fetchDataOnce() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child("services");
    _databaseReference.onValue.listen((event) {
      setState(() {
        servicesList.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) async{
              value['id'] = key;
              double distance = calculateDistance(widget.latLng!.latitude,widget.latLng!.longitude, value["lat"], value["lon"]);
              value["distance"] = distance;
              servicesList.add(value.cast<String, dynamic>());
            });
          }
        }
      });
    });
    await fetchReviews();
  }
  Future<void> fetchReviews() async {
    final _databaseReference =
    FirebaseDatabase.instance.ref().child("reviews");
    _databaseReference.onValue.listen((event) {
      setState(() {
        reviewsList.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) async{
              value['id'] = key;
              reviewsList.add(value.cast<String, dynamic>());
            });
          }
        }
      });
    });
  }

  void RefineData() async {

    await fetchDataOnce();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });

    currentServicesList.clear();
    completeServicesList.clear();
    servicesList.forEach((Map<String, dynamic> service) {
     if(widget.showAll == true){
       if (double.parse(service["distance"].toStringAsFixed(0)) <= range) {
         setState(() {
           currentServicesList.add(service);
         });
       }
     }else{
       if (service[widget.breakDownItem!.key] == true && service[widget.vehicleType!.title]==true && service[widget.vehicleMode!.title]==true && double.parse(service["distance"].toStringAsFixed(0)) <= range) {
         setState(() {
           currentServicesList.add(service);
         });
       }
     }
    });

    currentServicesList.forEach((Map<String,dynamic> service){
      reviewsList.forEach((Map<String,dynamic> review){
        if(service["id"] == review["serviceId"]){
          service["rating"] = review["rating"];
        }
        setState(() {
          completeServicesList.add(service);
        });
      });
    });

    print(currentServicesList);
  }

  Future<Map<String, dynamic>> getDistance(LatLng dLatLng, LatLng sLatLng) async{

    final url = Uri.parse('https://distance-calculation-api-by-pizza-api.p.rapidapi.com/distance?lat1=${dLatLng.latitude}&lon1=${dLatLng.longitude}&lat2=${sLatLng.latitude}&lon2=${sLatLng.longitude}&metric=km');

    final headers = {
      'x-rapidapi-key': '0dd97e1934msh64ce609c0180674p1aa300jsncdb37bc4273d',
      'x-rapidapi-host': 'distance-calculation-api-by-pizza-api.p.rapidapi.com',
    };

    http.get(url, headers: headers)
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    })
        .catchError((error) {
      print('Error encountered: $error');
    });
    return {"":""};
  }
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {

    final distance = Distance();

    final double distanceInMeters = distance(
      LatLng(41.977226, -87.836723), // Chicago coordinates
      LatLng(40.730610, -73.935242), // New York coordinates
    );

    final double distanceInKm = distanceInMeters / 1000; // convert to kilometers
    return distanceInKm;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    RefineData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF3F54BE),
          foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: ElevatedButton(onPressed: (){
              setState(() {
                range--;
                RefineData();
              });
            }, child: Text("-"))),
            Expanded(child: Container(child: Text("$range km", textAlign: TextAlign.center,))),
            Expanded(child: ElevatedButton(onPressed: (){
              setState(() {
                range++;
                RefineData();
              });
            }, child: Text("+"))),
          ],
        )
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : completeServicesList.isNotEmpty
              ? GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 0.8,
                  children: List.generate(completeServicesList.length, (index) {
                    Map<String, dynamic> service = completeServicesList[index];
                    String title = service["title"].toString();
                    double val = 0;
                    if(service["rating"] != null){

                        val = double.parse(service["rating"].toString());
                    }
                    else{
                      val = 0;
                    }
                    if (title.length > 80) {
                      title = title.substring(0, 80);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchResultDetails(
                                        service: service,
                                      )));
                        },
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Color(0xFFFBF8F8),
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(1, 2),
                                      color: Color(0xFFE3E2E2),
                                      blurRadius: 2)
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  Image(
                                      image: NetworkImage(
                                          "${service["thumbnail"]}")),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    title + "...",
                                    style: bold14Black,
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingStars(
                                        value: val,
                                        starBuilder: (index, color) => Icon(
                                          Icons.star,
                                          color: color,
                                          size: 14,
                                        ),
                                        starCount: 5,
                                        starSize: 14,
                                        valueLabelColor:
                                            const Color(0xff9b9b9b),
                                        valueLabelTextStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 12.0),
                                        valueLabelRadius: 10,
                                        maxValue: 5,
                                        starSpacing: 2,
                                        maxValueVisibility: true,
                                        valueLabelVisibility: false,
                                        animationDuration:
                                            Duration(milliseconds: 1000),
                                        valueLabelPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 1, horizontal: 8),
                                        valueLabelMargin:
                                            const EdgeInsets.only(right: 8),
                                        starOffColor: const Color(0xffe7e8ea),
                                        starColor: Colors.yellow,
                                      ),
                                      Text(service["distance"].toStringAsFixed(0)+" km", style: bold13Black)
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                          "Rs. ${service["minPrice"]} - ${service["maxPrice"]}",
                                          style: bold16Red))
                                ],
                              ),
                            )),
                      ),
                    );
                  }),
                )
              : Center(
                  child: Text(
                    "No data available",
                    style: bold14Black,
                  ),
                ),
    );
  }
}
