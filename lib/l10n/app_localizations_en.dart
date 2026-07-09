// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Asilov';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginButton => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSubtitle => 'Create a new account';

  @override
  String get registerButton => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmMessage =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteAccountCancel => 'Cancel';

  @override
  String get deleteAccountFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Must be at least 8 characters';

  @override
  String get passwordConfirm => 'Confirm Password';

  @override
  String get passwordConfirmRequired => 'Password confirmation is required';

  @override
  String get passwordConfirmMismatch => 'Passwords do not match';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'We will send a reset link to your email address';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameHint => 'John';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameHint => 'Doe';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get phone => 'Phone';

  @override
  String get phoneHint => '5551234567';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get countryCode => 'Country Code';

  @override
  String get selectCountryCode => 'Select Country Code';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get registerSuccess => 'Registration successful! Please login.';

  @override
  String get required => 'Required';

  @override
  String get consentText => 'By registering you agree to our';

  @override
  String get consentTerms => 'Terms of Service';

  @override
  String get consentAnd => 'and';

  @override
  String get consentPrivacy => 'Privacy Policy';

  @override
  String get consentEnd => '.';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Your journey begins here.';

  @override
  String get logout => 'Logout';

  @override
  String get forgotPasswordSuccessTitle => 'Check Your Email';

  @override
  String get forgotPasswordSuccessMessage =>
      'Click the link in your email to reset your password, then come back and login.';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get navHome => 'Home';

  @override
  String get navTemplates => 'My Templates';

  @override
  String get navImages => 'My Images';

  @override
  String get navVideos => 'My Videos';

  @override
  String get packages => 'Packages';

  @override
  String get aboutUs => 'About Us';

  @override
  String get drawerProfile => 'Profile';

  @override
  String get tokens => 'tokens';

  @override
  String get buyTokens => 'Buy Tokens';

  @override
  String get useTemplate => 'Use Template';

  @override
  String get loginToUse => 'Login to Use';

  @override
  String get swipeHint => 'Swipe up';

  @override
  String get swipeBack => 'Back';

  @override
  String get createImage => 'Create Image';

  @override
  String get createVideo => 'Create Video';

  @override
  String get featuredTemplates => 'Featured Templates';

  @override
  String get noTemplates => 'No templates found';

  @override
  String get noImages => 'No images yet';

  @override
  String get noVideos => 'No videos yet';

  @override
  String get retry => 'Retry';

  @override
  String get myRequests => 'My Requests';

  @override
  String get requestPending => 'Pending';

  @override
  String get requestProcessing => 'Processing';

  @override
  String get requestCompleted => 'Completed';

  @override
  String get requestFailed => 'Failed';

  @override
  String get download => 'Download';

  @override
  String get noRequests => 'No requests yet';

  @override
  String get requestDate => 'Date';

  @override
  String get requestProgress => 'Progress';

  @override
  String get requestType => 'Type';

  @override
  String get downloadError => 'Download failed';

  @override
  String get createRequest => 'Create Request';

  @override
  String get selectPhoto => 'Select Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get photoRequired => 'Photo is required';

  @override
  String get requestQueued => 'Request queued successfully';

  @override
  String get outputType => 'Output Type';

  @override
  String get outputImage => 'Image';

  @override
  String get outputVideo => 'Video';

  @override
  String get orientationOptional => 'Orientation (Optional)';

  @override
  String get orientationAny => 'Any';

  @override
  String get portrait => 'Portrait';

  @override
  String get landscape => 'Landscape';

  @override
  String get square => 'Square';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint =>
      'Describe the image you want to create in detail...';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get orientationLabel => 'Orientation';

  @override
  String get referencePhotoOptional => 'Reference Photo (Optional)';

  @override
  String get videoRequests => 'My Videos';

  @override
  String get noVideoRequests => 'No video requests yet';

  @override
  String get createVideoRequest => 'Create Video Request';

  @override
  String get promptLabel => 'Prompt';

  @override
  String get promptHint => 'Describe the video you want to create in detail...';

  @override
  String get promptRequired => 'Prompt is required';

  @override
  String get formatLabel => 'Format';

  @override
  String get formatVertical => 'Vertical (9:16)';

  @override
  String get formatHorizontal => 'Horizontal (16:9)';

  @override
  String get formatSquare => 'Square (1:1)';

  @override
  String get inputImageOptional => 'Input Image (Optional)';

  @override
  String get videoRequestDetail => 'Request Detail';

  @override
  String get segmentsTitle => 'Segments';

  @override
  String get segmentNumber => 'Segment';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get tokenCost => 'Token Cost';

  @override
  String get failureReason => 'Failure Reason';

  @override
  String get noSegmentsYet => 'Segments not created yet';

  @override
  String get requestEditButton => 'Request Edit';

  @override
  String get editPending => 'Edit Pending';

  @override
  String get editPromptLabel => 'Edit Instructions';

  @override
  String get editPromptHint => 'Describe what you want changed...';

  @override
  String get editPromptRequired => 'Edit instructions are required';

  @override
  String get submitEdit => 'Submit';

  @override
  String get editSubmitted => 'Edit request submitted';

  @override
  String get downloadVideo => 'Download Video';

  @override
  String get videoRequestCreated => 'Video request created successfully';

  @override
  String get tokenCostInfo =>
      'Cost will be determined by admin after video is processed and deducted from your tokens.';

  @override
  String get contact => 'Contact';

  @override
  String get urlPrivacyPolicy => 'https://asilov.com/en/privacy-policy';

  @override
  String get urlTermsOfService => 'https://asilov.com/en/terms-of-service';

  @override
  String get urlAbout => 'https://asilov.com/en/about';

  @override
  String get urlContact => 'https://asilov.com/en/contact';

  @override
  String get premiumTitle => 'Go Premium';

  @override
  String get premiumSubtitle => 'Buy tokens, create fast content.';

  @override
  String get loginToSubscribe => 'You need to login to make a purchase.';

  @override
  String get activeSubscription => 'Active Subscription';

  @override
  String subscriptionExpiry(String date) {
    return 'Expires: $date';
  }

  @override
  String get autoRenewing => 'Auto-renewing';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get loginAndSubscribe => 'Login & Subscribe';

  @override
  String get activePlan => 'Active Plan';

  @override
  String get noPackagesAvailable => 'No active packages available.';

  @override
  String get subscriptionRenewalNote =>
      'Subscription renews automatically each period.\nTo cancel, use your device\'s store settings.';

  @override
  String get applePaymentTerms => 'Apple Payment Terms apply.';

  @override
  String get googlePaymentTerms => 'Google Play Payment Terms apply.';

  @override
  String purchaseSuccessTokens(int count) {
    return '$count tokens added to your account!';
  }

  @override
  String get subscriptionSuccess => 'Subscription completed successfully!';

  @override
  String get purchaseFailed => 'Purchase failed.';

  @override
  String get storeUnavailable => 'In-app purchase is currently unavailable.';

  @override
  String get insufficientBalance =>
      'Insufficient token balance. Please purchase tokens.';

  @override
  String insufficientBalanceTemplate(int required, int available) {
    return 'Insufficient balance. This template requires $required tokens, you have $available.';
  }
}
