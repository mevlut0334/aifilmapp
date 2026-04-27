# 🎬 Film Yapma Uygulaması — Flutter Proje Rehberi

> Bu doküman yapay zeka destekli geliştirme için hazırlanmıştır.
> Her faz bağımsızdır. Bir fazı tamamlamadan diğerine geçme.

---

## 📋 İçindekiler

1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Teknoloji Yığını](#teknoloji-yığını)
3. [Mimari](#mimari)
4. [Klasör Yapısı](#klasör-yapısı)
5. [Katman Kuralları](#katman-kuralları)
6. [API Bilgileri](#api-bilgileri)
7. [Faz Planı](#faz-planı)
8. [Yapay Zekaya Kod Yazdırma Kuralları](#yapay-zekaya-kod-yazdırma-kuralları)

---

## Proje Genel Bakış

Kullanıcıların template veya custom prompt kullanarak yapay zeka destekli görsel ve video üretimi yapabildiği bir mobil uygulama. Backend API hazır, sadece Flutter uygulaması yazılacak.

**Temel Özellikler:**
- Kullanıcı kaydı ve girişi
- Template listesi ve önizleme
- Template tabanlı görsel/video üretimi
- Custom prompt ile görsel üretimi
- Custom video üretimi ve segment takibi
- Segment bazlı düzenleme talepleri
- Üretim durumu takibi (polling)

---

## Teknoloji Yığını

| Paket | Versiyon | Amaç |
|---|---|---|
| `flutter_riverpod` | ^2.5.0 | State management |
| `riverpod_annotation` | ^2.3.0 | Code generation |
| `dio` | ^5.4.0 | HTTP client |
| `go_router` | ^13.0.0 | Navigation |
| `flutter_secure_storage` | ^9.0.0 | Token saklama |
| `freezed` | ^2.4.0 | Immutable modeller |
| `freezed_annotation` | ^2.4.0 | Code generation |
| `json_serializable` | ^6.7.0 | JSON parse |
| `build_runner` | ^2.4.0 | Code generation çalıştırma |
| `envied` | ^0.5.0 | Env variable yönetimi |
| `cached_network_image` | ^3.3.0 | Resim önbellekleme |
| `video_player` | ^2.8.0 | Video önizleme |
| `image_picker` | ^1.0.0 | Fotoğraf seçme |

---

## Mimari

**Clean Architecture** kullanılır. Her feature 3 katmana ayrılır:

```
feature/
├── data/          → API ile konuşur, JSON parse eder
├── domain/        → İş kuralları, soyut tanımlar
└── presentation/  → UI ve state
```

**Veri akışı (tek yön):**

```
UI (Screen)
  └── izler → Provider (Riverpod)
                └── çağırır → UseCase (Domain)
                               └── çağırır → Repository (Domain - Abstract)
                                              └── implements → RepositoryImpl (Data)
                                                               └── çağırır → RemoteDatasource
                                                                              └── HTTP → API
```

**Altın kural:** Hiçbir katman kendinden üst katmanı import etmez.

---

## Klasör Yapısı

```
lib/
│
├── core/                          # Tüm feature'ların ortak kullandığı kodlar
│   ├── constants/
│   │   ├── api_constants.dart     # Base URL, tüm endpoint path'leri
│   │   └── app_constants.dart     # Genel sabitler
│   │
│   ├── network/
│   │   ├── api_client.dart        # Dio instance (Provider olarak)
│   │   ├── api_response.dart      # Generic ApiResponse<T> modeli
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart      # Bearer token inject eder
│   │       └── app_key_interceptor.dart   # X-App-Key ve X-Secret-Key inject eder
│   │
│   ├── error/
│   │   ├── failures.dart          # ServerFailure, NetworkFailure, etc.
│   │   └── exceptions.dart        # ServerException, NetworkException
│   │
│   ├── utils/
│   │   ├── result.dart            # Result<T> = Success<T> | Failure
│   │   └── extensions.dart        # Yardımcı extension'lar
│   │
│   └── storage/
│       └── secure_storage.dart    # Token okuma/yazma
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── login_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart       # abstract class
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── register_screen.dart
│   │       └── widgets/
│   │           └── auth_form_field.dart
│   │
│   ├── templates/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── template_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── template_model.dart
│   │   │   └── repositories/
│   │   │       └── template_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── template_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── template_repository.dart   # abstract class
│   │   │   └── usecases/
│   │   │       ├── get_templates_usecase.dart
│   │   │       └── get_template_detail_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── template_provider.dart
│   │       ├── screens/
│   │       │   ├── template_list_screen.dart
│   │       │   └── template_detail_screen.dart
│   │       └── widgets/
│   │           └── template_card.dart
│   │
│   ├── generation/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── generation_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── generation_request_model.dart
│   │   │   └── repositories/
│   │   │       └── generation_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── generation_request_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── generation_repository.dart  # abstract class
│   │   │   └── usecases/
│   │   │       ├── create_template_generation_usecase.dart
│   │   │       ├── create_custom_image_usecase.dart
│   │   │       ├── get_generation_requests_usecase.dart
│   │   │       ├── get_generation_detail_usecase.dart
│   │   │       └── cancel_generation_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── generation_provider.dart
│   │       ├── screens/
│   │       │   ├── generation_list_screen.dart
│   │       │   ├── generation_detail_screen.dart
│   │       │   ├── create_template_generation_screen.dart
│   │       │   └── create_custom_image_screen.dart
│   │       └── widgets/
│   │           └── generation_status_badge.dart
│   │
│   └── custom_video/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── custom_video_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── custom_video_request_model.dart
│       │   │   └── segment_model.dart
│       │   └── repositories/
│       │       └── custom_video_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── custom_video_request_entity.dart
│       │   │   └── segment_entity.dart
│       │   ├── repositories/
│       │   │   └── custom_video_repository.dart  # abstract class
│       │   └── usecases/
│       │       ├── create_custom_video_usecase.dart
│       │       ├── get_custom_video_requests_usecase.dart
│       │       ├── get_custom_video_detail_usecase.dart
│       │       ├── edit_segment_usecase.dart
│       │       └── delete_custom_video_usecase.dart
│       └── presentation/
│           ├── providers/
│           │   └── custom_video_provider.dart
│           ├── screens/
│           │   ├── custom_video_list_screen.dart
│           │   ├── custom_video_detail_screen.dart
│           │   └── create_custom_video_screen.dart
│           └── widgets/
│               ├── segment_card.dart
│               └── segment_edit_dialog.dart
│
└── main.dart
```

---

## Katman Kuralları

Bu kurallar değiştirilemez. Yapay zekanın her dosyada uyması gerekir.

### datasource
- **Sadece** HTTP çağrısı yapar
- Dio kullanır, başka hiçbir package import etmez
- Ham JSON alır, `model` nesnesine parse eder
- Hata olursa `Exception` fırlatır (`ServerException`)
- `Repository` veya `UseCase` import edemez

### model
- `entity`'yi extend eder veya `toEntity()` metodu içerir
- `fromJson` ve `toJson` içerir
- `freezed` ile immutable olur
- Sadece JSON ↔ Dart dönüşümü yapar

### repository (abstract — domain)
- Sadece method signature'ları içerir
- `Future<Result<T>>` döner, asla raw exception fırlatmaz
- Hiçbir Dio veya HTTP detayı içermez

### repository impl (data)
- Abstract repository'yi implements eder
- `datasource`'u çağırır, try/catch ile sarar
- `Exception`'ları `Failure`'a dönüştürür
- `Result.success()` veya `Result.failure()` döner

### usecase
- **Tek** bir iş yapar, tek bir public metodu vardır: `call()`
- Repository'yi çağırır, başka hiçbir şey yapmaz
- İş mantığı burada toplanır (validation, transformation)

### provider (Riverpod)
- `AsyncNotifier` veya `Notifier` kullanır
- UseCase'i çağırır, UI state'ini tutar
- `Result` gelince `AsyncData`, `AsyncError` veya `AsyncLoading` döner
- İçinde Dio, HTTP, JSON kodu olmaz

### screen
- Sadece UI kodu içerir
- Provider'ı `ref.watch()` ile izler
- İş mantığı içermez
- Widget'ları `widgets/` klasöründen import eder

---

## API Bilgileri

### Base URL
```
https://[DOMAIN]/api/v1/
```

### Zorunlu Header'lar (Her İstek)
```
X-App-Key: {app_key}           → .env dosyasından okunur
X-Secret-Key: {secret_key}     → .env dosyasından okunur
Accept-Language: tr            → varsayılan, değiştirilebilir
```

### Korumalı Endpoint'ler (Ek Header)
```
Authorization: Bearer {token}  → login sonrası SecureStorage'dan okunur
```

### Standart Response Formatı
```json
{
  "success": true,
  "message": "İşlem başarılı",
  "data": {},
  "locale": "tr"
}
```

### Hata Response Formatı
```json
{
  "success": false,
  "message": "Hata mesajı",
  "data": null,
  "locale": "tr"
}
```

### HTTP Status Kodları
| Kod | Anlam |
|---|---|
| 200 | Başarılı |
| 201 | Oluşturuldu |
| 401 | Yetkisiz (token veya app key hatalı) |
| 404 | Bulunamadı |
| 422 | Validasyon hatası |
| 500 | Sunucu hatası |

### Endpoint Özeti

| Method | Path | Auth | Açıklama |
|---|---|---|---|
| POST | `/register` | App Key | Kayıt |
| POST | `/login` | App Key | Giriş, token döner |
| POST | `/logout` | Bearer | Çıkış |
| GET | `/profile` | Bearer | Profil bilgisi |
| GET | `/templates` | Bearer | Template listesi |
| GET | `/templates?orientation=landscape` | Bearer | Filtreli template listesi |
| GET | `/templates/{uuid}` | Bearer | Template detayı |
| POST | `/generation-requests` | Bearer | Görsel/video talebi oluştur |
| GET | `/generation-requests` | Bearer | Talep listesi |
| GET | `/generation-requests/{uuid}` | Bearer | Talep detayı |
| DELETE | `/generation-requests/{uuid}` | Bearer | Talebi iptal et |
| POST | `/custom-video-requests` | Bearer | Custom video talebi |
| GET | `/custom-video-requests` | Bearer | Custom video listesi |
| GET | `/custom-video-requests/{uuid}` | Bearer | Detay + segmentler |
| POST | `/custom-video-requests/{uuid}/segments/{id}/edit` | Bearer | Segment düzenleme talebi |
| DELETE | `/custom-video-requests/{uuid}` | Bearer | Video talebini sil |

### generation-requests type Değerleri
| type | Açıklama | input_image |
|---|---|---|
| `template_image` | Template ile görsel | Zorunlu |
| `template_video` | Template ile video | Zorunlu |
| `custom_image` | Custom prompt ile görsel | Opsiyonel |

### custom-video-requests format Değerleri
| format | Oran |
|---|---|
| `vertical` | 9:16 (varsayılan) |
| `horizontal` | 16:9 |
| `square` | 1:1 |

### Segment Status Değerleri
| status | Anlam |
|---|---|
| `pending` | Bekliyor |
| `processing` | İşleniyor |
| `completed` | Tamamlandı |
| `failed` | Başarısız |

---

## Faz Planı

> Her faz bağımsız çalışır. Bir faz bitmeden diğerine geçilmez.
> Her fazın sonunda `flutter run` ile uygulama ayağa kalkmalıdır.

---

### Faz 0 — Proje İskeleti
**Süre: ~30 dakika**

Bu fazda sadece proje yapısı kurulur, hiç iş mantığı yazılmaz.

**Yapılacaklar:**
1. `flutter create` ile proje oluştur
2. `pubspec.yaml`'a tüm paketleri ekle
3. Klasör yapısını oluştur (boş dosyalar)
4. `core/utils/result.dart` — `Result<T>` tipi
5. `core/error/failures.dart` — Failure tipleri
6. `core/error/exceptions.dart` — Exception tipleri
7. `core/constants/api_constants.dart` — Tüm endpoint path'leri
8. `.env` dosyası ve `envied` setup
9. `main.dart` — sadece `ProviderScope` ile `MaterialApp`

**Tamamlandı kriteri:** `flutter run` çalışır, boş ekran açılır.

---

### Faz 1 — Core Network Katmanı
**Süre: ~45 dakika**

API ile konuşacak olan temel altyapı. Hiçbir feature henüz yok.

**Yapılacaklar:**
1. `core/network/api_response.dart` — Generic `ApiResponse<T>`
2. `core/network/interceptors/app_key_interceptor.dart`
3. `core/network/interceptors/auth_interceptor.dart`
4. `core/network/api_client.dart` — Dio Provider
5. `core/storage/secure_storage.dart` — Token saklama
6. Postman veya DIO logger ile endpoint test

**Tamamlandı kriteri:** Login endpoint'e manuel istek atılabilir, response parse edilir.

---

### Faz 2 — Auth Feature
**Süre: ~60 dakika**

Login, register, logout ve profil. Routing henüz basit.

**Yapılacaklar:**

*Domain katmanı:*
1. `user_entity.dart`
2. `auth_repository.dart` (abstract)
3. `login_usecase.dart`, `register_usecase.dart`, `logout_usecase.dart`

*Data katmanı:*
4. `login_response_model.dart`, `user_model.dart`
5. `auth_remote_datasource.dart`
6. `auth_repository_impl.dart`

*Presentation katmanı:*
7. `auth_provider.dart` — `AsyncNotifier`
8. `login_screen.dart`
9. `register_screen.dart`

*Routing:*
10. `go_router` setup — `/login`, `/register`, `/home` route'ları
11. Token varsa `/home`'a yönlendir, yoksa `/login`'e

**Tamamlandı kriteri:** Gerçek kullanıcı ile giriş yapılabilir, token kaydedilir, home sayfasına geçilir.

---

### Faz 3 — Template Feature
**Süre: ~45 dakika**

Template listesi ve detay sayfası. Henüz talep oluşturma yok.

**Yapılacaklar:**

*Domain katmanı:*
1. `template_entity.dart` — `title` ve `description` `Map<String, String>` olmalı (çok dil)
2. `template_repository.dart` (abstract)
3. `get_templates_usecase.dart`, `get_template_detail_usecase.dart`

*Data katmanı:*
4. `template_model.dart`
5. `template_remote_datasource.dart`
6. `template_repository_impl.dart`

*Presentation katmanı:*
7. `template_provider.dart`
8. `template_list_screen.dart` — orientation filter ile
9. `template_detail_screen.dart` — video önizleme
10. `template_card.dart` widget

**Tamamlandı kriteri:** Template'ler listelenir, detay sayfası açılır, video oynatılır.

---

### Faz 4 — Generation Feature (Template + Custom Image)
**Süre: ~60 dakika**

Template kullanarak ve custom prompt ile görsel/video üretim talepleri.

**Yapılacaklar:**

*Domain katmanı:*
1. `generation_request_entity.dart` — tüm alanlar dahil (`template` nested entity)
2. `generation_repository.dart` (abstract)
3. `create_template_generation_usecase.dart`
4. `create_custom_image_usecase.dart`
5. `get_generation_requests_usecase.dart`
6. `get_generation_detail_usecase.dart`
7. `cancel_generation_usecase.dart`

*Data katmanı:*
8. `generation_request_model.dart`
9. `generation_remote_datasource.dart` — multipart/form-data desteği
10. `generation_repository_impl.dart`

*Presentation katmanı:*
11. `generation_provider.dart`
12. `create_template_generation_screen.dart` — image picker dahil
13. `create_custom_image_screen.dart`
14. `generation_list_screen.dart`
15. `generation_detail_screen.dart` — **polling ile status takibi** (5 sn interval)
16. `generation_status_badge.dart` widget

**Polling Notu:** Status `completed` veya `failed` olana kadar her 5 saniyede detail endpoint'i çağır.

**Tamamlandı kriteri:** Template ile talep oluşturulur, liste görünür, detay sayfasında durum güncellenir.

---

### Faz 5 — Custom Video Feature
**Süre: ~75 dakika**

Custom video üretimi ve segment bazlı takip/düzenleme.

**Yapılacaklar:**

*Domain katmanı:*
1. `segment_entity.dart` — `latest_edit_request` nested entity dahil
2. `custom_video_request_entity.dart`
3. `custom_video_repository.dart` (abstract)
4. `create_custom_video_usecase.dart`
5. `get_custom_video_requests_usecase.dart`
6. `get_custom_video_detail_usecase.dart`
7. `edit_segment_usecase.dart`
8. `delete_custom_video_usecase.dart`

*Data katmanı:*
9. `segment_model.dart`
10. `custom_video_request_model.dart`
11. `custom_video_remote_datasource.dart`
12. `custom_video_repository_impl.dart`

*Presentation katmanı:*
13. `custom_video_provider.dart` — polling dahil
14. `create_custom_video_screen.dart` — format seçimi, image picker
15. `custom_video_list_screen.dart`
16. `custom_video_detail_screen.dart` — segment listesi, overall progress
17. `segment_card.dart` — video oynatma, düzenleme butonu
18. `segment_edit_dialog.dart` — edit prompt girişi

**Segment Kuralları:**
- Sadece `completed` segmentlere düzenleme talebi gönderilebilir
- `has_pending_edit: true` ise düzenleme butonu disabled
- Overall progress bar: `(completed_segments / segments_count) * 100`

**Tamamlandı kriteri:** Video talebi oluşturulur, segmentler listelenir, tamamlanan segmentlere düzenleme talebi gönderilebilir.

---

### Faz 6 — Polish & UX
**Süre: ~60 dakika**

Hata yönetimi, loading state'leri ve kullanıcı deneyimi.

**Yapılacaklar:**
1. Global error handling — 401 alınca otomatik logout
2. Tüm ekranlarda loading indicator'lar
3. Error state'leri için retry butonu
4. Boş liste durumları (empty state widget)
5. Pull-to-refresh
6. Token expire kontrolü (interceptor seviyesinde)
7. Network hatası için offline uyarısı

**Tamamlandı kriteri:** Hata durumları graceful handle edilir, kullanıcı bilgilendirilir.

---

## Yapay Zekaya Kod Yazdırma Kuralları

Yapay zekaya her istekte aşağıdaki bağlamı ver:

### Sistem Prompt Şablonu

```
Sen bir Flutter geliştiricisisin. Clean Architecture + Riverpod kullanıyoruz.

KATMAN KURALLARI:
- datasource: sadece Dio HTTP çağrısı, ServerException fırlatır
- model: fromJson/toJson + toEntity() metodu, freezed kullanır
- repository abstract: Future<Result<T>> döner
- repository impl: datasource çağırır, exception → failure dönüştürür
- usecase: tek metot call(), sadece repository çağırır
- provider: AsyncNotifier, usecase çağırır
- screen: sadece UI, iş mantığı yok

RESULT TIPI: Result<T> = Success<T> | Failure — never throw

API standart yanıtı:
{ "success": bool, "message": string?, "data": any, "locale": string }
```

### Her İstek İçin Format

```
Şu fazı yazıyorum: [FAZ NUMARASI]
Şu adımı yazıyorum: [ADIM NUMARASI]
Dosya: [DOSYA YOLU]

[Varsa bağımlı olduğu dosyaların içeriği]

Sadece bu dosyayı yaz. Başka dosyaya dokunma.
```

### Önemli Notlar

- **Bir seferde tek dosya iste.** Çoklu dosya istersen yapay zeka katman kurallarını karıştırır.
- **Bağımlı dosyaları context olarak ver.** Örneğin `repository_impl` yazarken `repository abstract`'ı ve `datasource`'u yapıştır.
- **Code generation dosyalarını (`.g.dart`, `.freezed.dart`) elle yazma.** `build_runner` çalıştırır.
- **Her fazın sonunda `flutter run` yap.** Faz içinde biriken hataları sonda çözmek yerine anında yakala.

---

## Çalıştırma Komutları

```bash
# Bağımlılıkları yükle
flutter pub get

# Code generation (freezed, riverpod_annotation, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Code generation (watch mode — geliştirme sırasında)
dart run build_runner watch --delete-conflicting-outputs

# Uygulamayı çalıştır
flutter run

# Analiz
flutter analyze
```

---

## .env Dosyası

Proje kökünde `.env` dosyası oluştur (git'e commit etme):

```env
APP_KEY=your_app_key_here
SECRET_KEY=your_secret_key_here
BASE_URL=https://your-domain.com/api/v1
```

`.gitignore`'a ekle:
```
.env
lib/core/constants/env.g.dart
```

---

*Son güncelleme: Faz planı v1.0*