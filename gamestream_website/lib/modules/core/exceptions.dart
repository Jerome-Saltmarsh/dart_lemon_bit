class LoginException implements Exception {
  final Exception cause;
  LoginException(this.cause);
}