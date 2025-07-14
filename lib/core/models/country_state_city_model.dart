class Country {
  final int id;
  final String name;
  final String? countryCodeChar2;
  final String? countryCodeChar3;
  final String? unRegion;
  final String? unSubregion;
  final String? zone;

  Country({
    required this.id,
    required this.name,
    this.countryCodeChar2,
    this.countryCodeChar3,
    this.unRegion,
    this.unSubregion,
    this.zone,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['country_id'],
      name: json['country_name'],
      countryCodeChar2: json['country_code_char2'],
      countryCodeChar3: json['country_code_char3'],
      unRegion: json['un_region'],
      unSubregion: json['un_subregion'],
      zone: json['zone'],
    );
  }
}

class StateModel {
  final int id;
  final int countryId;
  final String? countryCodeChar2;
  final String? countryCodeChar3;
  final String name;
  final String? stateSubdivisionAlternateNames;
  final String primaryLevelName;
  final String? stateSubdivisionCode;
  final String? ini;

  StateModel({
    required this.id,
    required this.countryId,
    this.countryCodeChar2,
    this.countryCodeChar3,
    required this.name,
    this.stateSubdivisionAlternateNames,
    required this.primaryLevelName,
    this.stateSubdivisionCode,
    this.ini,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['state_subdivision_id'],
      countryId: json['country_id'],
      countryCodeChar2: json['country_code_char2'],
      countryCodeChar3: json['country_code_char3'],
      name: json['state_subdivision_name'],
      stateSubdivisionAlternateNames: json['state_subdivision_alternate_names'],
      primaryLevelName: json['primary_level_name'],
      stateSubdivisionCode: json['state_subdivision_code'],
      ini: json['ini'],
    );
  }
}

class City {
  final int id;
  final String name;
  final int stateId;
  final String? stateCode;
  final String stateName;
  final double latitude;
  final double longitude;

  City({
    required this.id,
    required this.name,
    required this.stateId,
    this.stateCode,
    required this.stateName,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['cities_id'] ?? 0,
      name: json['name_of_city'] ?? 'Unknown',
      stateId: int.parse(json['state_id']),
      stateCode: json['state_code'],
      stateName: json['state_name'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
    );
  }
}