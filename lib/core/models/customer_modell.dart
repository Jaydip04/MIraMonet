class CustomerResponse {
  final bool status;
  final String message;
  final CustomerData customerData;

  CustomerResponse({
    required this.status,
    required this.message,
    required this.customerData,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      status: json['status'],
      message: json['message'],
      customerData: CustomerData.fromJson(json['customer_data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'customer_data': customerData.toJson(),
    };
  }
}

class CustomerData {
  final String customerUniqueId;
  final String? customerProfile;
  final String name;
  String? artistName;
  final String role;
  final String email;
  final bool? isMiramonet;
  final String mobile;
  final String? miramonet_chat_id;
  final CustomerCountry? country;
  final CustomerStateSubdivision? state;
  final CustomerCity? city;
  final String? address;
  final String? zipCode;
  final String? introduction;

  CustomerData({
    required this.customerUniqueId,
    this.customerProfile,
    this.artistName,
    required this.name,
    required this.role,
    required this.email,
    required this.mobile,
    this.country,
    this.miramonet_chat_id,
    this.isMiramonet,
    this.state,
    this.city,
    this.address,
    this.zipCode,
    this.introduction,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      customerUniqueId: json['customer_unique_id'],
      customerProfile: json['customer_profile'],
      artistName: json['artist_name'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      mobile: json['mobile'],
      miramonet_chat_id: json['miramonet_chat_id'].toString() ?? "",
      country: json['country'] != null ? CustomerCountry.fromJson(json['country']) : null,
      state: json['state'] != null ? CustomerStateSubdivision.fromJson(json['state']) : null,
      city: json['city'] != null ? CustomerCity.fromJson(json['city']) : null,
      address: json['address'],
      zipCode: json['zip_code'],
      isMiramonet: json['isMiramonet'],
      introduction: json['introduction'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_unique_id': customerUniqueId,
      'customer_profile': customerProfile,
      'name': name,
      'role': role,
      'email': email,
      'mobile': mobile,
      'country': country?.toJson(),
      'state': state?.toJson(),
      'city': city?.toJson(),
      'address': address,
      'zip_code': zipCode,
    };
  }
}

class CustomerCountry {
  final int? countryId;
  final String? countryName;

  CustomerCountry({
    this.countryId,
    this.countryName,
  });

  factory CustomerCountry.fromJson(Map<String, dynamic> json) {
    return CustomerCountry(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_id': countryId,
      'country_name': countryName,
    };
  }
}

class CustomerStateSubdivision {
  final int? stateSubdivisionId;
  final String? stateSubdivisionName;

  CustomerStateSubdivision({
    this.stateSubdivisionId,
    this.stateSubdivisionName,
  });

  factory CustomerStateSubdivision.fromJson(Map<String, dynamic> json) {
    return CustomerStateSubdivision(
      stateSubdivisionId: json['state_subdivision_id'],
      stateSubdivisionName: json['state_subdivision_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state_subdivision_id': stateSubdivisionId,
      'state_subdivision_name': stateSubdivisionName,
    };
  }
}

class CustomerCity {
  final int? citiesId;
  final String? nameOfCity;

  CustomerCity({
    this.citiesId,
    this.nameOfCity,
  });

  factory CustomerCity.fromJson(Map<String, dynamic> json) {
    return CustomerCity(
      citiesId: json['cities_id'],
      nameOfCity: json['name_of_city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cities_id': citiesId,
      'name_of_city': nameOfCity,
    };
  }
}
