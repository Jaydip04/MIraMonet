class OrderResponse {
  final bool status;
  final List<OrderData> orderAllData;

  OrderResponse({required this.status, required this.orderAllData});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    var list = json['OrderAllData'] as List;
    List<OrderData> orderDataList = list.map((i) => OrderData.fromJson(i)).toList();

    return OrderResponse(status: json['status'], orderAllData: orderDataList);
  }
}

class OrderData {
  // final OrderDetails orderDetails;
  final List<ArtDetails> artDetails;

  OrderData({
    // required this.orderDetails,
    required this.artDetails});

  factory OrderData.fromJson(Map<String, dynamic> json) {
    var list = json['art_details'] as List;
    List<ArtDetails> artList = list.map((i) => ArtDetails.fromJson(i)).toList();

    return OrderData(
        // orderDetails: OrderDetails.fromJson(json['order_details']),
        artDetails: artList);
  }
}

// class OrderDetails {
//   final int orderId;
//   final String orderUniqueId;
//   final String orderStatus;
//   final int customerId;
//   final dynamic trackingId;
//   final dynamic trackingStatus;
//   final String amount;
//   final String insertedDate;
//
//   OrderDetails({
//     required this.orderId,
//     required this.orderUniqueId,
//     required this.orderStatus,
//     required this.customerId,
//     this.trackingId,
//     this.trackingStatus,
//     required this.amount,
//     required this.insertedDate,
//   });
//
//   factory OrderDetails.fromJson(Map<String, dynamic> json) {
//     return OrderDetails(
//       orderId: json['order_id'],
//       orderUniqueId: json['order_unique_id'],
//       orderStatus: json['order_status'],
//       customerId: json['customer_id'],
//       trackingId: json['tracking_id'],
//       trackingStatus: json['tracking_status'],
//       amount: json['amount'],
//       insertedDate: json['inserted_date'],
//     );
//   }
// }

class ArtDetails {
  final String title;
  final String artUniqueId;
  final String price;
  final String artOrderStatus;
  String? order_unique_id;
  String? fcmToken;
  final String tracking_status;
  final String images;
  final String frame;
  final String edition;
  final String artistName;
  final String artist_unique_id;
  final String colorCode;
  final bool isReturn;
  final bool isTrack;
  final bool isFeedback;

  ArtDetails({
    required this.title,
    required this.artUniqueId,
    required this.price,
    required this.artOrderStatus,
    required this.order_unique_id,
    required this.tracking_status,
    required this.images,
    required this.frame,
    required this.edition,
    required this.artistName,
    required this.artist_unique_id,
    required this.isReturn,
    required this.isTrack,
    required this.isFeedback,
    this.fcmToken,
    required this.colorCode,
  });

  factory ArtDetails.fromJson(Map<String, dynamic> json) {
    return ArtDetails(
      title: json['title'] ?? "",
      fcmToken: json['fcm_token'] ?? json['artist_fcm_token'] ?? "",
      artUniqueId: json['art_unique_id'] ?? "",
      price: json['price'] ?? "",
      artOrderStatus: json['art_order_status'] ?? "",
      order_unique_id: json['order_unique_id'] ?? "",
      tracking_status: json['tracking_status'] ?? "",
      images: json['images'] ?? "",
      frame: json['frame'] ?? "",
      edition: json['edition'] ?? "",
      artistName: json['artist_name'] ?? "",
      artist_unique_id: json['artist_unique_id'] ?? "",
      isReturn: json['isReturn'] ?? false,
      isTrack: json['isTrack'] ?? false,
      isFeedback: json['isFeedback'] ?? false,
      colorCode: json['colorCode'] ?? "",
    );
  }
}
