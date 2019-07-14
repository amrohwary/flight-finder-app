import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomAppBar.dart';
import 'CustomShapeClipper.dart';
import 'package:intl/intl.dart';
import 'flight_list.dart';
import 'package:cached_network_image/cached_network_image.dart';

Future<void> main() async {
  final FirebaseApp app = Platform.isIOS ? await FirebaseApp.configure(
    name: 'flight-finder-app-c81f7',
    options: const FirebaseOptions(
      googleAppID: '1:710712618295:ios:f1b24cd8e2a0e9f2',
      gcmSenderID: '710712618295',
      databaseURL: 'https://flight-finder-app-c81f7.firebaseio.com',),
  ) : null;

  runApp(MaterialApp(
    title: 'Flutter Demo',
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    theme: appTheme,
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CustomAppBar(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              HomeScreenTopPart(),
              homeScreenBottomPart,
              homeScreenBottomPart,
              homeScreenBottomPart,
            ],
          ),
        )
    );
  }
}

class HomeScreenTopPart extends StatefulWidget {
  @override
  _HomeScreenTopPartState createState() => _HomeScreenTopPartState();
}

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFFEF772C);

ThemeData appTheme = ThemeData(
  primaryColor: Color(0xFFF3791A),
  fontFamily: 'Oxygen',
);

List<String> locations = [];

TextStyle dropDownLabelStyle = TextStyle(color: Colors.white, fontSize: 16.0,);
TextStyle dropDownMenuItemsStyle = TextStyle(color: Colors.black, fontSize: 16.0,);

final searchFieldController = TextEditingController();

List<PopupMenuItem<int>> _buildPopupMenuItem() {
  List<PopupMenuItem<int>> popupMenuItems = List();
  for (int i = 0; i < locations.length; i++) {
    popupMenuItems.add(PopupMenuItem(child: Text(locations[i], style: dropDownMenuItemsStyle), value: 0,));
  }
  return popupMenuItems;
}

class _HomeScreenTopPartState extends State<HomeScreenTopPart> {
  var selectedLocationIndex = 0;
  var isFlightSelected = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  firstColor,
                  secondColor,
                ],
              ),
            ),
            height: 400.0,
            child: Column(
              children: <Widget>[
                SizedBox(height: 50.0,),
                StreamBuilder(
                  stream: Firestore.instance.collection('locations').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      addLocations(context, snapshot.data.documents);
                    return !snapshot.hasData
                        ? Container()
                        : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.location_on, color: Colors.white,),
                          SizedBox(width: 16,),
                          PopupMenuButton(
                            onSelected: (index) {
                              setState(() {
                                selectedLocationIndex = index;
                              });
                            },
                            child: Row(
                                children: <Widget>[
                                  Text(locations[selectedLocationIndex],
                                    style: dropDownLabelStyle,),
                                  Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white,),
                                ]
                            ),
                            itemBuilder: (BuildContext context) => _buildPopupMenuItem(),
                          ),
                          Spacer(),
                          Icon(Icons.settings, color: Colors.white,),
                        ],
                      ),
                    );
                  }
                ),
                SizedBox(height: 50.0),
                Text('Where would\nyou want to go?', style: TextStyle(fontSize: 24.0, color: Colors.white,), textAlign: TextAlign.center,),
                SizedBox(height: 30.0,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: TextField(
                      controller: searchFieldController,
                      style: dropDownMenuItemsStyle,
                      cursorColor: appTheme.primaryColor,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 13,),
                        suffixIcon: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InheritedFlightListing(
                                            fromLocation: locations[selectedLocationIndex],
                                            toLocation: searchFieldController.text,
                                            child: FlightListingScreen(),
                                          )
                                  )
                              );
                            },
                              child: Icon(Icons.search, color: Colors.black,)),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          setState(() {
                            isFlightSelected = true;
                          });
                        },
                        child: ChoiceChip(Icons.flight_takeoff, "Flights", isFlightSelected)
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: () {
                          setState(() {
                            isFlightSelected = false;
                          });
                        },
                        child: ChoiceChip(Icons.hotel, "Hotels", !isFlightSelected)
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class ChoiceChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isSelected;

  ChoiceChip(this.icon, this.text, this.isSelected);

  @override
  _ChoiceChipState createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8,),
      decoration: widget.isSelected ? BoxDecoration(color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            widget.icon,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            widget.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

var viewAllStyle = TextStyle(fontSize: 14, color: appTheme.primaryColor);

var homeScreenBottomPart = Column(
  children: <Widget>[
    Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text("Currently Watched Items", style: dropDownMenuItemsStyle),
          Spacer(),
          Text("VIEW ALL (12)", style: viewAllStyle),
        ],
      ),
    ),
    Container(
      height: 235,
      child: StreamBuilder(
        stream: Firestore.instance.collection('cities').orderBy('newPrice').snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData ? Center(child: Padding(padding: const EdgeInsets.only(right: 40, left: 20,),child: LinearProgressIndicator(),))
              : _buildCitiesList(context, snapshot.data.documents);
        },
      ),
    ),
  ],
);

addLocations(BuildContext context, List<DocumentSnapshot> snapshots) {
  locations.clear();
  for(int i = 0; i < snapshots.length; i++) {
    final Location location = Location.fromSnapshot(snapshots[i]);
    locations.add(location.name);
  }
}

class Location {
  final String name;
  Location.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        name = map['name'];

  Location.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

Widget _buildCitiesList(BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
      itemCount: snapshots.length,
      shrinkWrap: false,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index){
        return CityCard(city: City.fromSnapshot(snapshots[index]),);
      });
}

class City {
  final String imagePath, cityName, monthYear, discount;
  final int oldPrice, newPrice;

  City.fromMap(Map<String, dynamic> map)
      : assert(map['imagePath'] != null),
        assert(map['cityName'] != null),
        assert(map['monthYear'] != null),
        assert(map['discount'] != null),
        imagePath = map['imagePath'],
        cityName = map['cityName'],
        discount = map['discount'],
        monthYear = map['monthYear'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'];

  City.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

final formatCurrency = NumberFormat.simpleCurrency();

class CityCard extends StatelessWidget {
  final City city;

  CityCard({this.city});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 210.0,
                  width: 155,
                  child: CachedNetworkImage(
                    imageUrl: city.imagePath,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeInCurve: Curves.easeIn,
                    placeholder: (BuildContext context, String str) =>  Center(child: CircularProgressIndicator()),
                  )
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: 160,
                  height: 90,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.black.withOpacity(0)]
                      )
                    ),
                  )
                ),
                Positioned(
                  left:10,
                  bottom: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(city.cityName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                          Text(city.monthYear, style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white
                        ),
                          child: Text(
                              "${city.discount}%",
                              style: TextStyle(fontSize: 14, color: Colors.black))),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 5,
            ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 5),
              Text('${formatCurrency.format(city.newPrice)}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14,)),
              SizedBox(width: 5),
              Text('(${formatCurrency.format(city.oldPrice)})', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 10, decoration: TextDecoration.lineThrough)),
            ],
          ),
        ],
      ),
    );
  }
}
