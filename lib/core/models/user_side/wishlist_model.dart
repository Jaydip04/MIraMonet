class Wishlist {
  bool status;
  List<WishlistItem> wishlistItems;

  Wishlist({required this.status, required this.wishlistItems});

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      status: json['status'],
      wishlistItems: List<WishlistItem>.from(
        json['wishlist_items'].map((item) => WishlistItem.fromJson(item)),
      ),
    );
  }
}

class WishlistItem {
  int wishlist_id;
  String artUniqueId;
  String title;
  String artistName;
  String artType;
  String edition;
  String price;
  String since;
  String pickupAddress;
  String pincode;
  String country;
  String state;
  String city;
  String frame;
  String paragraph;
  dynamic status;
  WishListCategory category;
  CountryDetails countryDetails;
  StateDetails stateDetails;
  CityDetails cityDetails;
  List<ArtAdditionalDetail> artAdditionalDetails;
  List<ArtImage> artImages;

  WishlistItem({
    required this.wishlist_id,
    required this.artUniqueId,
    required this.title,
    required this.artistName,
    required this.artType,
    required this.edition,
    required this.price,
    required this.since,
    required this.pickupAddress,
    required this.pincode,
    required this.country,
    required this.state,
    required this.city,
    required this.frame,
    required this.paragraph,
    this.status,
    required this.category,
    required this.countryDetails,
    required this.stateDetails,
    required this.cityDetails,
    required this.artAdditionalDetails,
    required this.artImages,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      wishlist_id: json['wishlist_id'],
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      artType: json['art_type'],
      edition: json['edition'],
      price: json['price'],
      since: json['since'],
      pickupAddress: json['pickup_address'],
      pincode: json['pincode'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      frame: json['frame'],
      paragraph: json['paragraph'],
      status: json['status'],
      category: WishListCategory.fromJson(json['category']),
      countryDetails: CountryDetails.fromJson(json['country_details']),
      stateDetails: StateDetails.fromJson(json['state_details']),
      cityDetails: CityDetails.fromJson(json['city_details']),
      artAdditionalDetails: List<ArtAdditionalDetail>.from(
        json['art_additional_details'].map((item) => ArtAdditionalDetail.fromJson(item)),
      ),
      artImages: List<ArtImage>.from(
        json['artImages'].map((item) => ArtImage.fromJson(item)),
      ),
    );
  }
}

class WishListCategory {
  int categoryId;
  String categoryName;
  String categoryIcon;
  String categoryImage;
  String subText;

  WishListCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryImage,
    required this.subText,
  });

  factory WishListCategory.fromJson(Map<String, dynamic> json) {
    return WishListCategory(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      categoryImage: json['category_image'],
      subText: json['sub_text'],
    );
  }
}

class CountryDetails {
  int countryId;
  String countryName;

  CountryDetails({required this.countryId, required this.countryName});

  factory CountryDetails.fromJson(Map<String, dynamic> json) {
    return CountryDetails(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }
}

class StateDetails {
  int stateId;
  String stateName;

  StateDetails({required this.stateId, required this.stateName});

  factory StateDetails.fromJson(Map<String, dynamic> json) {
    return StateDetails(
      stateId: json['state_id'],
      stateName: json['state_name'],
    );
  }
}

class CityDetails {
  int cityId;
  String cityName;

  CityDetails({required this.cityId, required this.cityName});

  factory CityDetails.fromJson(Map<String, dynamic> json) {
    return CityDetails(
      cityId: json['city_id'],
      cityName: json['city_name'],
    );
  }
}

class ArtAdditionalDetail {
  ArtData artData;
  String description;

  ArtAdditionalDetail({required this.artData, required this.description});

  factory ArtAdditionalDetail.fromJson(Map<String, dynamic> json) {
    return ArtAdditionalDetail(
      artData: ArtData.fromJson(json['art_data']),
      description: json['description'],
    );
  }
}

class ArtData {
  int artDataId;
  String artDataTitle;

  ArtData({required this.artDataId, required this.artDataTitle});

  factory ArtData.fromJson(Map<String, dynamic> json) {
    return ArtData(
      artDataId: json['art_data_id'],
      artDataTitle: json['art_data_title'],
    );
  }
}

class ArtImage {
  int artImageId;
  String artType;
  String image;

  ArtImage({required this.artImageId, required this.artType, required this.image});

  factory ArtImage.fromJson(Map<String, dynamic> json) {
    return ArtImage(
      artImageId: json['art_image_id'],
      artType: json['art_type'],
      image: json['image'],
    );
  }
}
