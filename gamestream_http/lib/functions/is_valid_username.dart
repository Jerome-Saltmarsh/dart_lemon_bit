final _usernamePattern = RegExp(r'^[a-zA-Z0-9_-]{7,}$');

// Define your own rules for a valid username here.
// For example, you might require that the username:
// - Contains at least 7 characters.
// - Contains only letters, numbers, underscores, or hyphens.
// - Does not start or end with an underscore or hyphen.
bool isValidUsername(String username) => _usernamePattern.hasMatch(username);