class ArtData {
  final int artDataId;
  final String artDataTitle;

  ArtData({required this.artDataId, required this.artDataTitle});

  factory ArtData.fromJson(Map<String, dynamic> json) {
    return ArtData(
      artDataId: json['art_data_id'],
      artDataTitle: json['art_data_title'],
    );
  }
}

class ArtResponse {
  final bool status;
  final List<ArtData> artData;

  ArtResponse({required this.status, required this.artData});

  factory ArtResponse.fromJson(Map<String, dynamic> json) {
    var artDataList = json['artData'] as List;
    List<ArtData> artData = artDataList.map((i) => ArtData.fromJson(i)).toList();

    return ArtResponse(
      status: json['status'],
      artData: artData,
    );
  }
}
