import 'dart:convert';
import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import 'artist_register_payment_screen.dart';

class Booth {
  final int exhibitionBoothId;
  final String boothSize;
  final String noOfSeats;
  final String price;
  final int exhibitionId;
  final List<BoothSeat> boothSeats;

  Booth({
    required this.exhibitionBoothId,
    required this.boothSize,
    required this.noOfSeats,
    required this.price,
    required this.exhibitionId,
    required this.boothSeats,
  });

  factory Booth.fromJson(Map<String, dynamic> json) {
    return Booth(
      exhibitionBoothId:
          int.tryParse(json['exhibition_booth_id'].toString()) ?? 0,
      boothSize: json['booth_size'],
      noOfSeats: json['no_of_seats'],
      price: json['price'],
      exhibitionId: int.tryParse(json['exhibition_id'].toString()) ?? 0,
      boothSeats: (json['booth_seats'] as List)
          .map((seatJson) => BoothSeat.fromJson(seatJson))
          .toList(),
    );
  }
}

class BoothSeat {
  final int boothSeatId;
  final int exhibitionBoothId;
  final String seatName;
  bool isBooked;

  BoothSeat({
    required this.boothSeatId,
    required this.exhibitionBoothId,
    required this.seatName,
    required this.isBooked,
  });

  factory BoothSeat.fromJson(Map<String, dynamic> json) {
    return BoothSeat(
      boothSeatId: int.tryParse(json['booth_seat_id'].toString()) ?? 0,
      exhibitionBoothId:
          int.tryParse(json['exhibition_booth_id'].toString()) ?? 0,
      seatName: json['seat_name'],
      isBooked: json['status'] == "Inactive"
          ? false
          : true, // Adjust based on status in JSON
    );
  }
}

class ArtistExhibitionSeatBookingScreen extends StatefulWidget {
  final String exhibitionUniqueId;

  const ArtistExhibitionSeatBookingScreen({
    Key? key,
    required this.exhibitionUniqueId,
  }) : super(key: key);

  @override
  _ArtistExhibitionSeatBookingScreenState createState() =>
      _ArtistExhibitionSeatBookingScreenState();
}

class _ArtistExhibitionSeatBookingScreenState
    extends State<ArtistExhibitionSeatBookingScreen> {
  List<Booth> booths = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchBoothData();
    _loadUserData();
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

  Future<void> fetchBoothData() async {
    try {
      final exhibition =
          await apiService.fetchBoothDataApi(widget.exhibitionUniqueId);
      setState(() {
        booths = exhibition;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching booth data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String? selectedSheet;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: isLoading
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
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(16)),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: Responsive.getWidth(41),
                              height: Responsive.getHeight(41),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(12)),
                                  border: Border.all(
                                      color: textFieldBorderColor, width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(30),
                          ),
                          WantText2(
                              text: "Exhibition seat Booking",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(3),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: Responsive.getWidth(9),
                                        width: Responsive.getWidth(9),
                                        color: Color.fromRGBO(60, 60, 60, 1),
                                      ),
                                      SizedBox(
                                        width: Responsive.getWidth(3),
                                      ),
                                      WantText2(
                                          text: "Booked",
                                          fontSize: Responsive.getFontSize(10),
                                          fontWeight: AppFontWeight.bold,
                                          textColor: textBlack)
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                width: Responsive.getWidth(16),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: Responsive.getWidth(9),
                                        width: Responsive.getWidth(9),
                                        color: Color.fromRGBO(153, 153, 153, 1),
                                      ),
                                      SizedBox(
                                        width: Responsive.getWidth(3),
                                      ),
                                      WantText2(
                                          text: "Available",
                                          fontSize: Responsive.getFontSize(10),
                                          fontWeight: AppFontWeight.bold,
                                          textColor: textBlack)
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(15),
                    ),
                    for (int boothIndex = 0;
                        boothIndex < booths.length;
                        boothIndex++)
                      _buildBooth(boothIndex),
                    SizedBox(
                      height: Responsive.getHeight(10),
                    ),
                    GeneralButton(
                      Width: Responsive.getWidth(331),
                      onTap: () {
                        if (selectedSheet == null) {
                          showToast(message: "Please select seat");
                        } else {
                          print(selectedSheet.toString());
                          showRegisterDialog(
                            context,
                            widget.exhibitionUniqueId,
                            selectedSheet.toString(),
                          );
                        }
                      },
                      label: "Next",
                      isBoarderRadiusLess: true,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBooth(int boothIndex) {
    final booth = booths[boothIndex];
    int numberOfRows = (booth.boothSeats.length / 8)
        .ceil(); // Dynamic row count based on the number of seats
    List<List<BoothSeat>> seatRows = [];

    for (int i = 0; i < numberOfRows; i++) {
      seatRows.add(
        booth.boothSeats.sublist(
          i * 8,
          (i + 1) * 8 <= booth.boothSeats.length
              ? (i + 1) * 8
              : booth.boothSeats.length,
        ),
      );
    }

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Responsive.getHeight(7)),
        width: Responsive.getWidth(321),
        padding: EdgeInsets.symmetric(
            vertical: Responsive.getHeight(8),
            horizontal: Responsive.getHeight(8)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.getWidth(11)),
            color: white,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.07),
                blurRadius: 14,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WantText2(
                    text: 'Booth ${boothIndex + 1} (${booth.boothSize})',
                    fontSize: Responsive.getFontSize(12),
                    fontWeight: AppFontWeight.bold,
                    textColor: textBlack),
                Column(
                  children: [
                    WantText2(
                        text: "Fee ${booth.price}\$",
                        fontSize: Responsive.getFontSize(12),
                        fontWeight: AppFontWeight.bold,
                        textColor: textBlack)
                  ],
                )
              ],
            ),
            Divider(
              color: Color.fromRGBO(60, 60, 60, 1),
              thickness: Responsive.getHeight(3),
            ),
            _buildSeatGraph(seatRows, boothIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGraph(List<List<BoothSeat>> seatRows, int boothIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Responsive.getWidth(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(8, (colIndex) {
              return Container(
                margin:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(13.5)),
                child: Center(
                  child: Text(
                    '${colIndex + 1}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        for (int rowIndex = 0; rowIndex < seatRows.length; rowIndex++)
          _buildSeatRow(seatRows[rowIndex], boothIndex, rowIndex),
      ],
    );
  }

  Widget _buildSeatRow(List<BoothSeat> seats, int boothIndex, int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: Responsive.getWidth(13)),
          margin: EdgeInsets.symmetric(vertical: Responsive.getWidth(5)),
          child: Center(
            child: Text(
              '${String.fromCharCode(65 + rowIndex)}',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: Responsive.getFontSize(14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Seats in the row
        for (int seatIndex = 0; seatIndex < seats.length; seatIndex++)
          _buildSeat(seats[seatIndex], boothIndex),
      ],
    );
  }

  Widget _buildSeat(BoothSeat seat, int boothIndex) {
    return GestureDetector(
      onTap: () {
        if (seat.isBooked) {
          showToast(message: "Already Booked");
        } else {
          _toggleSeatBooking(seat, boothIndex);
        }
      },
      child: Container(
        width: Responsive.getWidth(18),
        height: Responsive.getWidth(18),
        margin: EdgeInsets.symmetric(horizontal: Responsive.getWidth(8.5)),
        color: seat.isBooked
            ? Color.fromRGBO(60, 60, 60, 1)
            : Color.fromRGBO(153, 153, 153, 1),
      ),
    );
  }

  void _toggleSeatBooking(BoothSeat seat, int boothIndex) {
    setState(() {
      seat.isBooked = !seat.isBooked;
      selectedSheet = seat.boothSeatId.toString();
      print("selectedSheet : $selectedSheet");
    });
    print(
        'Booth ${boothIndex + 1}, Seat ${seat.boothSeatId} is ${seat.isBooked ? 'booked' : 'available'}');
  }

  void showRegisterDialog(
      BuildContext context, String exhibition_unique_id, String selectedSheet) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return RegisterDialog(
          exhibitionUniqueId: exhibition_unique_id.toString(),
          selectedSheet: selectedSheet.toString(),
          customerUniqueID: customerUniqueID.toString(),
        );
      },
    );
  }
}

class RegisterDialog extends StatefulWidget {
  final String exhibitionUniqueId;
  final String customerUniqueID;
  final String selectedSheet;

  const RegisterDialog(
      {Key? key,
      required this.exhibitionUniqueId,
      required this.selectedSheet,
      required this.customerUniqueID})
      : super(key: key);

  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController _pinControllerMobile = TextEditingController();
  final TextEditingController _ArtistNameControllerMobile =
      TextEditingController();
  final TextEditingController _profileLinkControllerMobile =
      TextEditingController();
  final TextEditingController _socialLinkControllerMobile =
      TextEditingController();
  bool isVisibleMobile = false;
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  String phoneNumber = '';
  String countryCode = '';
  bool isPhoneNumberValid = true;
  bool isSend = false;
  bool isVerify = false;
  bool isVerifySuccess = false;
  bool isLoading = false;

  void registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      if (nameController.text.isEmpty) {
        showToast(message: "Enter Full Name");
      } else if (emailController.text.isEmpty) {
        showToast(message: "Enter Email");
      } else if (mobileController.text.isEmpty) {
        showToast(message: "Enter Mobile");
      } else if (addressController.text.isEmpty) {
        showToast(message: "Enter Address");
      } else if (_ArtistNameControllerMobile.text.isEmpty) {
        showToast(message: "Enter Artist Name");
      } else if (_profileLinkControllerMobile.text.isEmpty) {
        showToast(message: "Enter Profile Link");
      } else if (_socialLinkControllerMobile.text.isEmpty) {
        showToast(message: "Enter Social Media Link");
      } else if (isVerifySuccess == false) {
        showToast(message: "Please Verify Email");
      } else {
        setState(() {
          isLoading = true;
        });
        try {
          // await ApiService().registerCustomerExhibitions(
          //   name: nameController.text,
          //   email: emailController.text,
          //   mobile: mobileController.text,
          //   exhibitionUniqueId: widget.exhibitionUniqueId,
          //   address: addressController.text,
          //   customerUniqueId: widget.customerUniqueID,
          // ).then((onValue) {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => RegisterPaymentScreen(),
          //     ),
          //   );
          // });
          print("selectedSheet : ${widget.selectedSheet}");
          final response = await ApiService().registerSellerExhibitions(
            name: nameController.text,
            email: emailController.text,
            mobile: mobileController.text,
            exhibitionUniqueId: widget.exhibitionUniqueId,
            address: addressController.text,
            selectedSheet: widget.selectedSheet,
            artist_name: _ArtistNameControllerMobile.text.toString(),
            portfolio_link: _profileLinkControllerMobile.text.toString(),
            social_link: _socialLinkControllerMobile.text.toString(),
            customerUniqueId: widget.customerUniqueID,
          );
          // role: "seller",
          showToast(message: response['message']);
          if (response['status'] == "false") {
            showToast(message: response['message']);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistRegisterPaymentScreen(response: response),
              ),
            );
          }
        } catch (e) {
          print(e);
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    getExhibitionPercentage();
    super.initState();
  }

  String? percentage;
  void getExhibitionPercentage() async {
    ApiService apiService = ApiService();

    percentage = await apiService.fetchExhibitionPercentage(widget.exhibitionUniqueId);

    if (percentage != null) {
      print('Exhibition percentage: $percentage%');
      // Trigger UI rebuild to reflect percentage
      setState(() {});
    } else {
      print('Failed to fetch exhibition percentage.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    print(widget.exhibitionUniqueId);
    print(widget.customerUniqueID);
    return Dialog(
      backgroundColor: whiteBack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
      child: Container(
        margin: EdgeInsets.all(0), // Remove all margins
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        WantText2(
                            text: "Register Now",
                            fontSize: Responsive.getFontSize(18),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              CupertinoIcons.multiply_circle,
                              color: textGray,
                            ))
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        WantText2(
                            text: "Fill the information carefully",
                            fontSize: Responsive.getFontSize(8),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack10),
                        Icon(
                          CupertinoIcons.multiply_circle,
                          color: Colors.transparent,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          WantText2(
                              text: "Full Name",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      AppTextFormField(
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(14)),
                        borderRadius: Responsive.getWidth(8),
                        controller: nameController,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        // onChanged: (p0) {
                        //   _formKey.currentState!.validate();
                        // },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Full Name",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Email",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width:  isVerifySuccess
                                ? Responsive.getWidth(324)
                                : Responsive.getWidth(252),
                            child: AppTextFormField(
                              suffixIcon: isVerifySuccess
                                  ? Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                color: Colors.green,
                              )
                                  : SizedBox(),
                              fillColor: Color.fromRGBO(247, 248, 249, 1),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getWidth(18),
                                  vertical: Responsive.getHeight(14)),
                              borderRadius: Responsive.getWidth(8),
                              controller: emailController,
                              borderColor: textFieldBorderColor,
                              hintStyle: GoogleFonts.urbanist(
                                color: textGray,
                                fontSize: Responsive.getFontSize(15),
                                fontWeight: AppFontWeight.medium,
                              ),
                              textStyle: GoogleFonts.urbanist(
                                color: textBlack,
                                fontSize: Responsive.getFontSize(15),
                                fontWeight: AppFontWeight.medium,
                              ),
                              // onChanged: (p0) {
                              //   _formKey.currentState!.validate();
                              // },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                final emailRegex = RegExp(
                                  r'^[a-z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Email is not valid';
                                }
                                return null;
                              },
                              hintText: "Enter Email",
                            ),
                          ),
                          isVerifySuccess
                              ? SizedBox()
                              : GestureDetector(
                            onTap: () async {
                              if (emailController.text.isEmpty) {
                                showToast(message: "Enter Email");
                              } else {
                                try {
                                  setState(() {
                                    isSend = true;
                                  });
                                  // await ApiService()
                                  //     .sendOTPexhibitionReg(
                                  //   emailController.text.toString(),
                                  //   // mobileController.text.toString(),
                                  //   widget.exhibitionUniqueId.toString()
                                  // )
                                  final response =
                                  await ApiService().sendOTPexhibitionReg(
                                    emailController.text.toString(),
                                    widget.exhibitionUniqueId.toString(),
                                  );
                                  if (response['status'] == 'true') {
                                    setState(() {
                                      isVisibleMobile = true;
                                      isSend = false;
                                    });
                                  } else {
                                    setState(() {
                                      isVisibleMobile = false;
                                      isSend = false;
                                    });
                                  }
                                  //     .then((onValue) {
                                  //   setState(() {
                                  //     isVisibleMobile = true;
                                  //     isSend = false;
                                  //   });
                                  // });
                                } catch (e) {
                                  setState(() {
                                    isVisibleMobile = true;
                                    isSend = false;
                                  });
                                  print(e);
                                }
                              }
                              // print("countryCode : $countryCode");
                              // print("countryCode : ${mobileController.text}");
                              // print(
                              //     "exhibition_unique_id : ${widget.exhibitionUniqueId}");
                            },
                            child: Container(
                              height: Responsive.getHeight(45),
                              width: Responsive.getWidth(60),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: black,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(5)),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      isSend
                                          ? Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                          : Text(
                                        "SEND",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            letterSpacing: 1.5,
                                            fontSize:
                                            Responsive.getFontSize(
                                                16),
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
                          )
                        ],
                      ),
                      isVisibleMobile
                          ? SizedBox(
                        height: Responsive.getHeight(12),
                      )
                          : Container(),
                      isVisibleMobile
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Pinput(
                            controller: _pinControllerMobile,
                            length: 4,
                            onCompleted: (pin) {
                              print('OTP entered: $pin');
                            },
                            defaultPinTheme: PinTheme(
                              width: 60,
                              height: 45,
                              textStyle: GoogleFonts.poppins(
                                color: black,
                                letterSpacing: 1.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: BoxDecoration(
                                // color: Color.fromRGBO(247, 248, 249, 1),
                                border: Border.all(
                                    color: textFieldBorderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 60,
                              height: 45,
                              textStyle: GoogleFonts.poppins(
                                color: black,
                                letterSpacing: 1.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: BoxDecoration(
                                // color: Colors.transparent,
                                border: Border.all(
                                    color: textFieldBorderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: 60,
                              height: 45,
                              textStyle: GoogleFonts.poppins(
                                color: black,
                                letterSpacing: 1.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: BoxDecoration(
                                // color: Color.fromRGBO(247, 248, 249, 1),
                                border: Border.all(
                                    color: textFieldBorderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isVerify = true;
                              });
                              try {
                                final response = await ApiService().verifyOtpEmail(
                                  emailController.text,
                                  _pinControllerMobile.text,
                                );

                                if (response['status'] == 'true') {
                                  setState(() {
                                    isVerifySuccess = true; // Set verification success
                                    isVisibleMobile = false; // Hide OTP input
                                    isVerify = false; // Stop loading indicator
                                  });
                                } else {
                                  setState(() {
                                    isVerifySuccess = false; // Mark verification as failed
                                    isVerify = false;
                                  });
                                  showToast(message: response['message']); // Show error message
                                }
                              } catch (e) {
                                setState(() {
                                  isVerifySuccess = false; // Mark verification as failed
                                  isVerify = false; // Stop loading indicator
                                });
                                showToast(message: "Something went wrong. Please try again.");
                                print(e);
                              }

                              // try {
                              //   await ApiService()
                              //       .verifyOtpEmail(emailController.text,
                              //           _pinControllerMobile.text)
                              //       .then((onValue) {
                              //     setState(() {
                              //       isVerifySuccess = true;
                              //       isVisibleMobile = false;
                              //       isVerify = false;
                              //     });
                              //   });
                              // } catch (e) {
                              //   setState(() {
                              //     isVerifySuccess = false;
                              //     isVerify = false;
                              //   });
                              //   print(e);
                              // }
                            },
                            child: Container(
                              height: Responsive.getHeight(45),
                              width: Responsive.getWidth(60),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: black,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(5)),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      isVerify
                                          ? Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                          : Text(
                                        "VERIFY",
                                        style: GoogleFonts.poppins(
                                          letterSpacing: 1.5,
                                          textStyle: TextStyle(
                                            fontSize: Responsive
                                                .getFontSize(14),
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Mobile Number",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      Container(
                        // width: Responsive.getWidth(252),
                        padding: EdgeInsets.only(
                          left: Responsive.getWidth(16),
                        ),
                        decoration: BoxDecoration(
                          // color: Color.fromRGBO(247, 248, 249, 1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                            color:
                            // isPhoneNumberValid
                            //     ?
                            textFieldBorderColor
                                // : Colors.red,
                          ),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              phoneNumber = number.phoneNumber ?? '';
                              countryCode = number.dialCode ?? '';
                            });
                            print("Full number: $phoneNumber");
                            print("Country code: $countryCode");
                          },
                          onInputValidated: (bool value) {
                            setState(() {
                              isPhoneNumberValid = value;
                            });
                            print(value ? 'Valid' : 'Invalid');
                          },
                          selectorConfig: SelectorConfig(
                            setSelectorButtonAsPrefixIcon: false,
                            useBottomSheetSafeArea: true,
                            leadingPadding: 0,
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: false,
                            trailingSpace: false,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          initialValue: number,
                          textFieldController: mobileController,
                          formatInput: false,
                          textStyle: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textBlack,
                            fontSize: 14.00,
                            fontWeight: FontWeight.normal,
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onSaved: (PhoneNumber number) {
                            String formattedNumber =
                                number.phoneNumber?.replaceFirst('+', '') ?? '';
                            print('On Saved: $formattedNumber');
                          },
                          cursorColor: Colors.black,
                          inputDecoration: InputDecoration(
                            isDense: true,
                            hintText: 'Enter phone number',
                            hintStyle: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: textGray,
                              fontSize: 14.00,
                              fontWeight: FontWeight.normal,
                            ),
                            // fillColor: Color.fromRGBO(247, 248, 249, 1),
                            // filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            // suffixIcon: IconButton(
                            //   icon: Icon(
                            //     Icons.clear,
                            //     color: Colors.grey,
                            //   ),
                            //   onPressed: () {
                            //     mobileController.clear();
                            //   },
                            // ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            errorMaxLines: 3,
                            counterText: "",
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Artist Name",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      AppTextFormField(
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(14)),
                        borderRadius: Responsive.getWidth(8),
                        controller: _ArtistNameControllerMobile,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        // onChanged: (p0) {
                        //   _formKey.currentState!.validate();
                        // },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Artist Name cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Artist Name",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Portfolio Link",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      AppTextFormField(
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(14)),
                        borderRadius: Responsive.getWidth(8),
                        controller: _profileLinkControllerMobile,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        // onChanged: (p0) {
                        //   _formKey.currentState!.validate();
                        // },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Portfolio Link cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Portfolio Link",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Social media Link",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      AppTextFormField(
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(14)),
                        borderRadius: Responsive.getWidth(8),
                        controller: _socialLinkControllerMobile,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        // onChanged: (p0) {
                        //   _formKey.currentState!.validate();
                        // },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Social media Link cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Social media Link",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Current Address",
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack9),
                          WantText2(
                              text: "*",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      AppTextFormField(
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(14)),
                        borderRadius: Responsive.getWidth(8),
                        controller: addressController,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        // onChanged: (p0) {
                        //   _formKey.currentState!.validate();
                        // },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current Address cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Address",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.check_box,
                            color: black,
                            size: Responsive.getWidth(20),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(5),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(300),
                            child: Text(
                              "A ${percentage == null ? 0 : percentage}% commission will be deducted from each artwork sold at the exhibition",
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                  color: black,
                                  fontSize: Responsive.getFontSize(8),
                                  fontWeight: AppFontWeight.semiBold,
                                  letterSpacing: 1.5),
                            ),
                          ),
                          // WantText2(text: "A 21% commission will be deducted from each artwork sold at the exhibition", fontSize: Responsive.getFontSize(8), fontWeight: AppFontWeight.semiBold, textColor: black)
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(20),
                      ),
                      Center(
                          child: GestureDetector(
                        onTap: registerCustomer,
                        child: Container(
                          height: Responsive.getHeight(45),
                          width: Responsive.getWidth(335),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: black,
                              borderRadius:
                                  BorderRadius.circular(Responsive.getWidth(5)),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  isLoading
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
                                          "NEXT",
                                          style: GoogleFonts.poppins(
                                            letterSpacing: 1.5,
                                            textStyle: TextStyle(
                                              fontSize:
                                                  Responsive.getFontSize(16),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
