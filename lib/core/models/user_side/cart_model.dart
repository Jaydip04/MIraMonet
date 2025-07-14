import 'dart:convert';

class CartModel {
  final bool status;
  final String total;
  final String payableamout;
  final String totalTax;
  final String totalServiceFee;
  final String tax_per;
  final String buyer_premiumAmountFee;
  final String buyer_premium;
  final String service_per;
  final List<ArtData> data;

  CartModel({
    required this.status,
    required this.total,
    required this.payableamout,
    required this.totalTax,
    required this.totalServiceFee,
    required this.tax_per,
    required this.buyer_premiumAmountFee,
    required this.buyer_premium,
    required this.service_per,
    required this.data,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      status: json['status'],
      total: json['total'].toString(),
      payableamout: json['payableamout'].toString(),
      totalTax: json['totalTax'].toString(),
      buyer_premiumAmountFee: json['buyer_premiumAmountFee'].toString(),
      buyer_premium: json['buyer_premium'].toString(),
      totalServiceFee: json['totalServiceFee'].toString(),
      tax_per: json['tax_per'].toString(),
      service_per: json['service_per'].toString(),
      data: List<ArtData>.from(json['data'].map((x) => ArtData.fromJson(x))),
    );
  }
}

class ArtData {
  final int artCartId;
  final String artistUniqueId;
  final String artist_fcm_token;
  final String artUniqueId;
  final String title;
  final String artistName;
  final String artType;
  final String edition;
  final String price;
  final String since;
  final String pickupAddress;
  final String pincode;
  final CountryDetails countryDetails;
  final StateDetails stateDetails;
  final CityDetails cityDetails;
  final List<ArtImage> artImages;

  ArtData({
    required this.artCartId,
    required this.artistUniqueId,
    required this.artist_fcm_token,
    required this.artUniqueId,
    required this.title,
    required this.artistName,
    required this.artType,
    required this.edition,
    required this.price,
    required this.since,
    required this.pickupAddress,
    required this.pincode,
    required this.countryDetails,
    required this.stateDetails,
    required this.cityDetails,
    required this.artImages,
  });

  factory ArtData.fromJson(Map<String, dynamic> json) {
    return ArtData(
      artCartId: json['art_cart_id'],
      artistUniqueId: json['artist_unique_id'],
      artist_fcm_token: json['artist_fcm_token'] ?? "",
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      artType: json['art_type'],
      edition: json['edition'],
      price: json['price'],
      since: json['since'],
      pickupAddress: json['pickup_address'],
      pincode: json['pincode'],
      countryDetails: CountryDetails.fromJson(json['country_details']),
      stateDetails: StateDetails.fromJson(json['state_details']),
      cityDetails: CityDetails.fromJson(json['city_details']),
      artImages: List<ArtImage>.from(
          json['artImages'].map((x) => ArtImage.fromJson(x))),
    );
  }
}

class CountryDetails {
  final int countryId;
  final String countryName;

  CountryDetails({required this.countryId, required this.countryName});

  factory CountryDetails.fromJson(Map<String, dynamic> json) {
    return CountryDetails(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }
}

class StateDetails {
  final int stateId;
  final String stateName;

  StateDetails({required this.stateId, required this.stateName});

  factory StateDetails.fromJson(Map<String, dynamic> json) {
    return StateDetails(
      stateId: json['state_id'],
      stateName: json['state_name'],
    );
  }
}

class CityDetails {
  final int cityId;
  final String cityName;

  CityDetails({required this.cityId, required this.cityName});

  factory CityDetails.fromJson(Map<String, dynamic> json) {
    return CityDetails(
      cityId: json['city_id'],
      cityName: json['city_name'],
    );
  }
}

class ArtImage {
  final int artImageId;
  final String artType;
  final String image;

  ArtImage(
      {required this.artImageId, required this.artType, required this.image});

  factory ArtImage.fromJson(Map<String, dynamic> json) {
    return ArtImage(
      artImageId: json['art_image_id'],
      artType: json['art_type'],
      image: json['image'],
    );
  }
}
