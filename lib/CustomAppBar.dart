import 'package:flutter/material.dart';
import 'main.dart';

class CustomAppBar extends StatelessWidget {
  final List<BottomNavigationBarItem> bottomBarItems = [];

  CustomAppBar() {
    bottomBarItems.add(
      BottomNavigationBarItem(
        activeIcon: Icon(
          Icons.map,
          color: appTheme.primaryColor,
        ),
        icon: Icon(Icons.map, color: Colors.black),
        title: Text("Explore", style: TextStyle(color: Colors.black)),
      )
    );
    bottomBarItems.add(
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.map,
            color: appTheme.primaryColor,
          ),
          icon: Icon(Icons.favorite, color: Colors.black),
          title: Text("Watch List", style: TextStyle(color: Colors.black)),
        )
    );
    bottomBarItems.add(
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.map,
            color: appTheme.primaryColor,
          ),
          icon: Icon(Icons.local_offer, color: Colors.black),
          title: Text("Deals", style: TextStyle(color: Colors.black)),
        )
    );
    bottomBarItems.add(
        BottomNavigationBarItem(
          activeIcon: Icon(
            Icons.map,
            color: appTheme.primaryColor,
          ),
          icon: Icon(Icons.notifications, color: Colors.black),
          title: Text("Notifications", style: TextStyle(color: Colors.black)),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 15,
      child: BottomNavigationBar(
        currentIndex: 0,
        items: bottomBarItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
