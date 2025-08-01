// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Boteco PRO';

  @override
  String get tagline => 'Bar and Restaurant Management';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Your email';

  @override
  String get emailEmpty => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get passwordEmpty => 'Please enter your password';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get orSeparator => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get signUpTitle => 'Create your Boteco PRO account';

  @override
  String get signUpSubtitle => 'Fill in the fields below to get started';

  @override
  String get nameLabel => 'Full name';

  @override
  String get nameHint => 'Your full name';

  @override
  String get nameEmpty => 'Please enter your name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get confirmPasswordEmpty => 'Please confirm your password';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get acceptTerms => 'I accept the ';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get signUpButton => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginLink => 'Sign in';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordMessage =>
      'Enter your email below to receive a password recovery link';

  @override
  String get sendResetLink => 'Send recovery link';

  @override
  String get rememberPassword => 'Remembered your password?';

  @override
  String get emailSentTitle => 'Email sent!';

  @override
  String emailSentMessage(Object email) {
    return 'We sent a password recovery link to $email';
  }

  @override
  String get checkSpam => 'Check your inbox and spam.';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get appearance => 'Appearance';

  @override
  String get sync => 'Synchronization';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get stockAlerts => 'Receive stock and order alerts';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get sounds => 'Sounds & Effects';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get themedSounds => 'Themed bar sounds';

  @override
  String get testSounds => 'Test sounds';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App version';

  @override
  String get aboutBoteco => 'About Boteco PRO';

  @override
  String get infoLicenses => 'Information and licenses';

  @override
  String get logoutSystem => 'Log out';

  @override
  String get logoutApp => 'Log out of the app';

  @override
  String get logoutQuestion =>
      'Are you sure you want to log out? You will need to sign in again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Log out';

  @override
  String get useSystemTheme => 'Use system theme';

  @override
  String get followDevice => 'Follow device settings';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get onlineMode => 'Online mode';

  @override
  String get connectedServer => 'Connected to server';

  @override
  String get offlineMode => 'Offline mode - using local data';

  @override
  String get lastSync => 'Last synchronization';

  @override
  String get neverSynced => 'Never synced';

  @override
  String get testSoundsTitle => 'Sound Test';

  @override
  String get clickButtons =>
      'Click the buttons below to test the sound effects:';

  @override
  String get tableOpened => 'Table Opened';

  @override
  String get tableClosed => 'Table Closed';

  @override
  String get orderAdded => 'Order Added';

  @override
  String get orderDelivered => 'Order Delivered';

  @override
  String get saleClosed => 'Sale Closed';

  @override
  String get productAdded => 'Product Added';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get notification => 'Notification';

  @override
  String get navigation => 'Navigation';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get appVersionNumber => '1.0.0';

  @override
  String get logoutSystemLabel => 'Sign Out';

  @override
  String get invalidEmailError => 'The email address is invalid.';

  @override
  String get userNotFoundError =>
      'User not found. Check your email and password.';

  @override
  String get wrongPasswordError => 'Incorrect password. Try again.';

  @override
  String get weakPasswordError => 'Password should be at least 6 characters.';

  @override
  String get emailInUseError =>
      'This email is already used by another account.';

  @override
  String get operationNotAllowedError =>
      'Operation not allowed. Contact support.';

  @override
  String get userDisabledError =>
      'This account has been disabled. Contact support.';

  @override
  String get tooManyRequestsError => 'Too many attempts. Try again later.';

  @override
  String get googleAuthFailedError =>
      'Google authentication failed. Try again.';

  @override
  String get signOutFailedError => 'Error signing out. Try again.';

  @override
  String get updateFailedError => 'Error updating profile. Try again.';

  @override
  String get unknownError =>
      'An error occurred while processing your request. Try again later.';

  @override
  String get genericError => 'An error occurred. Please try again later.';
}
