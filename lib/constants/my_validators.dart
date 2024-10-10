class MyValidators {
  static String? uploadProdTexts({String? value, String? toBeReturnedString}) {
    if (value!.isEmpty) {
      return toBeReturnedString;
    } else {
      return null;
    }
  }
}
