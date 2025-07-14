import 'package:artist/config/toast.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/order_screen/return_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/colors.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../../../../core/widgets/custom_text_2.dart';

class TrackOrderScreen extends StatefulWidget {
  final art_unique_id;
  final customer_unique_id;
  final artist_unique_id;
  final fcmToken;
  final isReturn;
  final isFeedback;
  const TrackOrderScreen(
      {super.key,
      required this.art_unique_id,
      required this.customer_unique_id,
      required this.isReturn,
      required this.fcmToken,
      required this.isFeedback,
      required this.artist_unique_id});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  TextEditingController _trackIdcontroller = TextEditingController();
  TextEditingController _trackLinkcontroller = TextEditingController();
  TextEditingController _companynamecontroller = TextEditingController();
  Future<Map<String, dynamic>>? TrackData;
  @override
  void initState() {
    TrackData = ApiService().fetchOrderTrackDetails(widget.art_unique_id);
    super.initState();
  }

  // Future<void> _launchPhone(String phoneNumber) async {
  //   final Uri url = Uri.parse('tel:$phoneNumber');
  //   try {
  //     if (await canLaunchUrl(url)) {
  //       await launchUrl(url);
  //     } else {
  //       throw 'Could not launch $url';
  //     }
  //   } catch (e) {
  //     print('Error launching phone call: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          // padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                  SizedBox(
                    width: Responsive.getWidth(80),
                  ),
                  WantText2(
                      text: "Track order",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(16),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
              height: 650,
              child: FutureBuilder<Map<String, dynamic>>(
                future: TrackData,
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
                    return Center(child: Text('No data available'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['status'] != true) {
                    return Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!;
                  print(snapshot.data);

                  data["data"]['tracking_id'] == null
                      ? ""
                      : _trackIdcontroller.text = data["data"]['tracking_id'];
                  data["data"]['tracking_link'] == null
                      ? ""
                      : _trackLinkcontroller.text =
                          data["data"]['tracking_link'];
                  data["data"]['company_name'] == null
                      ? ""
                      : _companynamecontroller.text =
                          data["data"]['company_name'];
                  print(data);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText2(
                          text: "Track ID",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack11),
                      SizedBox(
                        height: Responsive.getHeight(4),
                      ),
                      AppTextFormField(
                        fillColor: white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(15)),
                        borderRadius: Responsive.getWidth(8),
                        controller: _trackIdcontroller,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.poppins(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.poppins(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        hintText: "Track ID",
                        readOnly: true,
                        suffixIcon: IconButton(
                          icon: Image.asset(
                            'assets/copy.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _trackIdcontroller.text));
                            showToast(message: "Track ID copied to clipboard!");
                          },
                        ),
                      ),
                      // SizedBox(
                      //   height: Responsive.getHeight(16),
                      // ),
                      SizedBox(height: Responsive.getHeight(16)),
                      WantText2(
                          text: "Track Link",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack11),
                      SizedBox(
                        height: Responsive.getHeight(4),
                      ),
                      AppTextFormField(
                        fillColor: white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(15)),
                        borderRadius: Responsive.getWidth(8),
                        controller: _trackLinkcontroller,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.poppins(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.poppins(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        hintText: "Track Link",
                        readOnly: true,
                        onTap: () async {
                          final url = _trackLinkcontroller.text.trim();
                          if (url.isNotEmpty && Uri.parse(url).isAbsolute) {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            } else {
                              showToast(message: "Could not launch the link!");
                            }
                          } else {
                            showToast(message: "Invalid or empty track link!");
                          }
                        },
                        suffixIcon: IconButton(
                          icon: Image.asset(
                            'assets/copy.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _trackLinkcontroller.text));
                            showToast(
                                message: "Track Link copied to clipboard!");
                          },
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(16),
                      ),
                      WantText2(
                          text: "Company Name",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack11),
                      SizedBox(
                        height: Responsive.getHeight(4),
                      ),
                      AppTextFormField(
                        fillColor: white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(15)),
                        borderRadius: Responsive.getWidth(8),
                        controller: _companynamecontroller,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.poppins(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.poppins(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        hintText: "Company Name",
                        readOnly: true,
                        suffixIcon: IconButton(
                          icon: Image.asset(
                            'assets/copy.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: _companynamecontroller.text));
                            showToast(
                                message: "Company Name copied to clipboard!");
                          },
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(16),
                      ),
                      WantText2(
                          text: "Contact's Person",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack11),
                      SizedBox(
                        height: Responsive.getHeight(4),
                      ),
                      SizedBox(height: Responsive.getHeight(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    child: data["data"]['customer_profile'] ==
                                            null
                                        ? Center(
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              child: Text(
                                                '${data["data"]['artist_name'][0].toUpperCase()}',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 30,
                                            child: Image.network(
                                              data["data"]['customer_profile'],
                                              height: Responsive.getWidth(48),
                                              width: Responsive.getWidth(48),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                    borderRadius: BorderRadius.circular(
                                        Responsive.getWidth(80)),
                                  ),
                                  SizedBox(
                                    width: Responsive.getWidth(12),
                                  ),
                                  Container(
                                    width: Responsive.getWidth(221),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                width: Responsive.getWidth(221),
                                                child: WantText2(
                                                    text: data["data"]
                                                        ['artist_name'],
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            16),
                                                    fontWeight:
                                                        AppFontWeight.semiBold,
                                                    textColor: textBlack11)),
                                            WantText2(
                                                text: "Artist",
                                                fontSize:
                                                    Responsive.getFontSize(14),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: Color.fromRGBO(
                                                    128, 128, 128, 1))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // GestureDetector(
                          //   child: Container(
                          //       width: Responsive.getWidth(48),
                          //       height: Responsive.getWidth(48),
                          //       padding: EdgeInsets.all(12),
                          //       // decoration: BoxDecoration(
                          //       //     borderRadius: BorderRadius.circular(50),
                          //       //     color: Color.fromRGBO(230, 230, 230, 1)),
                          //       child:
                          //       Image.asset(
                          //         "assets/chat.png",
                          //         height: Responsive.getWidth(24),
                          //         width: Responsive.getWidth(24),
                          //       )
                          //   ),
                          //   onTap: () {
                          //     Clipboard.setData(ClipboardData(
                          //         text: data["data"]['mobile']));
                          //     showToast(
                          //         message:
                          //         "Mobile copied to clipboard!");
                          //     // _launchPhone(data["data"]['mobile'].toString());
                          //   },
                          // )
                        ],
                      ),
                      // SizedBox(height: Responsive.getHeight(100)),
                      Spacer(),
                      widget.isReturn == true
                          ? GeneralButton(
                              Width: double.infinity,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ReturnOrderScreen(
                                              fcmToken: widget.fcmToken,
                                              customer_unique_id:
                                                  widget.customer_unique_id,
                                              artist_unique_id:
                                                  widget.artist_unique_id,
                                              art_unique_id:
                                                  widget.art_unique_id,
                                            )));
                              },
                              label: "Return Order",
                              isBoarderRadiusLess: true,
                            )
                          : SizedBox()
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
