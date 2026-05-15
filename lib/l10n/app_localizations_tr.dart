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

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navTemplates => 'Şablonlarım';

  @override
  String get navImages => 'Görsellerim';

  @override
  String get navVideos => 'Videolarım';

  @override
  String get packages => 'Paketler';

  @override
  String get aboutUs => 'Hakkımızda';

  @override
  String get drawerProfile => 'Profil';

  @override
  String get tokens => 'token';

  @override
  String get buyTokens => 'Token Satın Al';

  @override
  String get useTemplate => 'Şablonu Kullan';

  @override
  String get loginToUse => 'Kullanmak için Giriş Yap';

  @override
  String get swipeHint => 'Yukarı kaydır';

  @override
  String get swipeBack => 'Geri';

  @override
  String get createImage => 'Görsel Oluştur';

  @override
  String get createVideo => 'Video Oluştur';

  @override
  String get featuredTemplates => 'Öne Çıkan Şablonlar';

  @override
  String get noTemplates => 'Şablon bulunamadı';

  @override
  String get noImages => 'Henüz görsel yok';

  @override
  String get noVideos => 'Henüz video yok';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get myRequests => 'Taleplerim';

  @override
  String get requestPending => 'Bekliyor';

  @override
  String get requestProcessing => 'İşleniyor';

  @override
  String get requestCompleted => 'Tamamlandı';

  @override
  String get requestFailed => 'Başarısız';

  @override
  String get download => 'İndir';

  @override
  String get noRequests => 'Henüz talep yok';

  @override
  String get requestDate => 'Tarih';

  @override
  String get requestProgress => 'İlerleme';

  @override
  String get requestType => 'Tip';

  @override
  String get downloadError => 'İndirme başarısız';

  @override
  String get createRequest => 'Talep Oluştur';

  @override
  String get selectPhoto => 'Fotoğraf Seç';

  @override
  String get changePhoto => 'Fotoğrafı Değiştir';

  @override
  String get photoRequired => 'Fotoğraf zorunludur';

  @override
  String get requestQueued => 'Talep başarıyla kuyruğa alındı';

  @override
  String get outputType => 'Çıktı Tipi';

  @override
  String get outputImage => 'Görsel';

  @override
  String get outputVideo => 'Video';

  @override
  String get orientationOptional => 'Yön (İsteğe Bağlı)';

  @override
  String get orientationAny => 'Herhangi';

  @override
  String get portrait => 'Dikey';

  @override
  String get landscape => 'Yatay';

  @override
  String get square => 'Kare';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get descriptionHint =>
      'Oluşturmak istediğiniz görseli detaylı olarak açıklayın...';

  @override
  String get descriptionRequired => 'Açıklama zorunludur';

  @override
  String get orientationLabel => 'Yön';

  @override
  String get referencePhotoOptional => 'Referans Fotoğraf (İsteğe Bağlı)';

  @override
  String get videoRequests => 'Videolarım';

  @override
  String get noVideoRequests => 'Henüz video talebi yok';

  @override
  String get createVideoRequest => 'Video Talebi Oluştur';

  @override
  String get promptLabel => 'Açıklama';

  @override
  String get promptHint =>
      'Oluşturmak istediğiniz videoyu detaylı olarak açıklayın...';

  @override
  String get promptRequired => 'Açıklama zorunludur';

  @override
  String get formatLabel => 'Format';

  @override
  String get formatVertical => 'Dikey (9:16)';

  @override
  String get formatHorizontal => 'Yatay (16:9)';

  @override
  String get formatSquare => 'Kare (1:1)';

  @override
  String get inputImageOptional => 'Başlangıç Görseli (İsteğe Bağlı)';

  @override
  String get videoRequestDetail => 'Talep Detayı';

  @override
  String get segmentsTitle => 'Segmentler';

  @override
  String get segmentNumber => 'Segment';

  @override
  String get overallProgress => 'Genel İlerleme';

  @override
  String get tokenCost => 'Token Maliyeti';

  @override
  String get failureReason => 'Başarısızlık Nedeni';

  @override
  String get noSegmentsYet => 'Segmentler henüz oluşturulmadı';

  @override
  String get requestEditButton => 'Düzenleme İste';

  @override
  String get editPending => 'Düzenleme Bekliyor';

  @override
  String get editPromptLabel => 'Düzenleme Talimatı';

  @override
  String get editPromptHint => 'Ne değiştirilmesini istediğinizi açıklayın...';

  @override
  String get editPromptRequired => 'Düzenleme talimatı zorunludur';

  @override
  String get submitEdit => 'Gönder';

  @override
  String get editSubmitted => 'Düzenleme talebi gönderildi';

  @override
  String get downloadVideo => 'Videoyu İndir';

  @override
  String get videoRequestCreated => 'Video talebi başarıyla oluşturuldu';

  @override
  String get tokenCostInfo =>
      'Maliyet admin tarafından video işlendikten sonra belirlenecek ve token\'ınızdan düşülecektir.';

  @override
  String get contact => 'İletişim';

  @override
  String get urlPrivacyPolicy => 'https://asilov.com/tr/privacy-policy';

  @override
  String get urlTermsOfService => 'https://asilov.com/tr/terms-of-service';

  @override
  String get urlAbout => 'https://asilov.com/tr/about';

  @override
  String get urlContact => 'https://asilov.com/tr/contact';

  @override
  String get premiumTitle => 'Premium\'a Geç';

  @override
  String get premiumSubtitle => 'Token satın al, hızlı içerik üret.';

  @override
  String get loginToSubscribe => 'Satın almak için giriş yapman gerekiyor.';

  @override
  String get activeSubscription => 'Aktif Abonelik';

  @override
  String subscriptionExpiry(String date) {
    return 'Bitiş: $date';
  }

  @override
  String get autoRenewing => 'Otomatik yenileme';

  @override
  String get currentPlan => 'Mevcut Plan';

  @override
  String get subscribe => 'Abone Ol';

  @override
  String get loginAndSubscribe => 'Giriş Yap & Abone Ol';

  @override
  String get activePlan => 'Aktif Plan';

  @override
  String get noPackagesAvailable => 'Şu an aktif paket bulunmuyor.';

  @override
  String get subscriptionRenewalNote =>
      'Abonelik her dönem otomatik olarak yenilenir.\nİptal için cihazınızın mağaza ayarlarını kullanın.';

  @override
  String get applePaymentTerms => 'Apple Ödeme Koşulları geçerlidir.';

  @override
  String get googlePaymentTerms => 'Google Play Ödeme Koşulları geçerlidir.';

  @override
  String purchaseSuccessTokens(int count) {
    return '$count token hesabınıza eklendi!';
  }

  @override
  String get subscriptionSuccess => 'Abonelik başarıyla tamamlandı!';

  @override
  String get purchaseFailed => 'Satın alma başarısız.';

  @override
  String get storeUnavailable =>
      'Uygulama içi satın alma şu an kullanılamıyor.';

  @override
  String get insufficientBalance =>
      'Yetersiz token bakiyesi. Lütfen token satın alın.';

  @override
  String insufficientBalanceTemplate(int required, int available) {
    return 'Yetersiz bakiye. Bu şablon $required token gerektiriyor, bakiyeniz: $available.';
  }
}
