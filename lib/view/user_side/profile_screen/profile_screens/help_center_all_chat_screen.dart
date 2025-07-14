import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/api_service/base_url.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../artist_side/artist_notification/artist_notification_screen.dart';
import 'help_center_chat_screen.dart';

class HelpCenterAllChatScreen extends StatefulWidget {
  const HelpCenterAllChatScreen({super.key});

  @override
  State<HelpCenterAllChatScreen> createState() =>
      _HelpCenterAllChatScreenState();
}

class _HelpCenterAllChatScreenState extends State<HelpCenterAllChatScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  List<Map<String, dynamic>> chats = [];

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
      fetchChatData();
    });
  }

  Future<void> fetchChatData() async {
    try {
      final response = await http.post(
        Uri.parse(
            '$serverUrl/get_customer_all_help_enquiry'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "customer_unique_id": customerUniqueID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        final data = jsonDecode(response.body);

        if (data["status"] == true) {
          setState(() {
            isLoading = false;
          });
          setState(() {
            chats = List<Map<String, dynamic>>.from(data["help_enuqiry_list"]);
          });
        } else {
          setState(() {
            isLoading = false;
          });
          // showToast(message: data["message"]);
        }
      } else {
        setState(() {
          isLoading = false;
        });

        // showToast(message: "Failed to fetch data");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  String convertToRelativeTime(String date, String time) {
    try {
      String dateTimeString = "$date $time";
      DateTime dateTime = DateTime.parse(dateTimeString);

      timeago.setLocaleMessages('en_custom', CustomMessages());

      return timeago.format(dateTime, locale: 'en_custom');
    } catch (e) {
      return "Invalid date/time";
    }
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
              child: Row(
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
                  SizedBox(width: Responsive.getWidth(40)),
                  WantText2(
                      text: "Help Center Enquiry",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color.fromRGBO(230, 230, 230, 1),
              ),
            ),
            SizedBox(height: Responsive.getHeight(10)),
            isLoading
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
                : chats.isEmpty
                    ? Container(
                        height: Responsive.getHeight(650),
                        width: Responsive.getMainWidth(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/profile_image/my_art_enquiry.png",
                              width: Responsive.getWidth(64),
                              height: Responsive.getWidth(64),
                            ),
                            SizedBox(height: Responsive.getHeight(10)),
                            WantText2(
                              text: "No Enquiry!",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.semiBold,
                              textColor: textBlack11,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return GestureDetector(
                            onTap: () {
                              print(chat['enquiry_category_name']);
                              print(chat['title']);
                              print("customerUniqueID : ${customerUniqueID}");
                              print(chat['reciver_unique_id']);
                              print(chat['help_center_chat_id']);
                              // if (chat['enquiry_category_name'] == "Private") {
                              //   // Navigator.push(
                              //   //   context,
                              //   //   MaterialPageRoute(
                              //   //     builder: (_) => MyPrivateSaleEnquiry(
                              //   //       art_type: chat['enquiry_category_name'],
                              //   //       art_name: chat['title'],
                              //   //       customerUniqueID: customerUniqueID,
                              //   //       reciver_unique_id: chat['reciver_unique_id'],
                              //   //       art_enquiry_chat_id: chat['last_message'] != null
                              //   //           ? chat['last_message']['private_enquiry_chat_id']
                              //   //           : null,
                              //   //     ),
                              //   //   ),
                              //   // );
                              // } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HelpCenterChatScreen(
                                    art_type: chat['enquiry_category_name'],
                                    art_name: chat['title'],
                                    customerUniqueID: customerUniqueID,
                                    reciver_unique_id:
                                        chat['reciver_unique_id'],
                                    art_enquiry_chat_id:
                                        chat['last_message']['message'] != null
                                            ? chat['last_message']
                                                    ['help_center_chat_id']
                                                .toString()
                                            : chat['help_center_chat_id']
                                                .toString(),
                                  ),
                                ),
                              );
                              // }
                            },
                            child: Container(
                              height: Responsive.getHeight(83),
                              margin: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Color.fromRGBO(242, 242, 242, 1)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            child: ClipRRect(
                                              child: Image.network(
                                                chat['image'],
                                                fit: BoxFit.fill,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                chat['title'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                  chat['last_message']
                                                              ['message'] !=
                                                          null
                                                      ? chat['last_message']
                                                              ['message'] ??
                                                          ''
                                                      : chat['last_message']
                                                              ['issue'] ??
                                                          '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color.fromRGBO(
                                                        60, 60, 60, 1),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    convertToRelativeTime(
                                      chat['last_message']['inserted_date'] ??
                                          '',
                                      chat['last_message']['inserted_time'] ??
                                          '',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
