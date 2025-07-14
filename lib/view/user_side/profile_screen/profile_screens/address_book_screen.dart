import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../config/colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  List<Address> addresses = [
    Address(
        id: '1',
        address: 'B205 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir',
        type: "Home"),
    Address(
        id: '2',
        address: 'B206 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir',
        type: "Office"),
    Address(
        id: '3',
        address: 'B207 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir',
        type: "Other"),
  ];
  String? selectedAddressId;

  void _editAddress(Address address) {}

  void _selectAddress(String id) {
    setState(() {
      selectedAddressId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        border:
                            Border.all(color: textFieldBorderColor, width: 1.0),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: Responsive.getWidth(19),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.getWidth(95)),
                  WantText2(
                    text: "Address",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack,
                  ),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(24),
              ),
              Divider(
                color: Color.fromRGBO(230, 230, 230, 1),
              ),
              Container(
                  width: Responsive.getWidth(341),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Responsive.getHeight(20),
                      ),
                      WantText2(
                          text: "Saved Address",
                          fontSize: Responsive.getWidth(16),
                          fontWeight: AppFontWeight.semiBold,
                          textColor: textBlack),
                      Container(
                        height: Responsive.getHeight(400),
                        child: ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            return AddressWidget(
                              address: addresses[index],
                              isSelected:
                                  addresses[index].id == selectedAddressId,
                              onEdit: () => _editAddress(addresses[index]),
                              onSelect: () =>
                                  _selectAddress(addresses[index].id),
                            );
                          },
                        ),
                      )
                    ],
                  )),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddressBottomSheet(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(20),
                      vertical: Responsive.getHeight(16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Responsive.getWidth(10),
                    ),
                    border: Border.all(
                        color: Color.fromRGBO(230, 230, 230, 1), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      WantText2(
                          text: "Add New Address",
                          fontSize: Responsive.getWidth(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack11)
                    ],
                  ),
                ),
              ),
              Spacer(),
              GeneralButton(
                Width: Responsive.getWidth(341),
                onTap: () {},
                label: "Apply",
                isBoarderRadiusLess: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AddressBottomSheet extends StatefulWidget {
  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  String? selectAddressType;

  final List<String> typeOptions = ['Home', 'Office', 'Other'];
  TextEditingController emailController = TextEditingController();
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.getWidth(16),
              vertical: Responsive.getHeight(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Responsive.getWidth(16))),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WantText2(
                      text: "Address",
                      fontSize: Responsive.getFontSize(20),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: textBlack11),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: Responsive.getWidth(24),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(16),
              ),
              WantText2(
                  text: "Address Nickname",
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.medium,
                  textColor: textBlack11),
              SizedBox(
                height: Responsive.getHeight(4),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: Responsive.getHeight(3)),
                decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: textFieldBorderColor,
                    )),
                child: DropdownButtonFormField<String>(
                  value: selectAddressType,
                  hint: Text(
                    'Select Gender',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0XFFA0A0A0).withOpacity(0.7),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectAddressType = newValue;
                    });
                  },
                  items:
                      typeOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey),
                  isExpanded: true,
                ),
              ),
              SizedBox(height: Responsive.getHeight(16)),
              WantText2(
                  text: "Full Address",
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
                controller: emailController,
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
                hintText: "925 S Chugach St #APT 10, Alaska 9964",
              ),
              SizedBox(height: Responsive.getHeight(16)),
              Row(
                children: [
                  _isChecked
                      ? GestureDetector(
                          child: Icon(
                            Icons.check_box,
                            color: black,
                            size: 24,
                          ),
                          onTap: () {
                            setState(() {
                              _isChecked = !_isChecked;
                            });
                          },
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              _isChecked = !_isChecked;
                            });
                          },
                          child: Icon(
                            Icons.check_box_outline_blank,
                            size: 24,
                          ),
                        ),
                  SizedBox(
                    width: Responsive.getWidth(9),
                  ),
                  WantText2(
                      text: "Make this as a default address",
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                      textColor: Color.fromRGBO(128, 128, 128, 1))
                ],
              ),
              SizedBox(height: Responsive.getHeight(20)),
              GeneralButton(
                Width: Responsive.getWidth(341),
                onTap: () {
                  Navigator.pop(context);
                  showCongratulationsDialog(context);
                },
                label: "Add",
                isBoarderRadiusLess: true,
              )
            ],
          ),
        );
      },
    );
  }
  void showCongratulationsDialog(BuildContext context) {
    showDialog(
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
        // height: Responsive.getHeight(422),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/check.png",height: Responsive.getWidth(78),width: Responsive.getWidth(78),),
                SizedBox(height: Responsive.getHeight(12)),
                WantText2(
                    text: "Congratulations!",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(8)),
                WantText2(
                    text: "Your new address has been added.",
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.regular,
                    textColor: Color.fromRGBO(128, 128, 128, 1)),
                SizedBox(height: Responsive.getHeight(24)),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(293),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    label: "Thanks",
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

class Address {
  final String id;
  final String address;
  final String type;
  Address({required this.id, required this.address, required this.type});
}

class AddressWidget extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onEdit;
  final VoidCallback onSelect;

  AddressWidget({
    required this.address,
    required this.isSelected,
    required this.onEdit,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(20),
            vertical: Responsive.getHeight(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            Responsive.getWidth(10),
          ),
          border: Border.all(color: Color.fromRGBO(230, 230, 230, 1), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/location.png",
              height: Responsive.getWidth(24),
              width: Responsive.getWidth(24),
            ),
            SizedBox(
              width: Responsive.getWidth(14),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Home",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(26, 26, 26, 1),
                        fontWeight: AppFontWeight.bold),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(4),
                  ),
                  Text(
                    address.address,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: Responsive.getWidth(10),
            ),
            Radio(
              focusColor: black,
              activeColor: black,
              value: true,
              groupValue: isSelected,
              onChanged: (value) => onSelect(),
            ),
          ],
        ),
      ),
    );
  }
}
