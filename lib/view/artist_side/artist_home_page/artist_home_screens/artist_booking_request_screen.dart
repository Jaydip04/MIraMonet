import 'package:artist/config/toast.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../artist_order_page/artist_track_order_screen.dart';

class ArtistBookingRequestScreen extends StatefulWidget {
  const ArtistBookingRequestScreen({super.key});

  @override
  State<ArtistBookingRequestScreen> createState() =>
      _ArtistBookingRequestScreenState();
}

class _ArtistBookingRequestScreenState
    extends State<ArtistBookingRequestScreen> {
  List<dynamic> arts = [];

  bool isLoading = true;
  bool isLoading2 = false;
  Future<void> fetchBookingRequest(String customerUniqueId) async {
    ApiService apiService = ApiService();
    List<dynamic> fetchedArts =
        await apiService.fetchBookingRequest(customerUniqueId, 'seller');
    setState(() {
      arts = fetchedArts;
      isLoading = false;
    });
  }

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
    fetchBookingRequest(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Column(
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
                      width: Responsive.getWidth(60),
                    ),
                    WantText2(
                        text: "Booking Request",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack)
                  ],
                ),
                SizedBox(
                  height: Responsive.getHeight(20),
                ),
                isLoading == true
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
                    : arts.isEmpty
                        ? Container(
                            height: Responsive.getHeight(600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/box_grey.png",
                                  width: Responsive.getWidth(64),
                                  height: Responsive.getWidth(64),
                                ),
                                SizedBox(height: Responsive.getHeight(24)),
                                WantText2(
                                    text: "No Orders!",
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.semiBold,
                                    textColor: textBlack11),
                                SizedBox(height: Responsive.getHeight(12)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.getWidth(50)),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "You don’t have any orders at this time.",
                                    style: GoogleFonts.poppins(
                                      letterSpacing: 1.5,
                                      color: Color.fromRGBO(128, 128, 128, 1),
                                      fontSize: Responsive.getFontSize(16),
                                      fontWeight: AppFontWeight.regular,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: arts.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var art = arts[index];
                              return Column(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                child: Image.network(
                                                  art["art_image"],
                                                  fit: BoxFit.contain,
                                                  width:
                                                      Responsive.getWidth(96),
                                                  height:
                                                      Responsive.getWidth(96),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.getWidth(4)),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            width: Responsive.getWidth(8),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: WantText2(
                                                    text: art["title"],
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            14),
                                                    fontWeight:
                                                        AppFontWeight.semiBold,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    textColor: textBlack11),
                                                width: Responsive.getWidth(213),
                                              ),
                                              SizedBox(
                                                height: Responsive.getHeight(3),
                                              ),
                                              WantText2(
                                                  text: "\$ ${art["price"]}",
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          12),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: textBlack11),
                                              SizedBox(
                                                height: Responsive.getHeight(3),
                                              ),
                                              Row(
                                                children: [
                                                  WantText2(
                                                      text: "Request Date: ",
                                                      fontSize: Responsive
                                                          .getFontSize(10),
                                                      fontWeight: AppFontWeight
                                                          .semiBold,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      textColor: textBlack11),
                                                  Container(
                                                    child: WantText2(
                                                        text: art["order_date"],
                                                        fontSize:
                                                            Responsive
                                                                .getFontSize(
                                                                    10),
                                                        fontWeight:
                                                            AppFontWeight
                                                                .semiBold,
                                                        textOverflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        textColor: textBlack11),
                                                    width: Responsive.getWidth(
                                                        140),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: Responsive.getHeight(8),
                                              ),
                                              Container(
                                                width: Responsive.getWidth(230),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              child: WantText2(
                                                                  text:
                                                                      "Decline",
                                                                  fontSize: Responsive
                                                                      .getFontSize(
                                                                          12),
                                                                  fontWeight:
                                                                      AppFontWeight
                                                                          .bold,
                                                                  textColor: Color
                                                                      .fromRGBO(
                                                                          238,
                                                                          0,
                                                                          0,
                                                                          1)),
                                                              onTap: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      false,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Dialog(
                                                                      backgroundColor:
                                                                          whiteBack,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12)),
                                                                      insetPadding:
                                                                          EdgeInsets.symmetric(
                                                                              horizontal: Responsive.getWidth(14)),
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.all(0),
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: Responsive.getWidth(11), vertical: Responsive.getHeight(24)),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Image.asset(
                                                                                  "assets/dialog_delete.png",
                                                                                  height: Responsive.getWidth(78),
                                                                                  width: Responsive.getWidth(78),
                                                                                ),
                                                                                SizedBox(height: Responsive.getHeight(12)),
                                                                                WantText2(text: "Decline Art", fontSize: Responsive.getFontSize(20), fontWeight: AppFontWeight.semiBold, textColor: textBlack),
                                                                                SizedBox(height: Responsive.getHeight(8)),
                                                                                Text(
                                                                                  textAlign: TextAlign.center,
                                                                                  "Are you sure you want to Decline this Art?\nThis action cannot be undone.",
                                                                                  style: GoogleFonts.poppins(
                                                                                    color: Color.fromRGBO(128, 128, 128, 1),
                                                                                    fontSize: Responsive.getFontSize(14),
                                                                                    fontWeight: AppFontWeight.regular,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: Responsive.getHeight(24)),
                                                                                Center(
                                                                                    child: GestureDetector(
                                                                                  onTap: () async {
                                                                                    ApiService().confirmOrder(customerUniqueID.toString(), art["art_unique_id"].toString(), "Declined", art["customer_fcm_token"].toString() ?? "").then((onValue) {
                                                                                      _loadUserData();
                                                                                      Navigator.pop(context);
                                                                                    });
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
                                                                                            isLoading2
                                                                                                ? Center(
                                                                                                    child: SizedBox(
                                                                                                      height: 20,
                                                                                                      width: 20,
                                                                                                      child: CircularProgressIndicator(
                                                                                                        strokeWidth: 3,
                                                                                                        color: Colors.white,
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                : Text(
                                                                                                    "Decline",
                                                                                                    style: GoogleFonts.urbanist(
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
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: Responsive
                                                                  .getWidth(18),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                print(
                                                                    "customerUniqueID : $customerUniqueID");
                                                                print(
                                                                    "order_id : ${art["order_unique_id"]}");
                                                                print(
                                                                    "art_unique_id : ${art["art_unique_id"]}");
                                                                print(
                                                                    "FCMToken : ${art["customer_fcm_token"]}");

                                                                ApiService()
                                                                    .confirmOrder(
                                                                        customerUniqueID
                                                                            .toString(),
                                                                        art["art_unique_id"]
                                                                            .toString(),
                                                                        "Confirmed",
                                                                        art["customer_fcm_token"]
                                                                            .toString())
                                                                    .then(
                                                                        (onValue) {
                                                                  setState(() {
                                                                    isClick =
                                                                        false;
                                                                  });
                                                                  _loadUserData();
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                                // showRegisterDialog(
                                                                //   context,
                                                                //   customerUniqueID
                                                                //       .toString(),
                                                                //   art["order_unique_id"]
                                                                //       .toString(),
                                                                //   art["art_unique_id"]
                                                                //       .toString(),
                                                                //   art["customer_fcm_token"] ??
                                                                //       "",
                                                                // );
                                                              },
                                                              child: Container(
                                                                height: Responsive
                                                                    .getHeight(
                                                                        30),
                                                                width: Responsive
                                                                    .getWidth(
                                                                        99),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black),
                                                                    color:
                                                                        black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Responsive.getWidth(6)),
                                                                  ),
                                                                  child: Center(
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "Accept",
                                                                          style:
                                                                              GoogleFonts.poppins(
                                                                            letterSpacing:
                                                                                1.5,
                                                                            textStyle:
                                                                                TextStyle(
                                                                              fontSize: Responsive.getFontSize(14),
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
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  ArtistTrackOrderScreen(
                                                    art_unique_id:
                                                        art["art_unique_id"]
                                                            .toString(),
                                                  )));
                                    },
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(8),
                                  ),
                                  Divider(),
                                  SizedBox(
                                    height: Responsive.getHeight(8),
                                  ),
                                ],
                              );
                            })
              ],
            ),
          ),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _trackIdController = TextEditingController();
  TextEditingController _trackLineController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();

  bool isClick = false;
  @override
  void dispose() {
    _trackIdController.dispose();
    _trackLineController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  // void showRegisterDialog(BuildContext context, String customer_unique_id,
  //     String order_unique_id, String art_unique_id, String FCMToken) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: whiteBack,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         insetPadding:
  //             EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
  //         child: Container(
  //           margin: EdgeInsets.all(0), // Remove all margins
  //           child: SingleChildScrollView(
  //             child: Padding(
  //               padding: EdgeInsets.symmetric(
  //                   horizontal: Responsive.getWidth(11),
  //                   vertical: Responsive.getHeight(11)),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       SizedBox(
  //                         width: 1,
  //                       ),
  //                       GestureDetector(
  //                         onTap: () => Navigator.pop(context),
  //                         child: Icon(
  //                           CupertinoIcons.multiply_circle,
  //                           color: Colors.grey,
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                   Form(
  //                     key: _formKey,
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         WantText2(
  //                             text: "Track Info",
  //                             fontSize: Responsive.getFontSize(16),
  //                             fontWeight: AppFontWeight.bold,
  //                             textColor: textBlack9),
  //                         SizedBox(
  //                           height: Responsive.getHeight(10),
  //                         ),
  //                         WantText2(
  //                             text: "Track ID",
  //                             fontSize: Responsive.getFontSize(12),
  //                             fontWeight: AppFontWeight.medium,
  //                             textColor: textBlack9),
  //                         SizedBox(
  //                           height: Responsive.getHeight(5),
  //                         ),
  //                         AppTextFormField(
  //                           fillColor: Color.fromRGBO(247, 248, 249, 1),
  //                           contentPadding: EdgeInsets.symmetric(
  //                               horizontal: Responsive.getWidth(18),
  //                               vertical: Responsive.getHeight(14)),
  //                           borderRadius: Responsive.getWidth(8),
  //                           controller: _trackIdController,
  //                           borderColor: textFieldBorderColor,
  //                           hintStyle: GoogleFonts.urbanist(
  //                             color: textGray,
  //                             fontSize: Responsive.getFontSize(15),
  //                             fontWeight: AppFontWeight.medium,
  //                           ),
  //                           textStyle: GoogleFonts.urbanist(
  //                             color: textBlack,
  //                             fontSize: Responsive.getFontSize(15),
  //                             fontWeight: AppFontWeight.medium,
  //                           ),
  //                           hintText: "Enter Track ID",
  //                         ),
  //                         SizedBox(
  //                           height: Responsive.getHeight(15),
  //                         ),
  //                         WantText2(
  //                             text: "Track Link",
  //                             fontSize: Responsive.getFontSize(12),
  //                             fontWeight: AppFontWeight.medium,
  //                             textColor: textBlack9),
  //                         SizedBox(
  //                           height: Responsive.getHeight(5),
  //                         ),
  //                         AppTextFormField(
  //                           fillColor: Color.fromRGBO(247, 248, 249, 1),
  //                           contentPadding: EdgeInsets.symmetric(
  //                               horizontal: Responsive.getWidth(18),
  //                               vertical: Responsive.getHeight(14)),
  //                           borderRadius: Responsive.getWidth(8),
  //                           controller: _trackLineController,
  //                           borderColor: textFieldBorderColor,
  //                           hintStyle: GoogleFonts.urbanist(
  //                             color: textGray,
  //                             fontSize: Responsive.getFontSize(15),
  //                             fontWeight: AppFontWeight.medium,
  //                           ),
  //                           textStyle: GoogleFonts.urbanist(
  //                             color: textBlack,
  //                             fontSize: Responsive.getFontSize(15),
  //                             fontWeight: AppFontWeight.medium,
  //                           ),
  //                           hintText: "Enter Track Link",
  //                         ),
  //                         SizedBox(
  //                           height: Responsive.getHeight(15),
  //                         ),
  //                         WantText2(
  //                             text: "Company Name",
  //                             fontSize: Responsive.getFontSize(12),
  //                             fontWeight: AppFontWeight.medium,
  //                             textColor: textBlack9),
  //                         SizedBox(
  //                           height: Responsive.getHeight(5),
  //                         ),
  //                         AppTextFormField(
  //                           fillColor: Color.fromRGBO(247, 248, 249, 1),
  //                           contentPadding: EdgeInsets.symmetric(
  //                               horizontal: Responsive.getWidth(18),
  //                               vertical: Responsive.getHeight(14)),
  //                           borderRadius: Responsive.getWidth(8),
  //                           controller: _companyNameController,
  //                           borderColor: textFieldBorderColor,
  //                           hintStyle: GoogleFonts.urbanist(
  //                             color: textGray,
  //                             fontSize: Responsive.getFontSize(15),
  //                             fontWeight: AppFontWeight.medium,
  //                           ),
  //                           textStyle: GoogleFonts.urbanist(
  //                             color: textBlack,
  //                             fontSize: Responsive.getFontSize(15),
  //                             fontWeight: AppFontWeight.medium,
  //                           ),
  //                           hintText: "Enter Company Name",
  //                         ),
  //                         SizedBox(
  //                           height: Responsive.getHeight(20),
  //                         ),
  //                         Align(
  //                           alignment: Alignment.center,
  //                           child: GestureDetector(
  //                             onTap: () async {
  //                               if (_trackIdController.text.isEmpty) {
  //                                 showToast(message: "Enter Track ID");
  //                               } else if (_trackLineController.text.isEmpty) {
  //                                 showToast(message: "Enter Track Link");
  //                               } else if (_companyNameController
  //                                   .text.isEmpty) {
  //                                 showToast(message: "Enter Company Name");
  //                               } else {
  //                                 setState(() {
  //                                   isClick = true;
  //                                 });
  //                                 ApiService()
  //                                     .addTrackingSystem(
  //                                         customer_unique_id,
  //                                         order_unique_id,
  //                                         art_unique_id,
  //                                         _trackIdController.text.toString(),
  //                                         _trackLineController.text.toString(),
  //                                         _companyNameController.text
  //                                             .toString())
  //                                     .then((onValue) {});
  //                               }
  //                             },
  //                             child: Container(
  //                               height: Responsive.getHeight(45),
  //                               width: Responsive.getMainWidth(context),
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                   border: Border.all(color: Colors.black),
  //                                   color: black,
  //                                   borderRadius: BorderRadius.circular(
  //                                       Responsive.getWidth(8)),
  //                                 ),
  //                                 child: Center(
  //                                   child: Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.center,
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.center,
  //                                     children: [
  //                                       isClick
  //                                           ? Center(
  //                                               child: SizedBox(
  //                                                 height: 20,
  //                                                 width: 20,
  //                                                 child:
  //                                                     CircularProgressIndicator(
  //                                                   strokeWidth: 3,
  //                                                   color: Colors.white,
  //                                                 ),
  //                                               ),
  //                                             )
  //                                           : Text(
  //                                               "ACCEPT",
  //                                               style: GoogleFonts.poppins(
  //                                                 letterSpacing: 1.5,
  //                                                 textStyle: TextStyle(
  //                                                   fontSize:
  //                                                       Responsive.getFontSize(
  //                                                           18),
  //                                                   color: Colors.white,
  //                                                   fontWeight: FontWeight.w500,
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //       //   RegisterDialog(
  //       //   artUniqueId: art_unique_id,
  //       //   customerUniqueId: customer_unique_id,
  //       //   orderUniqueId: order_unique_id,
  //       //   FCMToken: FCMToken,
  //       // );
  //     },
  //   );
  // }
}

// class RegisterDialog extends StatefulWidget {
//   final String customerUniqueId;
//   final String orderUniqueId;
//   final String artUniqueId;
//   final String FCMToken;
//
//   RegisterDialog({
//     required this.customerUniqueId,
//     required this.orderUniqueId,
//     required this.artUniqueId,
//     required this.FCMToken,
//   });
//
//   @override
//   _RegisterDialogState createState() => _RegisterDialogState();
// }
//
// class _RegisterDialogState extends State<RegisterDialog> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController _trackIdController = TextEditingController();
//   TextEditingController _trackLineController = TextEditingController();
//
//   bool isClick = false;
//   @override
//   void dispose() {
//     _trackIdController.dispose();
//     _trackLineController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return
//   }
// }
