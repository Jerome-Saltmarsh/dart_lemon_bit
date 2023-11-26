
final _passwordPattern = RegExp(
  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$',
);

bool isValidPassword(String password) {
  return _passwordPattern.hasMatch(password);
}
