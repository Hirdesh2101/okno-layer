// ignore_for_file: prefer_typing_uninitialized_variables

class MergeSort {
  void merge(List list, int leftIndex, int middleIndex, int rightIndex) {
    int leftSize = middleIndex - leftIndex + 1;
    int rightSize = rightIndex - middleIndex;

    List leftList = List.filled(leftSize, null, growable: false);
    List rightList = List.filled(rightSize, null, growable: false);

    for (int i = 0; i < leftSize; i++) {
      leftList[i] = list[leftIndex + i];
    }
    for (int j = 0; j < rightSize; j++) {
      rightList[j] = list[middleIndex + j + 1];
    }

    int i = 0, j = 0;
    int k = leftIndex;
    DateTime temp1, temp2;
    while (i < leftSize && j < rightSize) {
      temp1 = DateTime.parse(leftList[i]);
      temp2 = DateTime.parse(rightList[j]);
      if (temp2.isAfter(temp1) || temp2.isAtSameMomentAs(temp1)) {
        list[k] = leftList[i];
        i++;
      } else {
        list[k] = rightList[j];
        j++;
      }
      k++;
    }

    while (i < leftSize) {
      list[k] = leftList[i];
      i++;
      k++;
    }

    while (j < rightSize) {
      list[k] = rightList[j];
      j++;
      k++;
    }
  }

  void mergeSort(List list, int leftIndex, int rightIndex) {
    if (leftIndex < rightIndex) {
      int middleIndex = (rightIndex + leftIndex) ~/ 2;

      mergeSort(list, leftIndex, middleIndex);
      mergeSort(list, middleIndex + 1, rightIndex);

      merge(list, leftIndex, middleIndex, rightIndex);
    }
  }
}
