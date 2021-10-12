class BrandDetails {
  List<dynamic> watchedvideo;
  List<dynamic> viewedurl;
  List<dynamic> viewedproduct;
  List<dynamic> reportedby;
  BrandDetails({
    required this.watchedvideo,
    required this.reportedby,
    required this.viewedproduct,
    required this.viewedurl,
  });
  BrandDetails.fromJson(Map<dynamic, dynamic> json)
      : watchedvideo = json['WatchedVideo'] ?? [],
        viewedproduct = json['ViewedProduct'] ?? [],
        viewedurl = json['ViewedUrl'] ?? [],
        reportedby = json['ReportedBy'] ?? [];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ReportedBy'] = reportedby;
    data['ViewedUrl'] = viewedurl;
    data['ViewedProduct'] = viewedproduct;
    data['WatchedVideo'] = watchedvideo;
    return data;
  }
}
