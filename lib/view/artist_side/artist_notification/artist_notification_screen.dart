import 'dart:convert';

import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/api_service/base_url.dart';

class CustomMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'ago';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => '$seconds s';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int year) => '1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}

class ArtistNotificationScreen extends StatefulWidget {
  const ArtistNotificationScreen({super.key});

  @override
  State<ArtistNotificationScreen> createState() =>
      _ArtistNotificationScreenState();
}

class _ArtistNotificationScreenState extends State<ArtistNotificationScreen> {
  // final String baseUrl = "$serverUrl";
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    // fetchCustomerData(customerUniqueId);
    fetchNotifications(customerUniqueId);
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  Future<void> fetchNotifications(String customerUniqueId) async {
    final Map<String, dynamic> payload = {
      "customer_unique_id": customerUniqueId,
    };

    try {
      final response = await http.post(
        Uri.parse("$serverUrl/get_notification_data"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            notifications = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            notifications = [];
            isLoading = false;
          });
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching notifications: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  String convertToRelativeTime(String date, String time) {
    try {
      // Combine date and time into a single DateTime string
      String dateTimeString = "$date $time";
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Ensure timeago localization for the desired format
      timeago.setLocaleMessages('en_custom', CustomMessages());

      // Format the DateTime to a short relative time string
      return timeago.format(dateTime, locale: 'en_custom');
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
        child: ListView(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: Responsive.getWidth(41),
                    height: Responsive.getHeight(41),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Responsive.getWidth(12)),
                        border: Border.all(
                            color: textFieldBorderColor, width: 1.0)),
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: Responsive.getWidth(19),
                    ),
                  ),
                ),
                SizedBox(
                  width: Responsive.getWidth(80),
                ),
                WantText2(
                    text: "Notifications",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack)
              ],
            ),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            isLoading
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      ),
                    ),
                  )
                : notifications.isEmpty
                    ? Center(
                        child: Text(
                          "No notifications found",
                          style: GoogleFonts.poppins(
                              color: black,
                              fontWeight: AppFontWeight.regular,
                              letterSpacing: 1.5),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        // padding: const EdgeInsets.all(16.0),
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return buildNotificationTile(
                            notification['title'] ?? "No Title",
                            notification['body'] ?? "No Details",
                            notification['inserted_date'] ?? "No Date",
                            notification['inserted_time'] ?? "No Date",
                            notification['image'] ?? "",
                          );
                        },
                      ),
            // buildSectionTitle("Today", context),
            // buildNotificationTile("Your Shipping Already Delivered",
            //     "Tap to  see the detail shipping", "2 m ago", context),
            // SizedBox(
            //   height: Responsive.getHeight(16),
            // ),
            // buildSectionTitle("Yesterday", context),
            // buildNotificationTile("Try The Latest Service From Tracky!",
            //     "Let’s try the feature we provide", "2 m ago", context),
            // buildNotificationTile(
            //     "Get 20% Discount for First Transaction!",
            //     "For all transaction without requirements",
            //     "10 m ago",
            //     context),
            // SizedBox(
            //   height: Responsive.getHeight(16),
            // ),
            // buildSectionTitle("7 Days Ago", context),
            // buildNotificationTile("Try The Latest Service From Tracky!",
            //     "Let’s try the feature we provide", "2 m ago", context),
            // buildNotificationTile(
            //     "Get 20% Discount for First Transaction!",
            //     "For all transaction without requirements",
            //     "10 m ago",
            //     context),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.getHeight(10.0)),
      child: WantText2(
          text: title,
          fontSize: Responsive.getFontSize(16),
          fontWeight: AppFontWeight.regular,
          textColor: textGray3),
    );
  }

  Widget buildNotificationTile(
      String name, String details, String date, String time, String image) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.getHeight(16),
        // horizontal: Responsive.getWidth(16)
      ),
      decoration: BoxDecoration(
          color: whiteBack,
          borderRadius: BorderRadius.circular(
            Responsive.getWidth(
              8,
            ),
          ),
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(243, 243, 243, 1), width: 1.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Responsive.getWidth(44),
            width: Responsive.getWidth(44),
            decoration: BoxDecoration(
                color: Color.fromRGBO(29, 39, 47, 1),
                borderRadius: BorderRadius.circular(Responsive.getWidth(30))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(image),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Responsive.getWidth(289),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: Responsive.getWidth(150),
                      child: Text(
                        name,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          color: textBlack3,
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ),
                    WantText2(
                        text: convertToRelativeTime(date, time),
                        fontSize: Responsive.getFontSize(12),
                        fontWeight: AppFontWeight.regular,
                        textColor: textGray3),
                  ],
                ),
              ),
              SizedBox(
                height: Responsive.getHeight(8),
              ),
              Container(
                width: Responsive.getWidth(289),
                child: Text(
                  details,
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    color: textBlack3,
                    fontSize: Responsive.getFontSize(14),
                    fontWeight: AppFontWeight.regular,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
