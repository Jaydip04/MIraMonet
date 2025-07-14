class ArtReviewModel {
  String? artUniqueId;
  String? title;
  String? artistName;
  String? edition;
  String? since;
  String? price;
  String? frame;
  String? status;
  String? pickupAddress;
  String? paragraph;
  String? colorCode;
  bool? isAdd;
  bool? isSubmit;
  String? artCount;
  List<String>? images;
  List<ArtReviewDetail>? details;

  ArtReviewModel({
    this.artUniqueId,
    this.title,
    this.artistName,
    this.since,
    this.edition,
    this.price,
    this.frame,
    this.status,
    this.pickupAddress,
    this.paragraph,
    this.images,
    this.isAdd,
    this.isSubmit,
    this.artCount,
    this.colorCode,
    this.details,
  });

  factory ArtReviewModel.fromJson(Map<String, dynamic> json) {
    List<String>? imageList = json['image'] != null
        ? (json['image'] as List)
        .map((e) => e['image'] as String)
        .toList()
        : null;

    List<ArtReviewDetail>? detailsList = json['details'] != null
        ? (json['details'] as List)
        .map((e) => ArtReviewDetail.fromJson(e))
        .toList()
        : null;

    return ArtReviewModel(
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      edition: json['edition'],
      isAdd: json['isAdd'],
      artCount: json['artCount']?.toString(),
      isSubmit: json['isSubmit'],
      frame: json['frame'],
      status: json['status'],
      price: json['price']?.toString(),
      since: json['since'],
      colorCode: json['colorCode'],
      pickupAddress: json['pickup_address'],
      paragraph: json['paragraph'],
      images: imageList,
      details: detailsList,
    );
  }
}

class ArtReviewDetail {
  String? artDataTitle;
  String? description;

  ArtReviewDetail({
    this.artDataTitle,
    this.description,
  });

  factory ArtReviewDetail.fromJson(Map<String, dynamic> json) {
    return ArtReviewDetail(
      artDataTitle: json['art_data_title'],
      description: json['description'],
    );
  }
}
