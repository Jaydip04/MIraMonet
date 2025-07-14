class WalletDetails {
  final bool status;
  final double platformDeduction;
  final double withdrawalAmount;
  final double balanceAmount;
  final double netProfit;
  final List<Transaction> transactions;
  final List<dynamic> withdrawalRequests;
  final String message;

  WalletDetails({
    required this.status,
    required this.platformDeduction,
    required this.withdrawalAmount,
    required this.balanceAmount,
    required this.netProfit,
    required this.transactions,
    required this.withdrawalRequests,
    required this.message,
  });

  factory WalletDetails.fromJson(Map<String, dynamic> json) {
    var list = json['transactions'] as List;
    List<Transaction> transactionsList = list.map((i) => Transaction.fromJson(i)).toList();

    return WalletDetails(
      status: json['status'],
      platformDeduction: json['platefarm_deduction'].toDouble(),
      withdrawalAmount: json['widthrawl_amount'].toDouble(),
      balanceAmount: json['balance_amount'].toDouble(),
      netProfit: json['net_profilt'].toDouble(),
      transactions: transactionsList,
      withdrawalRequests: json['widthdraw_request'],
      message: json['message'],
    );
  }
}

class Transaction {
  final int orderedArtId;
  final int artId;
  final String artName;
  final double price;
  final String art;
  final String artOrderStatus;
  final String date;
  final String time;

  Transaction({
    required this.orderedArtId,
    required this.artId,
    required this.artName,
    required this.price,
    required this.art,
    required this.artOrderStatus,
    required this.date,
    required this.time,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      orderedArtId: json['ordered_art_id'],
      artId: json['art_id'],
      artName: json['art_name'],
      price: json['price'].toDouble(),
      art: json['art'],
      artOrderStatus: json['art_order_status'],
      date: json['date'],
      time: json['time'],
    );
  }
}
