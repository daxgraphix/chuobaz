class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    if (!regex.hasMatch(value.trim())) {
      return '3-20 characters, letters/numbers/underscore only';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final n = num.tryParse(value.trim());
    if (n == null || n < 0) return 'Enter a valid price';
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'This field'}) {
    if (value == null || value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }
}
