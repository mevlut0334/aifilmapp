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

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navTemplates.
  ///
  /// In tr, this message translates to:
  /// **'Şablonlarım'**
  String get navTemplates;

  /// No description provided for @navImages.
  ///
  /// In tr, this message translates to:
  /// **'Görsellerim'**
  String get navImages;

  /// No description provided for @navVideos.
  ///
  /// In tr, this message translates to:
  /// **'Videolarım'**
  String get navVideos;

  /// No description provided for @packages.
  ///
  /// In tr, this message translates to:
  /// **'Paketler'**
  String get packages;

  /// No description provided for @aboutUs.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımızda'**
  String get aboutUs;

  /// No description provided for @drawerProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get drawerProfile;

  /// No description provided for @tokens.
  ///
  /// In tr, this message translates to:
  /// **'token'**
  String get tokens;

  /// No description provided for @buyTokens.
  ///
  /// In tr, this message translates to:
  /// **'Token Satın Al'**
  String get buyTokens;

  /// No description provided for @useTemplate.
  ///
  /// In tr, this message translates to:
  /// **'Şablonu Kullan'**
  String get useTemplate;

  /// No description provided for @loginToUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullanmak için Giriş Yap'**
  String get loginToUse;

  /// No description provided for @swipeHint.
  ///
  /// In tr, this message translates to:
  /// **'Yukarı kaydır'**
  String get swipeHint;

  /// No description provided for @swipeBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get swipeBack;

  /// No description provided for @createImage.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Oluştur'**
  String get createImage;

  /// No description provided for @createVideo.
  ///
  /// In tr, this message translates to:
  /// **'Video Oluştur'**
  String get createVideo;

  /// No description provided for @featuredTemplates.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkan Şablonlar'**
  String get featuredTemplates;

  /// No description provided for @noTemplates.
  ///
  /// In tr, this message translates to:
  /// **'Şablon bulunamadı'**
  String get noTemplates;

  /// No description provided for @noImages.
  ///
  /// In tr, this message translates to:
  /// **'Henüz görsel yok'**
  String get noImages;

  /// No description provided for @noVideos.
  ///
  /// In tr, this message translates to:
  /// **'Henüz video yok'**
  String get noVideos;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @myRequests.
  ///
  /// In tr, this message translates to:
  /// **'Taleplerim'**
  String get myRequests;

  /// No description provided for @requestPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get requestPending;

  /// No description provided for @requestProcessing.
  ///
  /// In tr, this message translates to:
  /// **'İşleniyor'**
  String get requestProcessing;

  /// No description provided for @requestCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get requestCompleted;

  /// No description provided for @requestFailed.
  ///
  /// In tr, this message translates to:
  /// **'Başarısız'**
  String get requestFailed;

  /// No description provided for @download.
  ///
  /// In tr, this message translates to:
  /// **'İndir'**
  String get download;

  /// No description provided for @noRequests.
  ///
  /// In tr, this message translates to:
  /// **'Henüz talep yok'**
  String get noRequests;

  /// No description provided for @requestDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get requestDate;

  /// No description provided for @requestProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get requestProgress;

  /// No description provided for @requestType.
  ///
  /// In tr, this message translates to:
  /// **'Tip'**
  String get requestType;

  /// No description provided for @downloadError.
  ///
  /// In tr, this message translates to:
  /// **'İndirme başarısız'**
  String get downloadError;

  /// No description provided for @createRequest.
  ///
  /// In tr, this message translates to:
  /// **'Talep Oluştur'**
  String get createRequest;

  /// No description provided for @selectPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Seç'**
  String get selectPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı Değiştir'**
  String get changePhoto;

  /// No description provided for @photoRequired.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf zorunludur'**
  String get photoRequired;

  /// No description provided for @requestQueued.
  ///
  /// In tr, this message translates to:
  /// **'Talep başarıyla kuyruğa alındı'**
  String get requestQueued;

  /// No description provided for @outputType.
  ///
  /// In tr, this message translates to:
  /// **'Çıktı Tipi'**
  String get outputType;

  /// No description provided for @outputImage.
  ///
  /// In tr, this message translates to:
  /// **'Görsel'**
  String get outputImage;

  /// No description provided for @outputVideo.
  ///
  /// In tr, this message translates to:
  /// **'Video'**
  String get outputVideo;

  /// No description provided for @orientationOptional.
  ///
  /// In tr, this message translates to:
  /// **'Yön (İsteğe Bağlı)'**
  String get orientationOptional;

  /// No description provided for @orientationAny.
  ///
  /// In tr, this message translates to:
  /// **'Herhangi'**
  String get orientationAny;

  /// No description provided for @portrait.
  ///
  /// In tr, this message translates to:
  /// **'Dikey'**
  String get portrait;

  /// No description provided for @landscape.
  ///
  /// In tr, this message translates to:
  /// **'Yatay'**
  String get landscape;

  /// No description provided for @square.
  ///
  /// In tr, this message translates to:
  /// **'Kare'**
  String get square;
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
