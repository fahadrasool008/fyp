import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:fyp_orvba/Common/location_details.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Utils/components/Buttons.dart';
import '../Utils/components/containers.dart';
import '../Utils/components/utilities.dart';
import '../Utils/styles/textStyles.dart';

class SearchResultDetails extends StatefulWidget {
  Map<String, dynamic>? service;
  SearchResultDetails({super.key, this.service});

  @override
  State<SearchResultDetails> createState() => _SearchResultDetailsState();
}

class _SearchResultDetailsState extends State<SearchResultDetails> {
  double avg = 0;
  List<Map<String, dynamic>> servicesList = [];
  String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
  TextEditingController commentController = TextEditingController();
  String userId = "";
  double rating = 0.0;
  String email = FirebaseAuth.instance.currentUser!.email.toString();
  Map<String, dynamic>? myRequest;
  Map<String, dynamic>? currentCustomer;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> reviewsList = [];
  List<Map<String, dynamic>> myReviewsList = [];
  List<Map<String, dynamic>> customers = [];
  bool isLoading = true;
  bool enabled = true;
  String status = "approved";
  String currentUser = FirebaseAuth.instance.currentUser!.email.toString();

  Future<void> fetchrequests() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child("requests");
    _databaseReference.onValue.listen((event) {
      setState(() {
        requests.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              requests.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final _databaseReference =
        FirebaseDatabase.instance.ref().child("customers");
    _databaseReference.onValue.listen((event) {
      setState(() {
        customers.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              customers.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
    await fetchReviews();
  }

  void getRequest() async {
    customers.clear();
    requests.clear();
    reviewsList.clear();
    String serviceId = widget.service!["id"];
    await fetchrequests();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });

    requests.forEach((Map<String, dynamic> request) {
      if (request["serviceId"] == serviceId) {
        if (request["customerEmail"] == email) {
          setState(() {
            myRequest = request;
          });
        } else {
          setState(() {
            enabled = true;
          });
        }
      }
    });

    customers.forEach((Map<String, dynamic> customer) {
      if (customer["email"].toString() == email) {
        setState(() {
          currentCustomer = customer;
          print("This is current customer$currentCustomer");
        });
      }
    });

    customers.forEach((Map<String, dynamic> customer) {
      if (customer["email"].toString() == email) {
        setState(() {
          currentCustomer = customer;
          print("This is current customer$currentCustomer");
        });
      }
    });
    myReviewsList.clear();
    reviewsList.forEach((Map<String, dynamic> review) {
      if (review["serviceId"].toString() == widget.service!["id"]) {
        setState(() {
          myReviewsList.add(review);
        });
      }
    });
    List<double> ratings =[];
    myReviewsList.forEach((Map<String, dynamic> review){
      ratings.add(
        double.parse(review["rating"].toString())
      );
    });
    double sumRatings = 0;
    for(int i=0; i<ratings.length; i++){
      sumRatings += ratings[i];
    }
    setState(() {
      avg = sumRatings/ratings.length;
    });

    checkReview();

    if (myRequest == null) {
      print("entered null request");
      setState(() {
        enabled = true;
      });
    } else {
      if (email == myRequest!["customerEmail"] &&
          widget.service!["id"] == myRequest!["serviceId"]) {
        setState(() {
          enabled = false;
        });
      } else {
        setState(() {
          enabled = true;
        });
      }
    }
  }

  void checkReview() {
    String serviceId = widget.service!["id"];
    bool ans = reviewsList.any((review) =>
        review["customerEmail"] == currentUser &&
        review["serviceId"] == serviceId);
    if (ans == true) {
      setState(() {
        status = "pending";
      });
    }
  }

  bool checkRequest() {
    String email = FirebaseAuth.instance.currentUser!.email.toString();
    String serviceId = widget.service!["id"].toString();

    return requests.any((request) =>
        request["customerEmail"] == email && request["serviceId"] == serviceId);
  }

  void createRequest() async {
    if (checkRequest()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Request Already Sent",
        style: bold13White,
      )));
    } else {
      Map<String, dynamic> requestData = {
        'customerEmail': userEmail,
        'serviceId': widget.service!["id"],
        'mechanicId': widget.service!["mechanicId"],
        'status': "pending"
      };
      FirebaseDatabase.instance
          .ref("requests")
          .push()
          .set(requestData)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Request Sent",
          style: bold13White,
        )));
      });
    }
  }

  void writeReview() {
    Map<String, dynamic> reviewsList = {
      'serviceId': widget.service!["id"],
      'customerName': currentCustomer!["fullname"],
      'rating': rating,
      'comment': commentController.text.toString(),
      'customerEmail': currentUser,
    };

    final _databaseReference = FirebaseDatabase.instance.ref();
    _databaseReference.child("reviews").push().set(reviewsList).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Reviewed Successfully")));
    });
  }

  Future<void> fetchReviews() async {
    final _databaseReference = FirebaseDatabase.instance.ref().child("reviews");
    _databaseReference.onValue.listen((event) {
      setState(() {
        reviewsList.clear();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? data =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              value['id'] = key;
              reviewsList.add(
                  value.cast<String, dynamic>()); // Cast to the correct type
            });
          }
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRequest();
    fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3F54BE),
          foregroundColor: Colors.white,
        ),
        body: isLoading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 12,
                      child: ListView(
                        children: [
                          Image(
                            image: NetworkImage(widget.service!["thumbnail"]),
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.service!["title"],
                            style: bold24Black,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "Rs. ${widget.service!["minPrice"]} - ${widget.service!["maxPrice"]}",
                                  style: bold16Red),
                              const Gap(50),
                              Text(
                                  "${widget.service!["distance"].toStringAsFixed(0)} km",
                                  style: bold13Black)
                            ],
                          ),
                          const Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(10),
                              Text(
                                "Service Description",
                                style: bold18Black,
                              ),
                              const Gap(10),
                              Text(
                                widget.service!["description"],
                                style: bold13Black,
                              )
                            ],
                          ),
                          const Divider(),
                          if (!enabled)
                            if (myRequest!["status"] == "approved")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Gap(10),
                                    Text(
                                      "Ratings & Reviews",
                                      style: bold18Black,
                                    ),
                                    CustomRating(
                                      value: avg,
                                      size: 24,
                                      valueLabel: true,
                                    ),
                                    const Gap(20),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: myReviewsList.length,
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> item =
                                              myReviewsList[index];
                                          return ReviewContainer(
                                              value: item["rating"].toDouble(),
                                              customerName:
                                                  item["customerName"],
                                              comment: item["comment"]);
                                        }),
                                    if (status == "approved")
                                      Column(
                                      children: [
                                        SizedBox(
                                            width: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                "Review this service",
                                                style: bold13Black,
                                              ),
                                            )),
                                        CustomTextField(
                                          controller: commentController,
                                          keyoardType: TextInputType.text,
                                        ),
                                        Gap(20),
                                        RatingStars(
                                          value: rating,
                                          onValueChanged: (value) {
                                            setState(() {
                                              rating = value;
                                            });
                                          },
                                          starSize: 30,
                                          starSpacing: size.width * 0.09,
                                        ),
                                        Gap(40),
                                        TextButton(
                                            onPressed: () {
                                              writeReview();
                                              commentController.clear();
                                              getRequest();
                                            },
                                            child: Text("Submit"))
                                      ],
                                    )
                                  ],
                                ),
                          if (enabled)
                            Container(
                                height: 250,
                                child: Center(
                                  child: Text("No Reviews Yet"),
                                ))
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: enabled
                                    ? () {
                                        setState(() {
                                          createRequest();
                                        });
                                      }
                                    : () {},
                                child: SmoothButton(
                                  title: "Request Service",
                                  backColor: Color(0xFFECA234),
                                  enabled: enabled,
                                ),
                              ),
                            ),
                            Gap(10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LocationDetails(
                                                isCustomer: true,
                                                latLng: LatLng(
                                                    widget.service!["lat"],
                                                    widget.service!["lon"]),
                                              )));
                                },
                                child: SmoothButton(
                                  title: "Track Location",
                                  backColor: Color(0xFFEC343F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ));
  }
}

/*

 */
