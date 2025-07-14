import 'package:artist/core/api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'my_private_sale_enquiry.dart';
import 'package:timeago/timeago.dart' as timeago;

class PrivateSaleEnquiryScreen extends StatefulWidget {
  const PrivateSaleEnquiryScreen({super.key});

  @override
  State<PrivateSaleEnquiryScreen> createState() =>
      _PrivateSaleEnquiryScreenState();
}

class _PrivateSaleEnquiryScreenState extends State<PrivateSaleEnquiryScreen> {
  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  String timeAgo(String timeString) {
    final DateTime time = DateTime.parse(timeString);
    final DateTime currentTime = DateTime.now();

    return timeago.format(time);
  }

  @override
  void dispose() {
    super.dispose();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
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
                    width: Responsive.getWidth(50),
                  ),
                  WantText2(
                      text: "Private Sale Enquiry",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(25),
              ),
              FutureBuilder<List<dynamic>>(
                future: ApiService()
                    .fetchPrivateArtEnquiries(customerUniqueID.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
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
                            text: "No Private Sale Enquiry!",
                            fontSize: Responsive.getFontSize(20),
                            fontWeight: AppFontWeight.semiBold,
                            textColor: textBlack11,
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                            text: "No Private Sale Enquiry!",
                            fontSize: Responsive.getFontSize(20),
                            fontWeight: AppFontWeight.semiBold,
                            textColor: textBlack11,
                          ),
                        ],
                      ),
                    );
                  } else {
                    final enquiries = snapshot.data!;

                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: enquiries.length,
                        itemBuilder: (context, index) {
                          final enquiry = enquiries[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => MyPrivateSaleEnquiry(
                              //               customerUniqueID:
                              //                   customerUniqueID.toString(),
                              //               art_unique_id: enquiry['enquiry']
                              //                   ['art_unique_id'],
                              //             )));
                            },
                            child: Container(
                              width: Responsive.getWidth(342),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  SizedBox(
                                    height: Responsive.getHeight(10),
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              ClipRRect(
                                                child: Image.network(
                                                  enquiry['art_image'],
                                                  fit: BoxFit.contain,
                                                  width:
                                                      Responsive.getWidth(52),
                                                  height:
                                                      Responsive.getWidth(52),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.getWidth(8)),
                                              ),
                                              SizedBox(
                                                width: Responsive.getWidth(6),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  WantText2(
                                                      text: enquiry['enquiry']
                                                          ['title'],
                                                      fontSize: Responsive
                                                          .getFontSize(14),
                                                      fontWeight:
                                                          AppFontWeight.medium,
                                                      textColor: textBlack),
                                                  WantText2(
                                                      text: enquiry['enquiry']
                                                          ['artist_name'],
                                                      fontSize: Responsive
                                                          .getFontSize(12),
                                                      fontWeight:
                                                          AppFontWeight.regular,
                                                      textColor: Color.fromRGBO(
                                                          0, 0, 0, 0.4)),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      WantText2(
                                          text: timeAgo(
                                              "${enquiry['enquiry']['enquiry_date']} ${enquiry['enquiry']['enquiry_time']}"),
                                          fontSize: Responsive.getFontSize(12),
                                          fontWeight: AppFontWeight.regular,
                                          textColor:
                                              Color.fromRGBO(0, 0, 0, 0.4))
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(9),
                                  ),
                                  Text(
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    enquiry['enquiry']['message'],
                                    style: GoogleFonts.poppins(
                                      letterSpacing: 1.5,
                                      color: Color.fromRGBO(0, 0, 0, 0.6),
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.regular,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
