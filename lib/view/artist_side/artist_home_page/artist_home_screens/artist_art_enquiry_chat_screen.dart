import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../artist_my_art_page/single_art_screen/artist_review_art_screen.dart';
import 'artist_my_enquiry_replay_screen.dart';
import 'artist_my_private_sale_enquiry.dart';

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
  String lessThanOneMinute(int seconds) => '${seconds}s';
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

class ArtistArtEnquiryChatScreen extends StatefulWidget {
  final int index;
  const ArtistArtEnquiryChatScreen({super.key, required this.index});

  @override
  _ArtistArtEnquiryChatScreenState createState() =>
      _ArtistArtEnquiryChatScreenState();
}

class _ArtistArtEnquiryChatScreenState extends State<ArtistArtEnquiryChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _chatDataFuture;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.index);
    _loadUserData();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    _chatDataFuture =
        ApiService().getCustomerEnquiryArtist(customerUniqueId.toString());
    // ApiService().getCustomerEnquiryArtist("8088078491");
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  SizedBox(width: Responsive.getWidth(115)),
                  WantText2(
                      text: "Chat",
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
            FutureBuilder<Map<String, dynamic>>(
              future: _chatDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container(
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
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final artEnquiryChats = data['art_enuqiry_list'];
                  final privateSaleChats = data['private_enuqiry_list'];

                  return Column(
                    children: [
                      Container(
                        width: Responsive.getWidth(300),
                        height: Responsive.getHeight(55),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Responsive.getWidth(16)),
                          color: const Color.fromRGBO(215, 215, 215, 1),
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          controller: _tabController,
                          labelColor: Colors.black,
                          dividerColor: Colors.transparent,
                          labelPadding: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(0),
                          indicatorPadding: const EdgeInsets.all(0),
                          indicator: BoxDecoration(
                            color: white,
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(12)),
                          ),
                          indicatorColor: Colors.transparent,
                          labelStyle: GoogleFonts.poppins(
                            color: black,
                            fontSize: Responsive.getFontSize(12),
                            fontWeight: AppFontWeight.medium,
                            letterSpacing: 1.5,
                          ),
                          tabs: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 19),
                              child: Tab(text: "Art Enquiry"),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 19),
                              child: Tab(text: "Private Sale Enquiry"),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(10)),
                      Container(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            buildChatList(artEnquiryChats),
                            buildChatList(privateSaleChats),
                          ],
                        ),
                        height: 500,
                      ),
                    ],
                  );
                } else {
                  return Container(
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
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChatList(List<dynamic>? chats) {
    if (chats == null || chats.isEmpty) {
      return Container(
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
      );
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return GestureDetector(
          onTap: () {
            print(chat['art_type']);
            if (chat['art_type'].toString() == "Private") {
              print("object");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArtistMyPrivateSaleEnquiry(
                    art_id: chat['art_unique_id'].toString(),
                    art_type: chat['art_type'].toString(),
                    art_name: chat['title'].toString(),
                    customerUniqueID: customerUniqueID.toString(),
                    reciver_unique_id: chat['reciver_unique_id'].toString(),
                    art_enquiry_chat_id: chat['last_message'] == null
                        ? chat['private_enquiry_chat_id']
                        : chat['last_message']['private_enquiry_chat_id'],
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArtistMyEnquiryReplayScreen(
                    art_id: chat['art_unique_id'].toString(),
                    art_type: chat['art_type'].toString(),
                    art_name: chat['title'].toString(),
                    customerUniqueID: customerUniqueID.toString(),
                    reciver_unique_id: chat['reciver_unique_id'].toString(),
                    fcmToken: chat['reciver_fcm_token'].toString(),
                    art_enquiry_chat_id: chat['last_message'] == null
                        ? chat['art_enquiry_chat_id']
                        : chat['last_message']['art_enquiry_chat_id'],
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Responsive.getWidth(10),
              vertical: Responsive.getHeight(3),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getWidth(16),
              vertical: Responsive.getHeight(16),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Responsive.getWidth(16)),
              border: Border.all(color: Color.fromRGBO(242, 242, 242, 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ArtistSingleArtScreen(
                                          artUniqueID:
                                              chat['art_unique_id'].toString(),
                                        )));
                          },
                          child: Container(
                            width: Responsive.getWidth(40),
                            height: Responsive.getWidth(40),
                            child: ClipRRect(
                              child: Image.network(
                                chat['image'],
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(
                                  Responsive.getWidth(40)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Responsive.getWidth(10),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Responsive.getWidth(200),
                              child: WantText2(
                                  text: chat['title']!,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.bold,
                                  textColor: black),
                            ),
                            chat['last_message'] != null
                                ? SizedBox(
                                    width: 200,
                                    child: Text(
                                      chat['last_message']['message'] == null
                                          ? ''
                                          : chat['last_message']['message'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromRGBO(60, 60, 60, 1),
                                      ),
                                    ),
                                  )
                                : SizedBox()
                            // chat['last_message'] != null
                            //     ? SizedBox(
                            //         width: Responsive.getWidth(200),
                            //         child: Text(chat['last_message']
                            //         ['message'] == null ? chat['last_message']
                            //         ['reason']  : chat['last_message']
                            //         ['message'] ,
                            //           overflow: TextOverflow.ellipsis,
                            //           style: TextStyle(
                            //             fontSize: 14,
                            //             fontWeight: FontWeight.normal,
                            //             color: Color.fromRGBO(
                            //                 60, 60, 60, 1),
                            //           ),
                            //         // WantText2(
                            //         //
                            //         //     textOverflow: TextOverflow.ellipsis,
                            //         //     text: chat['last_message']['message'] ??
                            //         //         '',
                            //         //     fontSize: Responsive.getFontSize(14),
                            //         //     fontWeight: AppFontWeight.regular,
                            //         //     textColor:
                            //         //         Color.fromRGBO(60, 60, 60, 1)),
                            //       )
                            //     : SizedBox(),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                chat['last_message'] != null
                    ? WantText2(
                        text: convertToRelativeTime(
                            chat['last_message']['inserted_date']!,
                            chat['last_message']['inserted_time']!),
                        fontSize: Responsive.getFontSize(12),
                        fontWeight: AppFontWeight.regular,
                        textColor: black)
                    : SizedBox()
              ],
            ),
          ),
        );
      },
    );
  }
}
