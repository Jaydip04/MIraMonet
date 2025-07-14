import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _switchValue = false;
  List notificationsOptions = [];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    List options = [
      "General Notifications",
      "Sound",
      "Vibrate",
      "Special Offers",
      "Promo & Discounts",
      "Payments",
      "Cahback",
      "App Updates",
      "New Service Available",
      "New Tips Available",
    ];
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
          child: SingleChildScrollView(
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
                      width: Responsive.getWidth(30),
                    ),
                    WantText2(
                        text: "Notification Settings",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack)
                  ],
                ),
                SizedBox(
                  height: Responsive.getHeight(25),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return notificationCard(
                      label: options[index],
                      value:
                          notificationsOptions.contains(index) ? true : false,
                      onChanged: (value) {
                        if (notificationsOptions.contains(index)) {
                          notificationsOptions.remove(index);
                        } else {
                          notificationsOptions.add(index);
                        }
                        setState(() {
                          _switchValue = value;
                        });
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget notificationCard({
    required String label,
    bool? value,
    Function(bool)? onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.getWidth(4)),
      padding: EdgeInsets.symmetric(vertical: Responsive.getHeight(15)),
      decoration: BoxDecoration(
        border: Border(top:  BorderSide(color: Color.fromRGBO(230, 230, 230, 1), width: 1),)
        // border: Border.symmetric(
        //   horizontal:
        //       BorderSide(color: Color.fromRGBO(230, 230, 230, 1), width: 1),
        // ),
      ),
      child: Row(
        children: [
          Expanded(
            child: WantText2(
                text: label,
                fontSize: Responsive.getFontSize(16),
                fontWeight: FontWeight.w500,
                textColor: textBlack),
          ),
          const SizedBox(width: 10),
          CupertinoSwitch(
            value: value ?? false,
            onChanged: onChanged,
            activeColor: textBlack11,
          ),
        ],
      ),
    );
  }
}
