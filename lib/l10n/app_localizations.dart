import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Asilov'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza giriş yapın'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginButton;

  /// No description provided for @registerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni hesap oluşturun'**
  String get registerSubtitle;

  /// No description provided for @registerButton.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerButton;

  /// No description provided for @createAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta zorunludur'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In tr, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre zorunludur'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter olmalıdır'**
  String get passwordMinLength;

  /// No description provided for @passwordConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get passwordConfirm;

  /// No description provided for @passwordConfirmRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre tekrar zorunludur'**
  String get passwordConfirmRequired;

  /// No description provided for @passwordConfirmMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordConfirmMismatch;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinize sıfırlama bağlantısı göndereceğiz'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama Bağlantısı Gönder'**
  String get sendResetLink;

  /// No description provided for @resetPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Sıfırla'**
  String get resetPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Sıfırla'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordButton.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Sıfırla'**
  String get resetPasswordButton;

  /// No description provided for @firstName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ahmet'**
  String get firstNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad zorunludur'**
  String get firstNameRequired;

  /// No description provided for @lastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Yılmaz'**
  String get lastNameHint;

  /// No description provided for @lastNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Soyad zorunludur'**
  String get lastNameRequired;

  /// No description provided for @phone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In tr, this message translates to:
  /// **'5551234567'**
  String get phoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In tr, this message translates to:
  /// **'Telefon zorunludur'**
  String get phoneRequired;

  /// No description provided for @countryCode.
  ///
  /// In tr, this message translates to:
  /// **'Ülke Kodu'**
  String get countryCode;

  /// No description provided for @selectCountryCode.
  ///
  /// In tr, this message translates to:
  /// **'Ülke Kodu Seçin'**
  String get selectCountryCode;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get haveAccount;

  /// No description provided for @registerSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Lütfen giriş yapın.'**
  String get registerSuccess;

  /// No description provided for @required.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu'**
  String get required;

  /// No description provided for @consentText.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olarak'**
  String get consentText;

  /// No description provided for @consentTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get consentTerms;

  /// No description provided for @consentAnd.
  ///
  /// In tr, this message translates to:
  /// **'ve'**
  String get consentAnd;

  /// No description provided for @consentPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get consentPrivacy;

  /// No description provided for @consentEnd.
  ///
  /// In tr, this message translates to:
  /// **'\'nı kabul etmiş olursunuz.'**
  String get consentEnd;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğunuz burada başlıyor.'**
  String get welcomeSubtitle;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanızı Kontrol Edin'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessMessage.
  ///
  /// In tr, this message translates to:
  /// **'E-postanızdaki bağlantıya tıklayarak şifrenizi sıfırlayın, ardından geri dönüp giriş yapın.'**
  String get forgotPasswordSuccessMessage;

  /// No description provided for @backToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Girişe Dön'**
  String get backToLogin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
