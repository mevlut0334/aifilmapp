// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Asilov';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get loginSubtitle => 'Hesabınıza giriş yapın';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get registerSubtitle => 'Yeni hesap oluşturun';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get email => 'E-posta';

  @override
  String get emailHint => 'ornek@email.com';

  @override
  String get emailRequired => 'E-posta zorunludur';

  @override
  String get emailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get password => 'Şifre';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Şifre zorunludur';

  @override
  String get passwordMinLength => 'En az 8 karakter olmalıdır';

  @override
  String get passwordConfirm => 'Şifre Tekrar';

  @override
  String get passwordConfirmRequired => 'Şifre tekrar zorunludur';

  @override
  String get passwordConfirmMismatch => 'Şifreler eşleşmiyor';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get forgotPasswordSubtitle =>
      'E-posta adresinize sıfırlama bağlantısı göndereceğiz';

  @override
  String get sendResetLink => 'Sıfırlama Bağlantısı Gönder';

  @override
  String get resetPassword => 'Şifremi Sıfırla';

  @override
  String get resetPasswordTitle => 'Şifre Sıfırla';

  @override
  String get resetPasswordButton => 'Şifremi Sıfırla';

  @override
  String get firstName => 'Ad';

  @override
  String get firstNameHint => 'Ahmet';

  @override
  String get firstNameRequired => 'Ad zorunludur';

  @override
  String get lastName => 'Soyad';

  @override
  String get lastNameHint => 'Yılmaz';

  @override
  String get lastNameRequired => 'Soyad zorunludur';

  @override
  String get phone => 'Telefon';

  @override
  String get phoneHint => '5551234567';

  @override
  String get phoneRequired => 'Telefon zorunludur';

  @override
  String get countryCode => 'Ülke Kodu';

  @override
  String get selectCountryCode => 'Ülke Kodu Seçin';

  @override
  String get noAccount => 'Hesabınız yok mu?';

  @override
  String get haveAccount => 'Zaten hesabınız var mı?';

  @override
  String get registerSuccess => 'Kayıt başarılı! Lütfen giriş yapın.';

  @override
  String get required => 'Zorunlu';

  @override
  String get consentText => 'Kayıt olarak';

  @override
  String get consentTerms => 'Kullanım Şartları';

  @override
  String get consentAnd => 've';

  @override
  String get consentPrivacy => 'Gizlilik Politikası';

  @override
  String get consentEnd => '\'nı kabul etmiş olursunuz.';

  @override
  String get welcomeTitle => 'Hoş Geldiniz';

  @override
  String get welcomeSubtitle => 'Yolculuğunuz burada başlıyor.';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get forgotPasswordSuccessTitle => 'E-postanızı Kontrol Edin';

  @override
  String get forgotPasswordSuccessMessage =>
      'E-postanızdaki bağlantıya tıklayarak şifrenizi sıfırlayın, ardından geri dönüp giriş yapın.';

  @override
  String get backToLogin => 'Girişe Dön';
}
