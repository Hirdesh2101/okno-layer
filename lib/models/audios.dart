class AudioDetails {
  String url;
  String songname;
  String artistname;
  String thumbnail;
  int playingstatus;

  AudioDetails({
    required this.url,
    required this.thumbnail,
    required this.artistname,
    required this.songname,
    required this.playingstatus,
  });
  AudioDetails.fromJson(Map<dynamic, dynamic> json)
      : url = json['url'] ?? '',
        artistname = json['artistname'] ?? '',
        songname = json['songname'] ?? '',
        thumbnail = json['thumbnail'] ?? '',
        playingstatus = 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['thumbnail'] = thumbnail;
    data['songname'] = songname;
    data['artistname'] = artistname;
    data['url'] = url;
    return data;
  }
}
