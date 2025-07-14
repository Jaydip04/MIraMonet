import 'package:artist/config/colors.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/wallet_pages/show_transactions_item_details_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/wallet_pages/withdraw_send_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/models/wallet_details_model.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import 'artist_transactions_history_screen.dart';

class ArtistWalletScreen extends StatefulWidget {
  const ArtistWalletScreen({super.key});

  @override
  State<ArtistWalletScreen> createState() => _ArtistWalletScreenState();
}

class _ArtistWalletScreenState extends State<ArtistWalletScreen> {
  late Future<Map<String, dynamic>> futureWalletDetails;
  final ApiService apiService = ApiService();
  late List<dynamic> transactions = [];
  List<dynamic> privateArtIncome = [];
  late List<dynamic> widthdraw_request = [];

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
    futureWalletDetails =
        apiService.fetchWalletDetails(customerUniqueId, 'seller');
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
          child: SingleChildScrollView(
            child: FutureBuilder<Map<String, dynamic>>(
              future: futureWalletDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: Responsive.getMainWidth(context),
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
                  return Center(child: Text('No data available'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data available'));
                } else {
                  Map<String, dynamic> walletDetails = snapshot.data!;
                  transactions = walletDetails['transactions'];
                  widthdraw_request = walletDetails['widthdraw_request'];
                  privateArtIncome = walletDetails["privateData"];

                  List<dynamic> allTransactions = transactions;
                  List<dynamic> allwidthdraw_request = widthdraw_request;
                  List<dynamic> incomeTransactions =
                      transactions.where((transaction) {
                    return transaction['art_order_status'] == 'Delivered';
                  }).toList();

                  List<dynamic> expenseTransactions =
                      widthdraw_request.where((withdrawal) {
                    return withdrawal['amount'] != "";
                  }).toList();
                  print(expenseTransactions);
                  return Column(
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
                                borderRadius: BorderRadius.circular(
                                    Responsive.getWidth(12)),
                                border: Border.all(
                                    color: textFieldBorderColor, width: 1.0),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.getWidth(100)),
                          WantText2(
                            text: "Wallet",
                            fontSize: Responsive.getFontSize(18),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack,
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.getHeight(17)),
                      Divider(color: Color.fromRGBO(230, 230, 230, 1)),
                      SizedBox(height: Responsive.getHeight(22)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: Responsive.getHeight(80),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WantText2(
                                    text: "Total Balance",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor:
                                        Color.fromRGBO(69, 90, 100, 1.0)),
                                WantText2(
                                    text: "\$${walletDetails['total_ammount']}",
                                    fontSize: Responsive.getFontSize(32),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: Color.fromRGBO(6, 25, 65, 1.0))
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => WithdrawSendRequestScreen(
                                            customer_unique_id:
                                                customerUniqueID.toString(),
                                            total_amount:
                                                walletDetails['total_ammount']
                                                    .toString(),
                                          )));
                            },
                            child: Container(
                              height: Responsive.getHeight(40),
                              width: Responsive.getWidth(170),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'WITHDRAW REQUEST',
                                        style: GoogleFonts.poppins(
                                          letterSpacing: 1.5,
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(12),
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
                      SizedBox(height: Responsive.getHeight(19)),
                      Container(
                        width: Responsive.getWidth(332),
                        height: Responsive.getHeight(110),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Responsive.getWidth(20)),
                                color: Color.fromRGBO(243, 252, 247, 1),
                              ),
                              width: Responsive.getWidth(154),
                              height: Responsive.getHeight(122),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/income.png",
                                    height: Responsive.getWidth(24),
                                    width: Responsive.getWidth(24),
                                  ),
                                  WantText2(
                                    text: "Income",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: Color.fromRGBO(83, 102, 142, 1),
                                  ),
                                  WantText2(
                                    text: "\$${walletDetails['income_amount']}",
                                    fontSize: Responsive.getFontSize(18),
                                    fontWeight: AppFontWeight.bold,
                                    textColor: Color.fromRGBO(39, 174, 96, 1),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Responsive.getWidth(20)),
                                color: Color.fromRGBO(254, 241, 241, 1),
                              ),
                              width: Responsive.getWidth(154),
                              height: Responsive.getHeight(122),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/expense.png",
                                    height: Responsive.getWidth(24),
                                    width: Responsive.getWidth(24),
                                  ),
                                  WantText2(
                                    text: "Withdraw",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: Color.fromRGBO(83, 102, 142, 1),
                                  ),
                                  WantText2(
                                    text:
                                        "\$${walletDetails['widthrawl_amount']}",
                                    fontSize: Responsive.getFontSize(18),
                                    fontWeight: AppFontWeight.bold,
                                    textColor: Color.fromRGBO(231, 76, 60, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(19)),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WantText2(
                                text: "Transactions History",
                                fontSize: Responsive.getFontSize(18),
                                fontWeight: AppFontWeight.bold,
                                textColor: Color.fromRGBO(6, 25, 65, 1),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ArtistTransactionsHistoryScreen(),
                                    ),
                                  );
                                },
                                child: WantText2(
                                  text: "View more",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: Color.fromRGBO(83, 102, 142, 1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(20)),
                          Container(
                            height: Responsive.getHeight(380),
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  TabBar(
                                    indicatorColor: black,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    labelColor: Colors.black,
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    dividerColor:
                                        Color.fromRGBO(238, 239, 242, 100),
                                    labelStyle: GoogleFonts.poppins(
                                        color: black,
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: AppFontWeight.medium,
                                        letterSpacing: 1.5),
                                    tabs: [
                                      // Tab(text: "All"),
                                      Tab(text: "Art Income"),
                                      Tab(text: "Private Art Income"),
                                      Tab(text: "Withdraw"),
                                    ],
                                  ),
                                  Flexible(
                                    child: TabBarView(
                                      children: [
                                        // TransactionList(
                                        //     customerUniqueID:
                                        //         customerUniqueID.toString(),
                                        //     type: "all",
                                        //     transactions: allTransactions),
                                        TransactionList(
                                            customerUniqueID:
                                                customerUniqueID.toString(),
                                            type: "income",
                                            transactions: incomeTransactions),
                                        PrivateTransactionList(
                                            customerUniqueID:
                                                customerUniqueID.toString(),
                                            type: "income",
                                            transactions: privateArtIncome),
                                        widthdraw_requestList(
                                            customerUniqueID:
                                                customerUniqueID.toString(),
                                            type: "expenses",
                                            widthdraw_request:
                                                expenseTransactions),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String type;
  final String customerUniqueID;
  final List<dynamic> transactions;

  TransactionList(
      {required this.type,
      required this.transactions,
      required this.customerUniqueID});

  @override
  Widget build(BuildContext context) {
    return transactions.length == 0
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/profile_image/solar_wallet.png",
                  width: Responsive.getWidth(50),
                  height: Responsive.getWidth(50),
                ),
                SizedBox(height: Responsive.getHeight(10)),
                WantText2(
                  text: "No Art Income!",
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.semiBold,
                  textColor: textBlack11,
                ),
              ],
            ),
          )
        : ListView.builder(
            // padding: EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              if (transaction != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ShowTransactionsItemDetailsScreen(
                                  customer_id: customerUniqueID,
                                  ordered_art_id:
                                      transaction['ordered_art_id'].toString(),
                                )));
                  },
                  child: _buildTransactionItem(
                    transaction['image'] ?? "",
                    transaction['art_order_status'],
                    transaction['art_name'],
                    transaction['price'].toString(),
                    transaction['portal_percentages'].toString(),
                    transaction['platefarm_deduction'].toString(),
                    transaction['total_after_deducted'].toString(),
                    transaction['date'],
                  ),
                );
              } else {
                return Container();
              }
            },
          );
  }

  Widget _buildTransactionItem(
    String image,
    String type,
    String artName,
    String amount,
    String portal_percentages,
    String platefarm_deduction,
    String total_after_deducted,
    String date,
  ) {
    final Color color = (type == "Delivered")
        ? Color.fromRGBO(39, 174, 96, 1.0)
        : Color.fromRGBO(231, 59, 59, 1.0);

    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('d/M/yyyy').format(dateTime);
    String convertDate(String inputDate) {
      DateTime date = DateTime.parse(inputDate);
      DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
      return DateFormat("MMM dd, yyyy").format(newDate);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image.isEmpty
                        ? Container(
                            height: 44,
                            width: 44,
                            decoration:
                                BoxDecoration(color: Colors.grey.shade100),
                            child: Center(
                              child: WantText2(
                                  text: artName[0],
                                  fontSize: Responsive.getWidth(18),
                                  fontWeight: FontWeight.bold,
                                  textColor: Colors.black),
                            ),
                          )
                        : Image.network(
                            image,
                            height: 44,
                            width: 44,
                            fit: BoxFit.contain,
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
                          text: artName,
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(83, 102, 142, 1.0),
                        ),
                      ),
                      WantText2(
                        text: convertDate(date),
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.medium,
                        textColor: Color.fromRGBO(197, 202, 211, 1.0),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              WantText2(
                text: "\$${amount}",
                fontSize: Responsive.getFontSize(12),
                fontWeight: AppFontWeight.medium,
                textColor: Color.fromRGBO(83, 102, 142, 1.0),
              ),
              WantText2(
                text: "\$${platefarm_deduction}(${portal_percentages})",
                fontSize: Responsive.getFontSize(12),
                fontWeight: AppFontWeight.medium,
                textColor: Color.fromRGBO(83, 102, 142, 1.0),
              ),
              WantText2(
                text: "\$${total_after_deducted}",
                fontSize: Responsive.getFontSize(16),
                fontWeight: AppFontWeight.bold,
                textColor: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrivateTransactionList extends StatelessWidget {
  final String type;
  final String customerUniqueID;
  final List<dynamic> transactions;

  PrivateTransactionList(
      {required this.type,
      required this.transactions,
      required this.customerUniqueID});

  @override
  Widget build(BuildContext context) {
    return transactions.length == 0
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/profile_image/solar_wallet.png",
                  width: Responsive.getWidth(50),
                  height: Responsive.getWidth(50),
                ),
                SizedBox(height: Responsive.getHeight(10)),
                WantText2(
                  text: "No Art Income!",
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.semiBold,
                  textColor: textBlack11,
                ),
              ],
            ),
          )
        : ListView.builder(
            // padding: EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              if (transaction != null) {
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (_) => ShowTransactionsItemDetailsScreen(
                    //           customer_id: customerUniqueID,
                    //           ordered_art_id:
                    //           transaction['ordered_art_id'].toString(),
                    //         )));
                  },
                  child: _buildTransactionItem(
                    transaction['image'] ?? "",
                    transaction['art_title'],
                    transaction['artist_amount'].toString(),
                    transaction['sold_date'],
                  ),
                );
              } else {
                return Container();
              }
            },
          );
  }

  Widget _buildTransactionItem(
    String image,
    String artName,
    String amount,
    String date,
  ) {
    String convertDate(String inputDate) {
      DateTime date = DateTime.parse(inputDate);
      DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
      return DateFormat("MMM dd, yyyy").format(newDate);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image.isEmpty
                        ? Container(
                            height: 44,
                            width: 44,
                            decoration:
                                BoxDecoration(color: Colors.grey.shade100),
                            child: Center(
                              child: WantText2(
                                  text: artName[0],
                                  fontSize: Responsive.getWidth(18),
                                  fontWeight: FontWeight.bold,
                                  textColor: Colors.black),
                            ),
                          )
                        : Image.network(
                            image,
                            height: 44,
                            width: 44,
                            fit: BoxFit.contain,
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
                          text: artName,
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(83, 102, 142, 1.0),
                        ),
                      ),
                      WantText2(
                        text: convertDate(date),
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.medium,
                        textColor: Color.fromRGBO(197, 202, 211, 1.0),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          WantText2(
            text: "\$${amount}",
            fontSize: Responsive.getFontSize(16),
            fontWeight: AppFontWeight.bold,
            textColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class widthdraw_requestList extends StatelessWidget {
  final String type;
  final String customerUniqueID;
  final List<dynamic> widthdraw_request;

  widthdraw_requestList(
      {required this.type,
      required this.widthdraw_request,
      required this.customerUniqueID});

  @override
  Widget build(BuildContext context) {
    return widthdraw_request.length == 0
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/profile_image/solar_wallet.png",
                  width: Responsive.getWidth(50),
                  height: Responsive.getWidth(50),
                ),
                SizedBox(height: Responsive.getHeight(10)),
                WantText2(
                  text: "No Withdraw Request!",
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.semiBold,
                  textColor: textBlack11,
                ),
              ],
            ),
          )
        : ListView.builder(
            // padding: EdgeInsets.all(16.0),
            itemCount: widthdraw_request.length,
            itemBuilder: (context, index) {
              final transaction = widthdraw_request[index];
              if (transaction != null) {
                return _buildTransactionItem(
                  transaction['seller_image'] ?? "",
                  transaction['status'],
                  transaction['seller_name'],
                  transaction['amount'].toString(),
                  transaction['inserted_date'],
                );
              } else {
                return Container();
              }
            },
          );
  }

  Widget _buildTransactionItem(
      String image, String type, String artName, String amount, String date) {
    final Color color = (type == "Approved")
        ? Color.fromRGBO(39, 174, 96, 1.0)
        : Color.fromRGBO(231, 59, 59, 1.0);

    String convertDate(String inputDate) {
      DateTime date = DateTime.parse(inputDate);
      DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
      return DateFormat("MMM dd, yyyy").format(newDate);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image.isEmpty
                        ? Container(
                            height: 44,
                            width: 44,
                            decoration:
                                BoxDecoration(color: Colors.grey.shade100),
                            child: Center(
                              child: WantText2(
                                  text: artName[0],
                                  fontSize: Responsive.getWidth(18),
                                  fontWeight: FontWeight.bold,
                                  textColor: Colors.black),
                            ),
                          )
                        : Image.network(
                            image,
                            height: 44,
                            width: 44,
                            fit: BoxFit.contain,
                          ),
                  ),
                  SizedBox(
                    width: Responsive.getWidth(10),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText2(
                        text: artName,
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.medium,
                        textColor: Color.fromRGBO(83, 102, 142, 1.0),
                      ),
                      WantText2(
                        text: convertDate(date),
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.medium,
                        textColor: Color.fromRGBO(197, 202, 211, 1.0),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              WantText2(
                text: "\$${amount}",
                fontSize: Responsive.getFontSize(16),
                fontWeight: AppFontWeight.bold,
                textColor: color,
              ),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: WantText2(
                  text: "${type}",
                  fontSize: Responsive.getFontSize(8),
                  fontWeight: AppFontWeight.semiBold,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
