import 'package:artist/config/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../../config/colors.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_text_form_field.dart';
import '../../../core/widgets/custom_text_2.dart';

class ArtistTrackOrderScreen extends StatefulWidget {
  final art_unique_id;
  const ArtistTrackOrderScreen({super.key, required this.art_unique_id});

  @override
  State<ArtistTrackOrderScreen> createState() => _ArtistTrackOrderScreenState();
}

class _ArtistTrackOrderScreenState extends State<ArtistTrackOrderScreen> {
  TextEditingController _addresscontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _trackIdcontroller = TextEditingController();
  TextEditingController _trackLinkcontroller = TextEditingController();
  TextEditingController _compantNamecontroller = TextEditingController();
  Future<Map<String, dynamic>>? TrackData;
  @override
  void initState() {
    TrackData =
        ApiService().fetchOrderTrackDetailsForSeller(widget.art_unique_id);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: white,
        body: SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                    width: Responsive.getWidth(100),
                  ),
                  WantText2(
                      text: "Details",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(5),
              ),
              FutureBuilder<Map<String, dynamic>>(
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
                  print(data);
                  data["data"]['customerdetail']['addressData'] == null
                      ? ""
                      : _addresscontroller.text =
                          "${data["data"]['customerdetail']['addressData']['address']}, ${data["data"]['customerdetail']['addressData']['name_of_city']}, ${data["data"]['customerdetail']['addressData']['state_subdivision_name']}, ${data["data"]['customerdetail']['addressData']['country_name']}, ${data["data"]['customerdetail']['addressData']['pincode']}";

                  data["data"]['customerdetail']['customer_email'] == null
                      ? ""
                      : _emailcontroller.text =
                          data["data"]['customerdetail']['customer_email'];

                  data["data"]['trackdetail']['tracking_id'] == null
                      ? ""
                      : _trackIdcontroller.text =
                          data["data"]['trackdetail']['tracking_id'];
                  data["data"]['trackdetail']['tracking_link'] == null
                      ? ""
                      : _trackLinkcontroller.text =
                          data["data"]['trackdetail']['tracking_link'];
                  data["data"]['trackdetail']['company_name'] == null
                      ? ""
                      : _compantNamecontroller.text =
                          data["data"]['trackdetail']['company_name'];
                  print(data);

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: Responsive.getWidth(16)),
                      //   child: Row(
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () => Navigator.pop(context),
                      //         child: Container(
                      //           width: Responsive.getWidth(41),
                      //           height: Responsive.getHeight(41),
                      //           decoration: BoxDecoration(
                      //             color: Colors.white,
                      //             borderRadius: BorderRadius.circular(
                      //                 Responsive.getWidth(12)),
                      //             border: Border.all(
                      //                 color: textFieldBorderColor,
                      //                 width: 1.0),
                      //           ),
                      //           child: Icon(
                      //             Icons.arrow_back_ios_new_outlined,
                      //             size: Responsive.getWidth(19),
                      //           ),
                      //         ),
                      //       ),
                      //       SizedBox(width: Responsive.getWidth(95)),
                      //       WantText2(
                      //         text: "My Ticket",
                      //         fontSize: Responsive.getFontSize(18),
                      //         fontWeight: AppFontWeight.medium,
                      //         textColor: textBlack,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        // padding: EdgeInsets.symmetric(
                        //     horizontal: Responsive.getWidth(16)),
                        height: Responsive.getHeight(55),
                        child: TabBar(
                          indicatorColor: black,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.black,
                          labelStyle: GoogleFonts.poppins(
                              color: black,
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.medium,
                              letterSpacing: 1.5),
                          tabs: [
                            Tab(text: "Customer Contact"),
                            Tab(text: "Track Details"),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(16)),
                      Container(
                        height: Responsive.getHeight(660),
                        child: TabBarView(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WantText2(
                                    text: "Customer Address",
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
                                  controller: _addresscontroller,
                                  borderColor: textFieldBorderColor,
                                  maxLines: 2,
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
                                  hintText: "Customer Address",
                                  readOnly: true,
                                  suffixIcon: IconButton(
                                    icon: Image.asset(
                                      'assets/copy.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: _addresscontroller.text));
                                      showToast(
                                          message:
                                              "Address copied to clipboard!");
                                    },
                                  ),
                                ),
                                // SizedBox(
                                //   height: Responsive.getHeight(16),
                                // ),
                                SizedBox(height: Responsive.getHeight(16)),
                                WantText2(
                                    text: "Customer Email",
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
                                  controller: _emailcontroller,
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
                                  hintText: "Customer Email",
                                  readOnly: true,
                                  suffixIcon: IconButton(
                                    icon: Image.asset(
                                      'assets/copy.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: _emailcontroller.text));
                                      showToast(
                                          message:
                                              "Email copied to clipboard!");
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            data["data"]['customerdetail']
                                                        ['customer_profile'] ==
                                                    null
                                                ? CircleAvatar(
                                                    radius: 24,
                                                    backgroundColor:
                                                        Colors.grey.shade300,
                                                    child: Text(
                                                      '${data["data"]['customerdetail']['customer_name'][0].toUpperCase()}',
                                                      style: TextStyle(
                                                          fontSize: 24,
                                                          color: black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    radius: 24,
                                                    child: ClipRRect(
                                                      child: Image.network(
                                                        data["data"][
                                                                    "customerdetail"]
                                                                [
                                                                "customer_profile"]
                                                            .toString(),
                                                        height:
                                                            Responsive.getWidth(
                                                                48),
                                                        width:
                                                            Responsive.getWidth(
                                                                48),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                            // ClipRRect(
                                            //   child: Image.network(
                                            //     data["data"]
                                            //         ['customer_profile'],
                                            //     height: Responsive.getWidth(48),
                                            //     width: Responsive.getWidth(48),
                                            //     fit: BoxFit.fill,
                                            //   ),
                                            //   borderRadius:
                                            //       BorderRadius.circular(
                                            //           Responsive.getWidth(80)),
                                            // ),
                                            SizedBox(
                                              width: Responsive.getWidth(12),
                                            ),
                                            Container(
                                              width: Responsive.getWidth(221),
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                          width: Responsive
                                                              .getWidth(221),
                                                          child: WantText2(
                                                              text: data["data"]
                                                                              ['customerdetail']
                                                                          ['addressData']
                                                                      [
                                                                      'full_name']
                                                                  .toString(),
                                                              fontSize: Responsive
                                                                  .getFontSize(
                                                                      16),
                                                              fontWeight:
                                                                  AppFontWeight
                                                                      .semiBold,
                                                              textColor:
                                                                  textBlack11)),
                                                      WantText2(
                                                          text: data["data"][
                                                                          'customerdetail']
                                                                      [
                                                                      'addressData']
                                                                  ['mobile']
                                                              .toString(),
                                                          fontSize: Responsive
                                                              .getFontSize(14),
                                                          fontWeight:
                                                              AppFontWeight
                                                                  .regular,
                                                          textColor:
                                                              Color.fromRGBO(
                                                                  128,
                                                                  128,
                                                                  128,
                                                                  1))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      child: Container(
                                          width: Responsive.getWidth(48),
                                          height: Responsive.getWidth(48),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Color.fromRGBO(
                                                  230, 230, 230, 1)),
                                          child: Image.asset(
                                            "assets/artist/call.png",
                                            height: Responsive.getWidth(24),
                                            width: Responsive.getWidth(24),
                                          )),
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: data["data"]['customerdetail']
                                                    ['addressData']['mobile']
                                                .toString(),
                                          ),
                                        );
                                        showToast(
                                            message:
                                                "Mobile copied to clipboard!");
                                        // _launchPhone(data["data"]['mobile'].toString());
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                            Column(
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
                                      Clipboard.setData(ClipboardData(
                                          text: _trackIdcontroller.text));
                                      showToast(
                                          message:
                                              "Track ID copied to clipboard!");
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
                                      Clipboard.setData(ClipboardData(
                                          text: _trackLinkcontroller.text));
                                      showToast(
                                          message:
                                              "Track Link copied to clipboard!");
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
                                  controller: _compantNamecontroller,
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
                                  suffixIcon: IconButton(
                                    icon: Image.asset(
                                      'assets/copy.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: _compantNamecontroller.text));
                                      showToast(
                                          message:
                                              "Company Name copied to clipboard!");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
