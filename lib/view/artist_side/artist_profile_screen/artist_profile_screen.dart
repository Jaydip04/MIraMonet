import 'dart:convert';

import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_mira_monet_team_chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/colors.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/api_service/base_url.dart';
import '../../../core/models/customer_modell.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_text_2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacementNamed(context, '/');
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('UserToken');
  }

  Future<void> deleteAccount(String customerUniqueId) async {
    String? token = await _getToken();
    const String url = "$serverUrl/delete_account";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customer_unique_id": customerUniqueId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true) {
          _logout(context);
        }
        // final data = jsonDecode(response.body);
        print("✅ Account deleted successfully: $data");
      } else {
        print("❌ Failed to delete account: ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final String url = "https://miramonet.org/donate/";
  Future<void> _launchURL() async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    fetchCustomerData(customerUniqueId);
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  void fetchCustomerData(String customerUniqueId) async {
    ApiService apiService = ApiService();

    try {
      CustomerData customerData =
          await apiService.getCustomerData(customerUniqueId);
      print("customerData : $customerData");
      _updateControllers(customerData);
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  bool isLoading = true;

  String? imageUrl;
  String? name;
  bool? isMiramonet;
  String? miramonet_chat_id;
  void _updateControllers(CustomerData customerData) {
    setState(() {
      imageUrl = customerData.customerProfile;
      name = customerData.name;
      isMiramonet = customerData.isMiramonet;
      miramonet_chat_id = customerData.miramonet_chat_id;
      isLoading = false;
      print(name);
    });
  }

  void callMiramonetChat() async {
    setState(() {
      isLoading = true;
    });
    ApiService apiService = ApiService();

    try {
      final response =
      await apiService.miramonetChat(customerUniqueID.toString());
      print("Response Data: $response");
      print("Response Data: ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        final data = jsonDecode(response.body);
        print("Response Data: $data");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ArtistMiraMonetTeamChatScreen(
                  miramonet_chat_id: data['miramonet_chat_id'].toString(),
                )));
        // Navigator.pushNamed(
        //   context,
        //   '/User/Profile/MiraMonetTeamChatScreen',
        // );
      } else {
        setState(() {
          isLoading = false;
        });
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return isLoading
        ? Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.black,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              scrolledUnderElevation: 0.0,
              automaticallyImplyLeading: false,
              // centerTitle: true,
              centerTitle: false,
              title: Text(
                textAlign: TextAlign.start,
                "Profile",
                style: GoogleFonts.poppins(
                  letterSpacing: 1.5,
                  color: textBlack8,
                  fontSize: Responsive.getFontSize(20),
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              actions: [
                AnimationConfiguration.synchronized(
                  duration: const Duration(milliseconds: 2000),
                  child: SlideAnimation(
                    curve: Curves.easeInOut,
                    child: FadeInAnimation(
                      duration: const Duration(milliseconds: 1000),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/Artist/Notification',
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Stack(
                              children: [
                                Container(
                                    padding: EdgeInsets.all(6),
                                    width: Responsive.getWidth(32),
                                    height: Responsive.getWidth(32),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(249, 250, 251, 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.05),
                                          spreadRadius: 0,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(8)),
                                      border: Border.all(
                                        width: 1,
                                        color: Color.fromRGBO(0, 0, 0, 0.05),
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/bell_blank.png",
                                      width: Responsive.getWidth(24),
                                      height: Responsive.getHeight(24),
                                    )),
                                // Positioned(
                                //   top: 0,
                                //   right: 0,
                                //   child: Container(
                                //     width: 15,
                                //     height: 15,
                                //     decoration: BoxDecoration(
                                //         color: Colors.red,
                                //         borderRadius:
                                //             BorderRadius.circular(30)),
                                //     child: Center(
                                //         child: WantText2(
                                //             text: "1",
                                //             fontSize: Responsive.getWidth(10),
                                //             fontWeight: AppFontWeight.bold,
                                //             textColor: white)),
                                //   ),
                                // )
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: Responsive.getWidth(14),
                      right: Responsive.getWidth(24)),
                  child: Column(
                    children: [
                      Divider(
                        color: Color.fromRGBO(230, 230, 230, 1),
                      ),
                      // profileItemWidget(
                      //   context: context,
                      //   label: "My Details",
                      //   image: "assets/profile_image/details.png",
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //       context,
                      //       '/Artist/Profile/MyDetails',
                      //     );
                      //   },
                      // )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/Artist/Profile/MyDetails',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  // color: Colors.black.withOpacity(1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(50)),
                                  child: imageUrl == null
                                      ? CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey.shade300,
                                          child: Text(
                                            '${name![0].toUpperCase()}',
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 20,
                                          child: Image.network(
                                            imageUrl.toString(),
                                            height: Responsive.getWidth(40),
                                            width: Responsive.getWidth(40),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              WantText2(
                                  text: "My Account",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textBlack11)
                            ],
                          ),
                        ),
                        RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: Responsive.getWidth(20),
                              color: Color.fromRGBO(179, 179, 179, 1),
                            )),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Color.fromRGBO(230, 230, 230, 1),
                  thickness: 8,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: Responsive.getWidth(14),
                      right: Responsive.getWidth(24)),
                  child: Column(
                    children: [
                      profileItemWidget(
                        context: context,
                        label: "Wallet",
                        image: "assets/profile_image/solar_wallet.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/ArtistWalletScreen',
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),
                      profileItemWidget(
                        context: context,
                        label: "Bank Details",
                        image: "assets/profile_image/bank.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/BankDetailsScreen',
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),
                      profileItemWidget(
                        context: context,
                        label: "My Ticket",
                        image: "assets/profile_image/tiket.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/ArtistMyTicketScreen',
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: Responsive.getWidth(14),
                      right: Responsive.getWidth(24)),
                  child: Column(
                    children: [
                      profileItemWidget(
                        context: context,
                        label: "Donate Now",
                        image: "assets/profile_image/iconoir_donate.png",
                        onTap: () {
                          _launchURL();
                          // Navigator.pushNamed(
                          //   context,
                          //   '/Artist/Profile/ArtistDonateNowScreen',
                          // );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(55)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),
                      // profileItemWidget(
                      //   context: context,
                      //   label: "Notifications",
                      //   image: "assets/profile_image/bell.png",
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //       context,
                      //       '/Artist/Profile/NotificationSetting',
                      //     );
                      //   },
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                      //   child: Divider(
                      //     color: Color.fromRGBO(230, 230, 230, 1),
                      //   ),
                      // ),
                      // profileItemWidget(
                      //   context: context,
                      //   label: "FAQs",
                      //   image: "assets/profile_image/question.png",
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //       context,
                      //       '/Artist/Profile/Faq',
                      //     );
                      //   },
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                      //   child: Divider(
                      //     color: Color.fromRGBO(230, 230, 230, 1),
                      //   ),
                      // ),
                      profileItemWidget(
                        context: context,
                        label: "Privacy Policy",
                        image:
                            "assets/profile_image/iconoir_privacy_policy.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/PrivacyPolicy',
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),

                      profileItemWidget(
                        context: context,
                        label: "FAQ's",
                        image: "assets/profile_image/faq.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/Faq',
                          );
                          // Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.rightToLeft,
                          //         child: PrivacyPolicyScreen()));
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),

                      profileItemWidget(
                        context: context,
                        label: "Help Center",
                        image: "assets/profile_image/help_center.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/ArtistHelpCenterScreen',
                          );
                          // Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.rightToLeft,
                          //         child: PrivacyPolicyScreen()));
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),
                      profileItemWidget(
                        context: context,
                        label: "Help Center Enquiry",
                        image: "assets/profile_image/help_center_enquiry.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/Artist/Profile/ArtistHelpCenterAllChatScreen',
                          );
                          // Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.rightToLeft,
                          //         child: PrivacyPolicyScreen()));
                        },
                      ),
                      isMiramonet == false ? SizedBox() : Padding(
                        padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                        child: Divider(
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                      ),
                      isMiramonet == false ? SizedBox() : profileItemWidget(
                        context: context,
                        label: "Mira Monet Team",
                        image: "assets/profile_image/help_center_enquiry.png",
                        onTap: () {
                          isMiramonet!
                              ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ArtistMiraMonetTeamChatScreen(
                                    miramonet_chat_id:
                                    miramonet_chat_id,
                                  )))
                              : callMiramonetChat();

                          // Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.rightToLeft,
                          //         child: PrivacyPolicyScreen()));
                        },
                      ),

                      // Padding(
                      //   padding: EdgeInsets.only(left: Responsive.getWidth(51)),
                      //   child: Divider(
                      //     color: Color.fromRGBO(230, 230, 230, 1),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Divider(
                  color: Color.fromRGBO(230, 230, 230, 1),
                  thickness: 8,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: Responsive.getWidth(14),
                      right: Responsive.getWidth(24)),
                  child: GestureDetector(
                    onTap: () {
                      showDeleteDialog(context);
                    },
                    child: Container(
                      // padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    // color: Colors.black.withOpacity(1),
                                  ),
                                  child: Icon(
                                    Icons.power_settings_new,
                                    color: Color.fromRGBO(237, 16, 16, 1),
                                    size: Responsive.getFontSize(24),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                WantText2(
                                    text: "Logout",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: Color.fromRGBO(237, 16, 16, 1))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: Responsive.getWidth(14),
                      right: Responsive.getWidth(24)),
                  child: GestureDetector(
                    onTap: () {
                      showDeleteAccountDialog(context);
                    },
                    child: Container(
                      // padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    // color: Colors.black.withOpacity(1),
                                  ),
                                  child: Image.asset(
                                    "assets/profile_image/delete_account.png",
                                    height: Responsive.getWidth(24),
                                    width: Responsive.getWidth(24),
                                  ),
                                  // Icon(
                                  //   Icons.power_settings_new,
                                  //   color: Color.fromRGBO(237, 16, 16, 1),
                                  //   size: Responsive.getFontSize(24),
                                  // ),
                                ),
                                const SizedBox(width: 5),
                                WantText2(
                                    text: "Delete Account",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: Color.fromRGBO(237, 16, 16, 1))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Responsive.getHeight(40),
                )
              ],
            ),
          );
  }

  void showDeleteAccountDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(11),
                    vertical: Responsive.getHeight(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/dialog_delete.png",
                      height: Responsive.getWidth(78),
                      width: Responsive.getWidth(78),
                    ),
                    SizedBox(height: Responsive.getHeight(12)),
                    WantText2(
                        text: "Delete Account?",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack),
                    SizedBox(height: Responsive.getHeight(8)),
                    Text(
                      textAlign: TextAlign.center,
                      "are sure you want to delete your account?",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: Color.fromRGBO(128, 128, 128, 1),
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                      onTap: () async {
                        // _logout(context);
                        deleteAccount(customerUniqueID.toString());
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(217, 45, 32, 1.0),
                            ),
                            color: Color.fromRGBO(217, 45, 32, 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Yes, Please",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                    SizedBox(height: Responsive.getHeight(12)),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(208, 213, 221, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "No Cancel",
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Color.fromRGBO(52, 64, 84, 1.0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showDeleteDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(11),
                    vertical: Responsive.getHeight(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/logout_dialog.png",
                      height: Responsive.getWidth(78),
                      width: Responsive.getWidth(78),
                    ),
                    SizedBox(height: Responsive.getHeight(12)),
                    WantText2(
                        text: "Logout your Account?",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack),
                    SizedBox(height: Responsive.getHeight(8)),
                    Text(
                      textAlign: TextAlign.center,
                      "Are you sure you want to logout this Account?\nThis action cannot be undone.",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: Color.fromRGBO(128, 128, 128, 1),
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                      onTap: () async {
                        _logout(context);
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(217, 45, 32, 1.0),
                            ),
                            color: Color.fromRGBO(217, 45, 32, 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Log Out",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                    SizedBox(height: Responsive.getHeight(12)),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(208, 213, 221, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Cancel",
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Color.fromRGBO(52, 64, 84, 1.0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget profileItemWidget({
    required BuildContext context,
    required String label,
    required String image,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      // color: Colors.black.withOpacity(1),
                    ),
                    child: Image.asset(
                      image,
                      height: Responsive.getHeight(24),
                      width: Responsive.getWidth(24),
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 5),
                  WantText2(
                      text: label,
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.regular,
                      textColor: textBlack11)
                ],
              ),
            ),
            RotatedBox(
                quarterTurns: 2,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: Responsive.getWidth(20),
                  color: Color.fromRGBO(179, 179, 179, 1),
                )),
          ],
        ),
      ),
    );
  }
}
