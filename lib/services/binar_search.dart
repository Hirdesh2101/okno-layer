import '../models/video.dart';

class BinarySearch {
  int count(List<Video> arr, int numElems, String target) {
    int low = 0, high = numElems - 1, ans = -1;

    var time2 = DateTime.parse(target);
    while (low <= high) {
      int mid = ((low + high) / 2).floor();
      var time = DateTime.parse(arr[mid].id);
      if (time.isAtSameMomentAs(time2)) {
        ans = mid;
        break;
      } else if (time2.isAfter(time)) {
        low = mid + 1;
      } else if (time2.isBefore(time)) {
        high = mid - 1;
      }
    }
    return ans;
  }

  int count2(List arr, int numElems, String target) {
    int low = 0, high = numElems - 1, ans = -1;

    var time2 = DateTime.parse(target);
    while (low <= high) {
      int mid = ((low + high) / 2).floor();
      var time = DateTime.parse(arr[mid]);
      if (time.isAtSameMomentAs(time2)) {
        ans = mid;
        break;
      } else if (time2.isAfter(time)) {
        low = mid + 1;
      } else if (time2.isBefore(time)) {
        high = mid - 1;
      }
    }
    return ans;
  }
}
