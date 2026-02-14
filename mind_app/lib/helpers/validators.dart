class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return "Username required";
    if (value.length < 3) return "Username too short";
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password required";
    if (value.length < 4) return "Password too short";
    return null;
  }
}
