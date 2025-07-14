import 'dart:convert';

class CustomerExhibitionsModel {
  final int exhibitionId;
  final String exhibitionUniqueId;
  final String name;
  final String tagline;
  final String description;
  final String startDate;
  final String endDate;
  // final double amount;
  final String insertedDate;
  final String updatedDate;
  final CustomerExhibitionsCountry country;
  final CustomerExhibitionsState state;
  final CustomerExhibitionsCity city;
  final String address1;
  final String address2;
  final String contactNumber;
  final String contactEmail;
  final String websiteLink;
  final String status;
  final String logo;

  CustomerExhibitionsModel({
    required this.exhibitionId,
    required this.exhibitionUniqueId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.startDate,
    required this.endDate,
    // required this.amount,
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
    required this.logo,
  });

  factory CustomerExhibitionsModel.fromJson(Map<String, dynamic> json) {
    return CustomerExhibitionsModel(
      exhibitionId: json['exhibition_id'],
      exhibitionUniqueId: json['exhibition_unique_id'],
      name: json['name'],
      tagline: json['tagline'],
      description: json['description'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      // amount: json['amount'].toDouble(),
      insertedDate: json['inserted_date'] ?? "",
      updatedDate: json['updated_date'] ?? '',
      country: CustomerExhibitionsCountry.fromJson(json['country']),
      state: CustomerExhibitionsState.fromJson(json['state']),
      city: CustomerExhibitionsCity.fromJson(json['city']),
      address1: json['address1'] ?? "",
      address2: json['address2'] ?? "",
      contactNumber: json['contact_number'] ?? "",
      contactEmail: json['contact_email'] ?? "",
      websiteLink: json['website_link'] ?? "",
      status: json['status'] ?? "",
      logo: json['logo'] ?? "",
    );
  }
}

class CustomerExhibitionsCountry {
  final int countryId;
  final String countryName;

  CustomerExhibitionsCountry({required this.countryId, required this.countryName});

  factory CustomerExhibitionsCountry.fromJson(Map<String, dynamic> json) {
    return CustomerExhibitionsCountry(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }
}

class CustomerExhibitionsState {
  final int stateSubdivisionId;
  final String stateSubdivisionName;

  CustomerExhibitionsState({required this.stateSubdivisionId, required this.stateSubdivisionName});

  factory CustomerExhibitionsState.fromJson(Map<String, dynamic> json) {
    return CustomerExhibitionsState(
      stateSubdivisionId: json['state_subdivision_id'],
      stateSubdivisionName: json['state_subdivision_name'],
    );
  }
}

class CustomerExhibitionsCity {
  final int citiesId;
  final String nameOfCity;

  CustomerExhibitionsCity({required this.citiesId, required this.nameOfCity});

  factory CustomerExhibitionsCity.fromJson(Map<String, dynamic> json) {
    return CustomerExhibitionsCity(
      citiesId: json['cities_id'],
      nameOfCity: json['name_of_city'],
    );
  }
}
