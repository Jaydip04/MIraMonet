import 'dart:convert';

import 'package:artist/config/toast.dart';
import 'package:artist/view/user_side/cart_screen/cart_screen.dart';
import 'package:artist/view/user_side/gallery_screen/gallery_screen.dart';
import 'package:artist/view/user_side/home_screen/home_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screen.dart';
import 'package:artist/view/user_side/shop_screen/shop_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import 'package:http/http.dart' as http;

import '../../core/api_service/base_url.dart';
class UserSideBottomNavBar extends StatefulWidget {
  final int index;

  const UserSideBottomNavBar({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  _UserSideBottomNavBarState createState() => _UserSideBottomNavBarState();
}

class _UserSideBottomNavBarState extends State<UserSideBottomNavBar> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  static List<Widget> _widgetOptions = <Widget>[
    // HomeScreen(),
    HomeScreen(),
    const ShopScreen(),
    const GalleryScreen(),
    CartScreen(),
    const ProfileScreen()
    // MyCartScreen(),
    // LiveShopScreen(),
    // MainMyOrderScreen(),
    // ProfileScreen(),
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
    String? token = prefs.getString("UserToken");

    if (token == null || token.isEmpty) {
      print("❌ No token found, logging out...");
      return;
    }

    const String apiUrl = "${serverUrl}/verifyToken";
    // const String apiUrl = "${serverUrl}/test-token";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = json.decode(response.body);
      print('test : ${response.statusCode}');
      print('test : ${response.body}');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: white,
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
                    "assets/bottom_navigation_bar_icon/shop_black.png",
                    height: 27,
                    width: 27,
                  )
                : Image.asset(
                    "assets/bottom_navigation_bar_icon/shop_grey.png",
                    height: 25,
                    width: 25,
                  ),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            backgroundColor: white,
            icon: _selectedIndex == 2
                ? Image.asset(
                    "assets/bottom_navigation_bar_icon/gallery_black.png",
                    height: 26,
                    width: 26,
                  )
                : Image.asset(
                    "assets/bottom_navigation_bar_icon/gallery_grey.png",
                    height: 24,
                    width: 24,
                  ),
            label: 'Gallery',
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
            label: 'Cart',
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
        currentIndex: _selectedIndex!,
        unselectedItemColor: Color(0XFFA4A4A4),
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(
          color: black,
        ),
        selectedLabelStyle: GoogleFonts.poppins(
          color: textBlack,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        unselectedLabelStyle:  GoogleFonts.poppins(
          color: textGray,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        unselectedFontSize: 10,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
      ),
    );
  }
}
