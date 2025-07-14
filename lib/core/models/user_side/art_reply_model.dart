class ArtReply {
  final int? senderId;
  final int? receiverId;
  final String? senderUniqueId;
  final String? receiverUniqueId;
  String? reciver_fcm_token;
  final String? message;
  final String? insertedDate;
  final String? insertedTime;
  final String? image;

  ArtReply({
     this.senderId,
     this.receiverId,
     this.senderUniqueId,
     this.receiverUniqueId,
     this.reciver_fcm_token,
     this.message,
     this.insertedDate,
     this.insertedTime,
    this.image,
  });

  factory ArtReply.fromJson(Map<String, dynamic> json) {
    return ArtReply(
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      senderUniqueId: json['sender_unique_id'],
      receiverUniqueId: json['receiver_unique_id'],
      reciver_fcm_token: json['reciver_fcm_token'] ?? "",
      message: json['message'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
      image: json['image'],
    );
  }
}

class HelpEnquiryResponse {
  final bool status;
  final HelpEnquiryData? data;

  HelpEnquiryResponse({
    required this.status,
    required this.data,
  });

  factory HelpEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return HelpEnquiryResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? HelpEnquiryData.fromJson(json['data'])
          : null,
    );
  }
}

class HelpEnquiryData {
  final String helpCenterChatId;
  final List<ChatDetail> chatDetails;
  final ArtData artData;
  final String enquiryCategoryName;
  final String issue;
  bool? isReturnApproved;
  final List<IssueImage> issueImages;

  HelpEnquiryData({
    required this.helpCenterChatId,
    required this.chatDetails,
    required this.artData,
    required this.enquiryCategoryName,
    required this.issue,
    this.isReturnApproved,
    required this.issueImages,
  });

  factory HelpEnquiryData.fromJson(Map<String, dynamic> json) {
    return HelpEnquiryData(
      helpCenterChatId: json['help_center_chat_id'] ?? '',
      chatDetails: (json['chatDetails'] as List<dynamic>?)
          ?.map((item) => ChatDetail.fromJson(item))
          .toList() ??
          [],
      artData: ArtData.fromJson(json['artData'] ?? {}),
      enquiryCategoryName: json['enquiryCategoryName'] ?? '',
      issue: json['issue'] ?? '',
      isReturnApproved: json['isReturnApproved'] ?? false,
      issueImages: (json['issueImages'] as List<dynamic>?)
          ?.map((item) => IssueImage.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class ChatDetail {
  final int senderId;
  final int receiverId;
  final String senderUniqueId;
  final String receiverUniqueId;
  final String insertedDate;
  final String insertedTime;
  final String? message;
  final String? image;

  ChatDetail({
    required this.senderId,
    required this.receiverId,
    required this.senderUniqueId,
    required this.receiverUniqueId,
    required this.insertedDate,
    required this.insertedTime,
    this.message,
    this.image,
  });

  factory ChatDetail.fromJson(Map<String, dynamic> json) {
    return ChatDetail(
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      senderUniqueId: json['sender_unique_id'] ?? '',
      receiverUniqueId: json['receiver_unique_id'] ?? '',
      insertedDate: json['inserted_date'] ?? '',
      insertedTime: json['inserted_time'] ?? '',
      message: json['message'],
      image: json['image'],
    );
  }
}

class ArtData {
  final String title;
  final String image;

  ArtData({
    required this.title,
    required this.image,
  });

  factory ArtData.fromJson(Map<String, dynamic> json) {
    return ArtData(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class IssueImage {
  final int helpCenterImageId;
  final int helpCenterChatId;
  final String image;
  final String? insertedDate;
  final String? insertedTime;

  IssueImage({
    required this.helpCenterImageId,
    required this.helpCenterChatId,
    required this.image,
    this.insertedDate,
    this.insertedTime,
  });

  factory IssueImage.fromJson(Map<String, dynamic> json) {
    return IssueImage(
      helpCenterImageId: json['help_center_image_id'] ?? 0,
      helpCenterChatId: json['help_center_chat_id'] ?? 0,
      image: json['image'] ?? '',
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}


