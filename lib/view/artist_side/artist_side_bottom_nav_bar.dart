import 'dart:convert';

import 'package:artist/core/utils/responsive.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_submission_type_screen.dart';
import 'package:artist/view/artist_side/artist_my_art_page/artist_my_art_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screen.dart';
import 'package:artist/view/artist_side/artist_order_page/artist_order_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/colors.dart';
import '../../config/toast.dart';
import '../../core/api_service/base_url.dart';
import 'artist_home_page/artist_home_screen.dart';
import 'package:http/http.dart' as http;
class ArtistSideBottomNavBar extends StatefulWidget {
  final int index;

  const ArtistSideBottomNavBar({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  _ArtistSideBottomNavBarState createState() => _ArtistSideBottomNavBarState();
}

class _ArtistSideBottomNavBarState extends State<ArtistSideBottomNavBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ArtistHomeScreen(),
    ArtistMyArtScreen(),
    ArtistSubmissionTypeScreen(),
    ArtistOrderScreen(),
    ArtistProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _selectedIndex = widget.index;
    checkLoginStatus(context);
    super.initState();
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ No token found, logging out...");
      return;
    }

    const String apiUrl = "$serverUrl/verifyToken";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        print("✅ Token is valid: ${data["message"]}");
      } else {
        print("❌ Token is invalid or expired: ${data["message"]}");
        showToast(message: data["message"]);
        _logout(context);
      }
    } catch (e) {
      print("⚠️ Error verifying token: $e");
    }
  }

  _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: white,
            elevation: 20.0,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                backgroundColor: white,
                icon: _selectedIndex == 0
                    ? Image.asset(
                        "assets/bottom_navigation_bar_icon/home_black.png",
                        height: 26,
                        width: 26,
                      )
                    : Image.asset(
                        "assets/bottom_navigation_bar_icon/home_grey.png",
                        height: 24,
                        width: 24,
                      ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                backgroundColor: white,
                icon: _selectedIndex == 1
                    ? Image.asset(
                        "assets/bottom_navigation_bar_icon/art_black.png",
                        height: 28,
                        width: 28,
                      )
                    : Image.asset(
                        "assets/bottom_navigation_bar_icon/art_grey.png",
                        height: 26,
                        width: 26,
                      ),
                label: 'My Art',
              ),
              BottomNavigationBarItem(
                backgroundColor: white,
                icon: SizedBox(),
                label: '',
              ),
              BottomNavigationBarItem(
                backgroundColor: white,
                icon: _selectedIndex == 3
                    ? Image.asset(
                        "assets/bottom_navigation_bar_icon/cart_black.png",
                        height: 26,
                        width: 26,
                      )
                    : Image.asset(
                        "assets/bottom_navigation_bar_icon/cart_grey.png",
                        height: 24,
                        width: 24,
                      ),
                // icon: Image.asset("assets/my_order.png",width: 24.00,height: 24.00,),
                label: 'Order',
              ),
              BottomNavigationBarItem(
                backgroundColor: white,
                icon: _selectedIndex == 4
                    ? Image.asset(
                        "assets/bottom_navigation_bar_icon/profile_black.png",
                        height: 26,
                        width: 26,
                      )
                    : Image.asset(
                        "assets/bottom_navigation_bar_icon/profile_grey.png",
                        height: 24,
                        width: 24,
                      ),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index != 2) {
                _onItemTapped(index);
              }
            },
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.poppins(
              color: textBlack,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              color: textGray,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          // Center floating "+" button
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
              child: Container(
                height: Responsive.getWidth(60),
                width: Responsive.getWidth(60),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: Responsive.getWidth(28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
