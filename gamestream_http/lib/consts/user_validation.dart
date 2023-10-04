
final usernameRules = <RegExp, String> {
  RegExp(r'^.{7,}$'): 'Must contain at least 7 characters',
  RegExp(r'^[a-zA-Z0-9_-]+$'): 'Must contain only letters, numbers, underscores, or hyphens.',
  RegExp(r'^[^-_].*[^-_]$'): 'Does not start or end with an underscore or hyphen.',
};