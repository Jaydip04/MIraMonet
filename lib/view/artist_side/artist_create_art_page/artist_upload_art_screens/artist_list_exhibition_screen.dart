import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_register_payment_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../core/widgets/general_button.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import 'artist_exhibition_seat_booking_screen.dart';
import 'exhibition/artist_exhibition_upload_screen.dart';

class Exhibition {
  // final int exhibitionId;
  final String exhibitionUniqueId;
  final String name;
  final String tagline;
  final String description;
  final String startDate;
  final String endDate;
  final String insertedDate;
  final String updatedDate;
  final ExhibitionCountry? country;
  final ExhibitionState? state;
  final ExhibitionCity? city;
  final String address1;
  final String address2;
  final String contactNumber;
  final String contactEmail;
  final String websiteLink;
  final String status;
  final String? logo;
  final String art_submit_last_date;
  final int? isArtApproved;
  final int? is_booth;
  final bool? isRegister;
  final bool? isFull;
  final bool? isAdd;
  // final List<ExhibitionImage> images;

  Exhibition({
    // required this.exhibitionId,
    required this.exhibitionUniqueId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.insertedDate,
    required this.updatedDate,
    required this.country,
    required this.state,
    required this.city,
    required this.address1,
    required this.address2,
    required this.contactNumber,
    required this.contactEmail,
    required this.websiteLink,
    required this.status,
    this.logo,
    required this.art_submit_last_date,
    this.isArtApproved,
    this.is_booth,
    this.isRegister,
    this.isFull,
    this.isAdd,
    // required this.images,
  });

  factory Exhibition.fromJson(Map<String, dynamic> json) {
    return Exhibition(
      // exhibitionId: json['exhibition_id'],
      exhibitionUniqueId: json['exhibition_unique_id'] ?? "",
      name: json['name'] ?? "",
      tagline: json['tagline'] ?? "",
      description: json['description'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      insertedDate: json['inserted_date'] ?? "",
      updatedDate: json['updated_date'] ?? '',
      country: json['country'] != null ? ExhibitionCountry.fromJson(json['country']) : null,
      state: json['state'] != null ? ExhibitionState.fromJson(json['state']) : null,
      city: json['city'] != null ? ExhibitionCity.fromJson(json['city']) : null,
      address1: json['address1'] ?? "",
      address2: json['address2'] ?? "",
      contactNumber: json['contact_number'] ?? "",
      contactEmail: json['contact_email'] ?? "",
      websiteLink: json['website_link'] ?? "",
      status: json['status'] ?? "",
      logo: json['logo'] ?? "",
      art_submit_last_date: json['art_submit_last_date'] ?? "",
      isArtApproved: json['isArtApproved'] ?? 0,
      is_booth: json['is_booth'] ?? 0,
      isRegister: json['isRegister'] ?? false,
      isFull: json['isFull'] ?? false,
      isAdd: json['isAdd'] ?? false,
      // images: (json['images'] as List)
      //     .map((imageJson) => ExhibitionImage.fromJson(imageJson))
      //     .toList(),
    );
  }
}

class ExhibitionCountry {
  final int countryId;
  final String countryName;

  ExhibitionCountry({
    required this.countryId,
    required this.countryName,
  });

  factory ExhibitionCountry.fromJson(Map<String, dynamic> json) {
    return ExhibitionCountry(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }
}

class ExhibitionState {
  final int stateSubdivisionId;
  final String stateSubdivisionName;

  ExhibitionState({
    required this.stateSubdivisionId,
    required this.stateSubdivisionName,
  });

  factory ExhibitionState.fromJson(Map<String, dynamic> json) {
    return ExhibitionState(
      stateSubdivisionId: json['state_subdivision_id'],
      stateSubdivisionName: json['state_subdivision_name'],
    );
  }
}

class ExhibitionCity {
  final int citiesId;
  final String nameOfCity;

  ExhibitionCity({
    required this.citiesId,
    required this.nameOfCity,
  });

  factory ExhibitionCity.fromJson(Map<String, dynamic> json) {
    return ExhibitionCity(
      citiesId: json['cities_id'],
      nameOfCity: json['name_of_city'],
    );
  }
}

class ExhibitionImage {
  final int exhibitionGalleryId;
  final String link;
  final String tagline;
  // final int exhibitionId;
  // final String insertedDate;
  // final String insertedTime;
  // final String status;

  ExhibitionImage({
    required this.exhibitionGalleryId,
    required this.link,
    required this.tagline,
    // required this.exhibitionId,
    // required this.insertedDate,
    // required this.insertedTime,
    // required this.status,
  });

  factory ExhibitionImage.fromJson(Map<String, dynamic> json) {
    return ExhibitionImage(
      exhibitionGalleryId: json['exhibition_gallery_id'],
      link: json['link'],
      tagline: json['tagline'],
      // exhibitionId: json['exhibition_id'],
      // insertedDate: json['inserted_date'] ?? '',
      // insertedTime: json['inserted_time'] ?? '',
      // status: json['status'],
    );
  }
}

class ArtistListExhibitionScreen extends StatefulWidget {
  const ArtistListExhibitionScreen({super.key});

  @override
  State<ArtistListExhibitionScreen> createState() =>
      _ArtistListExhibitionScreenState();
}

class _ArtistListExhibitionScreenState
    extends State<ArtistListExhibitionScreen> {
  late Future<List<Exhibition>> futureExhibitions;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    futureExhibitions = ApiService().fetchExhibitions();
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

  String formatDate(String inputDate) {
    try {
      DateTime parsedDate = DateTime.parse(inputDate);
      return DateFormat("d MMM yyyy").format(parsedDate);
    } catch (e) {
      return "Invalid date format";
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
        backgroundColor: white,
        body: ListView(
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
                    width: Responsive.getWidth(35),
                  ),
                  WantText2(
                      text: "Upcoming Exhibition",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
            ),
            FutureBuilder<List<Exhibition>>(
              future: futureExhibitions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: Responsive.getHeight(700),
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No exhibitions found'));
                }
                final exhibitions = snapshot.data!;
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: exhibitions.length,
                    itemBuilder: (context, index) {
                      final exhibition = exhibitions[index];
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(16),
                              vertical: Responsive.getHeight(16),
                            ),
                            child: ClipRRect(
                              child: Image.network(
                                exhibition.logo.toString(),
                                fit: BoxFit.contain,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: Responsive.getHeight(290),
                            width: double.infinity,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exhibition.name.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack4,
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                                Text(
                                  exhibition.description,
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack4,
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                  ),
                                ),
                                SizedBox(height: Responsive.getHeight(5)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: Responsive.getWidth(16),
                                      color: textGray9,
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: Responsive.getWidth(310),
                                      child: WantText2(
                                        text:
                                            '${exhibition.address1}, ${exhibition.address2}',
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: AppFontWeight.regular,
                                        textColor: textGray9,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.getHeight(5)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: Responsive.getWidth(16),
                                      color: textGray9,
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: Responsive.getWidth(310),
                                      child: WantText2(
                                        text:
                                            '${formatDate(exhibition.startDate)} - ${formatDate(exhibition.endDate)}',
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: AppFontWeight.regular,
                                        textColor: textGray9,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.getHeight(5)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: Responsive.getWidth(16),
                                      color: textGray9,
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: Responsive.getWidth(310),
                                      child: WantText2(
                                        text:
                                            'Last date for art submission: ${formatDate(exhibition.art_submit_last_date)}',
                                        fontSize: Responsive.getFontSize(12),
                                        fontWeight: AppFontWeight.regular,
                                        textColor: textGray9,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.getHeight(10)),
                                exhibition.isArtApproved == 1
                                    ? Row(
                                        children: [
                                          GeneralButton(
                                            Width: Responsive.getWidth(340),
                                            onTap: () {
                                              print(
                                                  "${exhibition.exhibitionUniqueId}");
                                              exhibition.is_booth == 0
                                                  ? exhibition.isRegister ==
                                                          false
                                                      ? showCongratulationsDialog()
                                                      : showRegisterDialog(
                                                          context,
                                                          exhibition
                                                              .exhibitionUniqueId)
                                                  : exhibition.isRegister ==
                                                          false
                                                      ? showCongratulationsDialog()
                                                      : Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ArtistExhibitionSeatBookingScreen(
                                                                    exhibitionUniqueId:
                                                                        exhibition
                                                                            .exhibitionUniqueId,
                                                                  )));
                                            },
                                            label: exhibition.is_booth == 0
                                                ? "Booking"
                                                : "Select Seat",
                                            isBoarderRadiusLess: true,
                                          ),
                                        ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      )
                                    : exhibition.isAdd == true
                                        ? GeneralButton(
                                            Width: Responsive.getWidth(360),
                                            onTap: () {
                                              if (exhibition.isFull == true) {
                                                showCongratulationsDialog();
                                              } else {
                                                print(
                                                    "${exhibition.exhibitionUniqueId}");
                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (_) =>
                                                //             ArtistExhibitionUploadScreen(
                                                //               exhibitionUniqueId:
                                                //                   exhibition
                                                //                       .exhibitionUniqueId,
                                                //             )));
                                              }
                                            },
                                            label: "Upload Art",
                                            isBoarderRadiusLess: true,
                                          )
                                        : SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      );
                    });
              },
            ),
            SizedBox(
              height: Responsive.getHeight(20),
            )
          ],
        ));
  }

  void showRegisterDialog(BuildContext context, String exhibition_unique_id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return RegisterDialog(
          exhibitionUniqueId: exhibition_unique_id.toString(),
          customerUniqueID: customerUniqueID.toString(),
        );
      },
    );
  }

  void showCongratulationsDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Congratulations();
      },
    );
  }
}

class Congratulations extends StatefulWidget {
  @override
  _CongratulationsState createState() => _CongratulationsState();
}

class _CongratulationsState extends State<Congratulations> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      backgroundColor: whiteBack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
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
                // SizedBox(height: Responsive.getHeight(24)),
                WantText2(
                    text: "Art submission is now closed.",
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: black),
                SizedBox(height: Responsive.getHeight(24)),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(293),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    label: "Close",
                    isBoarderRadiusLess: true,
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

class RegisterDialog extends StatefulWidget {
  final String exhibitionUniqueId;
  final String customerUniqueID;

  const RegisterDialog(
      {Key? key,
      required this.exhibitionUniqueId,
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
          final response = await ApiService().registerSellerExhibitions(
            name: nameController.text,
            email: emailController.text,
            mobile: mobileController.text,
            exhibitionUniqueId: widget.exhibitionUniqueId,
            address: addressController.text,
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

    percentage =
        await apiService.fetchExhibitionPercentage(widget.exhibitionUniqueId);

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
                      WantText2(
                          text: "Enter Full Name",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
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
                      WantText2(
                          text: "Email Address",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: isVerifySuccess
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
                                        final response = await ApiService()
                                            .sendOTPexhibitionReg(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                        fontSize: Responsive
                                                            .getFontSize(16),
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
                                      final response =
                                          await ApiService().verifyOtpEmail(
                                        emailController.text,
                                        _pinControllerMobile.text,
                                      );

                                      if (response['status'] == 'true') {
                                        setState(() {
                                          isVerifySuccess =
                                              true; // Set verification success
                                          isVisibleMobile =
                                              false; // Hide OTP input
                                          isVerify =
                                              false; // Stop loading indicator
                                        });
                                      } else {
                                        setState(() {
                                          isVerifySuccess =
                                              false; // Mark verification as failed
                                          isVerify = false;
                                        });
                                        showToast(
                                            message: response[
                                                'message']); // Show error message
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isVerifySuccess =
                                            false; // Mark verification as failed
                                        isVerify =
                                            false; // Stop loading indicator
                                      });
                                      showToast(
                                          message:
                                              "Something went wrong. Please try again.");
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
                      WantText2(
                          text: "Mobile Number",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                mobileController.clear();
                              },
                            ),
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
                      WantText2(
                          text: "Artist Name",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
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
                      WantText2(
                          text: "Portfolio Link",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
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
                      WantText2(
                          text: "Social media Link",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
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
                      WantText2(
                          text: "Current Address",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
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

  void showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VerifyDialog();
      },
    );
  }
}

class VerifyDialog extends StatefulWidget {
  @override
  _VerifyDialogState createState() => _VerifyDialogState();
}

class _VerifyDialogState extends State<VerifyDialog> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      backgroundColor: whiteBack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
      child: Container(
        margin: EdgeInsets.all(0),
        height: Responsive.getHeight(422),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WantText2(
                    text: "Register Now",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(18)),
                WantText2(
                    text: "Enter verification code",
                    fontSize: Responsive.getFontSize(12),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack10),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Pinput(
                    controller: _pinController,
                    length: 4,
                    onCompleted: (pin) {
                      print('OTP entered: $pin');
                    },
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(10)),
                      textStyle: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(22),
                        fontWeight: AppFontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: textFieldBorderColor, width: 1.0),
                        color: whitefill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(10)),
                      textStyle: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(22),
                        fontWeight: AppFontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: textFieldBorderColor2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(10)),
                      textStyle: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(22),
                        fontWeight: AppFontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: textFieldBorderColor2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 23),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(50)),
                  child: Text(
                    textAlign: TextAlign.center,
                    "A verification code has been sent to your mobile number and email",
                    style: GoogleFonts.poppins(
                      color: textGray10,
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.regular,
                    ),
                  ),
                ),
                SizedBox(height: 120),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(275),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/User/SingleUpcomingExhibitionScreen/TicketScreen',
                      );
                    },
                    label: "Verify",
                    isBoarderRadiusLess: true,
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
