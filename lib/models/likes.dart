class Likes {
  late String likes;

  Likes({
    required this.likes,
  });

  Likes.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['likes'] = likes;
    return data;
  }
}
