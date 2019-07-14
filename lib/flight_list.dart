import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomShapeClipper.dart';
import 'main.dart';

final Color discountBackgroundColor = Color(0xFFFFE08D);
final Color flightBorderColor = Color(0xFFE6E6E6);
final Color chipBackgroundColor = Color(0xFFF6F6F6);

class InheritedFlightListing extends InheritedWidget {
  final String fromLocation, toLocation;
  InheritedFlightListing({this.fromLocation, this.toLocation, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedFlightListing of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedFlightListing);
}

class FlightListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Search Result",),
        centerTitle: true,
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          }
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            FlightListTopPart(),
            FlightListBottomPart(),
          ],
        ),
      ),
    );
  }
}

class FlightListBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Best Deals for Next 6 Months",
              style: dropDownMenuItemsStyle,
            ),
          ),
          SizedBox(height: 10),
          StreamBuilder(
            stream: Firestore.instance.collection('deals').snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData ?
              Center(child: Padding(padding: const EdgeInsets.only(right: 40, left: 20,),child: LinearProgressIndicator(),)) : _buildDealsList(context, snapshot.data.documents);
            },
          ),
        ],
      ),
    );
  }
}

class FlightDetails {
  final String airlines, date, discount, rating;
  final int oldPrice, newPrice;

  FlightDetails.fromMap(Map<String, dynamic> map)
      : assert(map['airlines'] != null),
        assert(map['date'] != null),
        assert(map['discount'] != null),
        assert(map['rating'] != null),
        airlines = map['airlines'],
        date = map['date'],
        discount = map['discount'],
        rating = map['rating'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'];

  FlightDetails.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

Widget _buildDealsList(BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
    itemCount: snapshots.length,
    shrinkWrap: true,
    physics: ClampingScrollPhysics(),
    scrollDirection: Axis.vertical,
    itemBuilder: (context, index){
      return FlightCard(flightDetails: FlightDetails.fromSnapshot(snapshots[index]),);
    });
}

class FlightCard extends StatelessWidget {
  final FlightDetails flightDetails;
  FlightCard({this.flightDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: flightBorderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '${formatCurrency.format(flightDetails.newPrice)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '(${formatCurrency.format(flightDetails.oldPrice)})',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: <Widget>[
                      FlightDetailChip(Icons.calendar_today, flightDetails.date),
                      FlightDetailChip(Icons.flight_takeoff, flightDetails.airlines),
                      FlightDetailChip(Icons.star, flightDetails.rating),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text('${flightDetails.discount}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: appTheme.primaryColor),),
              decoration: BoxDecoration(color: discountBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightDetailChip extends StatelessWidget {
  final IconData iconData;
  final String label;
  FlightDetailChip(this.iconData, this.label);
  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.black, fontSize: 14),
      backgroundColor: chipBackgroundColor,
      avatar: Icon(iconData, size: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
    );
  }
}


class FlightListTopPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  firstColor,
                  secondColor,
                ],
              ),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.symmetric(horizontal: 16),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${InheritedFlightListing.of(context).fromLocation}', style: TextStyle(fontSize: 16),),
                          Divider(color: Colors.grey, height: 20,),
                          Text('${InheritedFlightListing.of(context).toLocation}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 1,
                        child: Icon(Icons.import_export, color: Colors.black, size: 32)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

