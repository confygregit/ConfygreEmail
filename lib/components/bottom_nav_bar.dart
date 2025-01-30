import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  MyBottomNavBar({
    super.key,
    required this.onTabChange
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: GNav(
            color: Colors.grey.shade700,
            activeColor: Colors.grey[900],
            tabBackgroundColor: Colors.grey.shade100,
            mainAxisAlignment: MainAxisAlignment.center,
            tabBorderRadius: 16,
            onTabChange: (value) => onTabChange!(value),
            tabs: const [
              GButton(
                icon: Icons.swap_horiz_rounded,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              GButton(
                icon: Icons.table_chart_rounded,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              GButton(
                icon: Icons.settings_suggest_rounded,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              GButton(
                icon: Icons.account_circle_rounded,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ])
    );
  }
}
