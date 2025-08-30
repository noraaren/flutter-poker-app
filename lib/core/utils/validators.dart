// Use for validators that are used across the app, such as email, password, etc.

/// Validates Venmo username format
/// 
/// [username] - The Venmo username to validate
/// Returns true if the username is valid, false otherwise
/// 
/// Example usage:
/// ```dart
/// if (isValidVenmoUsername(username)) {
///   // Proceed with Venmo transaction
/// } else {
///   // Show error message
/// }
/// ```
bool isValidVenmoUsername(String username) {
  // Venmo usernames are 3-16 characters, alphanumeric and underscores only
  final regex = RegExp(r'^[a-zA-Z0-9_]{3,16}$');
  return regex.hasMatch(username);
}