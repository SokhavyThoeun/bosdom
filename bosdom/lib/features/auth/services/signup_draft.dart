/// Holds the personal-details form's in-progress values across screen
/// recreation during signup. Choose Role always pushes a *new*
/// PersonalDetailsScreen (see SignupScreen._continue), so backing out to
/// Choose Role and continuing again disposes the old instance and its
/// TextEditingControllers — without this, everything the user typed would
/// be lost even though they never left the signup flow.
abstract final class SignupDraft {
  static String fullName = '';
  static String phone = '';
  static String email = '';
  static String password = '';
  static String confirmPassword = '';

  static void clear() {
    fullName = '';
    phone = '';
    email = '';
    password = '';
    confirmPassword = '';
  }
}
