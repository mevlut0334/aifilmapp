# 🎬 Film Yapma Uygulaması — Flutter Proje Rehberi

> Bu doküman yapay zeka destekli geliştirme için hazırlanmıştır.
> Her faz bağımsızdır. Bir fazı tamamlamadan diğerine geçme.
> **Her dosya tek tek yazılır, bir sonrakine geçmek için kullanıcı onayı beklenir.**

---

## 📋 İçindekiler

1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Teknoloji Yığını](#teknoloji-yığını)
3. [Mimari](#mimari)
4. [Klasör Yapısı](#klasör-yapısı)
5. [Katman Kuralları](#katman-kuralları)
6. [Background Job Mimarisi](#background-job-mimarisi)
7. [API Bilgileri](#api-bilgileri)
8. [Faz Planı](#faz-planı)
9. [Yapay Zekaya Kod Yazdırma Kuralları](#yapay-zekaya-kod-yazdırma-kuralları)

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
- **Görsel yükleme işlemleri arka planda (background job) çalışır — kullanıcı ekranda beklemez**

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
| `workmanager` | ^0.5.0 | **Background job — görsel yükleme** |
| `flutter_local_notifications` | ^17.0.0 | **Job tamamlandığında bildirim** |
| `uuid` | ^4.0.0 | **Job ID üretimi** |
| `shared_preferences` | ^2.2.0 | **Job kuyruğu ve durumu kalıcı saklama** |

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

**Görsel yükleme veri akışı (background job):**

```
UI (Screen)
  └── "Talep Oluştur" butonuna basar
       └── JobQueueService'e iş ekler (anında döner)
            └── UI → liste ekranına yönlendirilir (beklemez)
                 └── WorkManager → arka planda çalışır
                                    └── multipart upload → API
                                         └── Tamamlanınca bildirim + provider güncellenir
```

**Altın kural:** Hiçbir katman kendinden üst katmanı import etmez.

---

## Klasör Yapısı

```
lib/
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_response.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── app_key_interceptor.dart
│   │
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   │
│   ├── utils/
│   │   ├── result.dart
│   │   └── extensions.dart
│   │
│   ├── storage/
│   │   └── secure_storage.dart
│   │
│   └── jobs/                          ← YENİ: Background job altyapısı
│       ├── job_model.dart             # JobStatus enum + UploadJob modeli
│       ├── job_queue_service.dart     # İş ekleme, listeleme, durum güncelleme
│       ├── job_worker.dart            # WorkManager callback — asıl upload mantığı
│       └── job_notification_service.dart  # Bildirim gönderme
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
│   │   │   │   └── auth_repository.dart
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
│   │   │   │   └── template_repository.dart
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
│   │   │   │   └── generation_repository.dart
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
│       │   │   └── custom_video_repository.dart
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

## Background Job Mimarisi

> Kullanıcının görsel yüklediği **her** talep oluşturma ekranı bu akışı kullanır.
> Kullanıcı "Oluştur" butonuna basınca iş kuyruğa eklenir ve ekran anında kapanır.

### Kapsam

Aşağıdaki ekranlar background job kullanır:

| Ekran | Sebep |
|---|---|
| `create_template_generation_screen.dart` | `input_image` multipart upload |
| `create_custom_image_screen.dart` | `input_image` opsiyonel upload |
| `create_custom_video_screen.dart` | `reference_image` upload |
| `segment_edit_dialog.dart` | Edit prompt — görsel eklenmişse |

### Job Durumları

```dart
enum JobStatus {
  queued,      // Kuyruğa alındı
  uploading,   // Yükleniyor
  completed,   // API'ye başarıyla iletildi
  failed,      // Hata oluştu
}
```

### Job Modeli (`core/jobs/job_model.dart`)

```dart
class UploadJob {
  final String jobId;          // uuid v4
  final String type;           // 'template_generation' | 'custom_image' | 'custom_video' | 'segment_edit'
  final String imagePath;      // Yerel dosya yolu
  final Map<String, dynamic> params;  // API'ye gönderilecek diğer alanlar
  final JobStatus status;
  final String? errorMessage;
  final DateTime createdAt;
}
```

### Akış

```
1. Kullanıcı formu doldurur, görsel seçer
2. Screen → JobQueueService.enqueue(UploadJob) çağırır
3. JobQueueService → shared_preferences'a job kaydeder
4. JobQueueService → WorkManager.registerOneOffTask(jobId) tetikler
5. Screen → liste ekranına yönlendirilir (kullanıcı beklemez)
6. WorkManager arka planda:
     a. Job verilerini shared_preferences'tan okur
     b. Dosyayı multipart/form-data ile API'ye gönderir
     c. Başarılıysa: job status = completed, bildirim gönderir
     d. Başarısızsa: job status = failed, retry veya bildirim
7. Liste ekranı açıksa provider invalidate edilir, liste yenilenir
```

### Job Worker (`core/jobs/job_worker.dart`)

```dart
// WorkManager callback — @pragma('vm:entry-point') olmalı
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // 1. SharedPreferences'tan UploadJob'u oku
    // 2. Job tipine göre ilgili datasource'u çağır
    // 3. Başarı/hata durumunu shared_preferences'a yaz
    // 4. Bildirim gönder
    return Future.value(true);
  });
}
```

### Kurallar

- **Worker içinde Riverpod provider kullanılmaz.** Worker bağımsız bir isolate'te çalışır.
- **Worker direkt datasource'u çağırır**, usecase zincirini kullanmaz.
- **Token okuma:** Worker içinde `FlutterSecureStorage` direkt kullanılır.
- **Hata durumunda** kullanıcıya bildirim gönderilir, job `failed` olarak işaretlenir.
- **Liste ekranı** açıkken `pending` jobları gösterir (`JobStatus.queued | uploading`).

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

> **Temel Kural:** Her faz bağımsız çalışır. Bir faz bitmeden diğerine geçilmez.
>
> **Dosya Oluşturma Kuralı:** Dosyalar **sırayla** oluşturulur. Bir dosya yazılır,
> kullanıcı onay verir, sonra bir sonraki dosyaya geçilir.
> **Boş dosya veya klasör yapısı önceden oluşturulmaz.**
>
> Her fazın sonunda `flutter run` ile uygulama ayağa kalkmalıdır.

---

### Faz 0 — Proje İskeleti
**Süre: ~30 dakika**

Bu fazda sadece temel kurulum yapılır. Boş dosya/klasör yapısı oluşturulmaz.

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Açıklama |
|---|---|---|
| 1 | `pubspec.yaml` | Tüm paketler eklenir |
| 2 | `.env` | App key, secret key, base URL |
| 3 | `lib/main.dart` | Sadece ProviderScope + MaterialApp |
| 4 | `lib/core/utils/result.dart` | `Result<T>` tipi |
| 5 | `lib/core/error/failures.dart` | Failure tipleri |
| 6 | `lib/core/error/exceptions.dart` | Exception tipleri |
| 7 | `lib/core/constants/api_constants.dart` | Base URL + tüm endpoint path'leri |
| 8 | `lib/core/constants/app_constants.dart` | Genel sabitler |

**Her dosya sonrası:** Yapay zeka durur ve şunu yazar:
> ✅ `[dosya adı]` tamamlandı. Onaylarsanız `[sonraki dosya]` ile devam edelim.

**Faz tamamlandı kriteri:** `flutter run` çalışır, boş ekran açılır.

---

### Faz 1 — Core Network Katmanı
**Süre: ~45 dakika**

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Açıklama |
|---|---|---|
| 1 | `lib/core/storage/secure_storage.dart` | Token okuma/yazma |
| 2 | `lib/core/network/api_response.dart` | Generic `ApiResponse<T>` |
| 3 | `lib/core/network/interceptors/app_key_interceptor.dart` | X-App-Key inject |
| 4 | `lib/core/network/interceptors/auth_interceptor.dart` | Bearer token inject |
| 5 | `lib/core/network/api_client.dart` | Dio Provider |

**Faz tamamlandı kriteri:** Login endpoint'e manuel istek atılabilir, response parse edilir.

---

### Faz 2 — Auth Feature
**Süre: ~60 dakika**

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Katman |
|---|---|---|
| 1 | `domain/entities/user_entity.dart` | Domain |
| 2 | `domain/repositories/auth_repository.dart` | Domain (abstract) |
| 3 | `domain/usecases/login_usecase.dart` | Domain |
| 4 | `domain/usecases/register_usecase.dart` | Domain |
| 5 | `domain/usecases/logout_usecase.dart` | Domain |
| 6 | `data/models/user_model.dart` | Data |
| 7 | `data/models/login_response_model.dart` | Data |
| 8 | `data/datasources/auth_remote_datasource.dart` | Data |
| 9 | `data/repositories/auth_repository_impl.dart` | Data |
| 10 | `presentation/providers/auth_provider.dart` | Presentation |
| 11 | `presentation/widgets/auth_form_field.dart` | Presentation |
| 12 | `presentation/screens/login_screen.dart` | Presentation |
| 13 | `presentation/screens/register_screen.dart` | Presentation |
| 14 | `app/router.dart` | Routing (go_router) |

**Faz tamamlandı kriteri:** Gerçek kullanıcı ile giriş yapılabilir, token kaydedilir, home sayfasına geçilir.

---

### Faz 3 — Template Feature
**Süre: ~45 dakika**

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Katman |
|---|---|---|
| 1 | `domain/entities/template_entity.dart` | Domain (`title`/`description` `Map<String,String>`) |
| 2 | `domain/repositories/template_repository.dart` | Domain (abstract) |
| 3 | `domain/usecases/get_templates_usecase.dart` | Domain |
| 4 | `domain/usecases/get_template_detail_usecase.dart` | Domain |
| 5 | `data/models/template_model.dart` | Data |
| 6 | `data/datasources/template_remote_datasource.dart` | Data |
| 7 | `data/repositories/template_repository_impl.dart` | Data |
| 8 | `presentation/providers/template_provider.dart` | Presentation |
| 9 | `presentation/widgets/template_card.dart` | Presentation |
| 10 | `presentation/screens/template_list_screen.dart` | Presentation |
| 11 | `presentation/screens/template_detail_screen.dart` | Presentation |

**Faz tamamlandı kriteri:** Template'ler listelenir, detay sayfası açılır, video oynatılır.

---

### Faz 4 — Background Job Altyapısı
**Süre: ~45 dakika**

> Bu faz, görsel yükleme içeren tüm feature'lardan **önce** tamamlanır.

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Açıklama |
|---|---|---|
| 1 | `core/jobs/job_model.dart` | `UploadJob` + `JobStatus` enum |
| 2 | `core/jobs/job_queue_service.dart` | Enqueue, listele, durum güncelle (SharedPreferences) |
| 3 | `core/jobs/job_notification_service.dart` | flutter_local_notifications setup |
| 4 | `core/jobs/job_worker.dart` | WorkManager callbackDispatcher |
| 5 | `main.dart` güncellemesi | WorkManager.initialize() çağrısı eklenir |

**Faz tamamlandı kriteri:** Bir test job kuyruğa eklenip arka planda çalıştırılabilir, bildirim gelir.

---

### Faz 5 — Generation Feature
**Süre: ~60 dakika**

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Katman |
|---|---|---|
| 1 | `domain/entities/generation_request_entity.dart` | Domain |
| 2 | `domain/repositories/generation_repository.dart` | Domain (abstract) |
| 3 | `domain/usecases/create_template_generation_usecase.dart` | Domain |
| 4 | `domain/usecases/create_custom_image_usecase.dart` | Domain |
| 5 | `domain/usecases/get_generation_requests_usecase.dart` | Domain |
| 6 | `domain/usecases/get_generation_detail_usecase.dart` | Domain |
| 7 | `domain/usecases/cancel_generation_usecase.dart` | Domain |
| 8 | `data/models/generation_request_model.dart` | Data |
| 9 | `data/datasources/generation_remote_datasource.dart` | Data |
| 10 | `data/repositories/generation_repository_impl.dart` | Data |
| 11 | `presentation/providers/generation_provider.dart` | Presentation |
| 12 | `presentation/widgets/generation_status_badge.dart` | Presentation |
| 13 | `presentation/screens/generation_list_screen.dart` | Presentation |
| 14 | `presentation/screens/generation_detail_screen.dart` | Presentation (polling 5sn) |
| 15 | `presentation/screens/create_template_generation_screen.dart` | Presentation **(job kullanır)** |
| 16 | `presentation/screens/create_custom_image_screen.dart` | Presentation **(job kullanır)** |

**Polling Notu:** Status `completed` veya `failed` olana kadar her 5 saniyede detail endpoint'i çağır.

**Job Notu:** `create_*_screen` dosyalarında görsel seçildikten sonra `JobQueueService.enqueue()` çağrılır. API direkt çağrılmaz.

**Faz tamamlandı kriteri:** Template ile talep oluşturulur, liste görünür, detay sayfasında durum güncellenir.

---

### Faz 6 — Custom Video Feature
**Süre: ~75 dakika**

**Dosya sırası (her biri için onay beklenir):**

| # | Dosya | Katman |
|---|---|---|
| 1 | `domain/entities/segment_entity.dart` | Domain |
| 2 | `domain/entities/custom_video_request_entity.dart` | Domain |
| 3 | `domain/repositories/custom_video_repository.dart` | Domain (abstract) |
| 4 | `domain/usecases/create_custom_video_usecase.dart` | Domain |
| 5 | `domain/usecases/get_custom_video_requests_usecase.dart` | Domain |
| 6 | `domain/usecases/get_custom_video_detail_usecase.dart` | Domain |
| 7 | `domain/usecases/edit_segment_usecase.dart` | Domain |
| 8 | `domain/usecases/delete_custom_video_usecase.dart` | Domain |
| 9 | `data/models/segment_model.dart` | Data |
| 10 | `data/models/custom_video_request_model.dart` | Data |
| 11 | `data/datasources/custom_video_remote_datasource.dart` | Data |
| 12 | `data/repositories/custom_video_repository_impl.dart` | Data |
| 13 | `presentation/providers/custom_video_provider.dart` | Presentation |
| 14 | `presentation/widgets/segment_card.dart` | Presentation |
| 15 | `presentation/widgets/segment_edit_dialog.dart` | Presentation **(job kullanır)** |
| 16 | `presentation/screens/custom_video_list_screen.dart` | Presentation |
| 17 | `presentation/screens/custom_video_detail_screen.dart` | Presentation |
| 18 | `presentation/screens/create_custom_video_screen.dart` | Presentation **(job kullanır)** |

**Segment Kuralları:**
- Sadece `completed` segmentlere düzenleme talebi gönderilebilir
- `has_pending_edit: true` ise düzenleme butonu disabled
- Overall progress bar: `(completed_segments / segments_count) * 100`

**Faz tamamlandı kriteri:** Video talebi oluşturulur, segmentler listelenir, tamamlanan segmentlere düzenleme talebi gönderilebilir.

---

### Faz 7 — Polish & UX
**Süre: ~60 dakika**

**Dosya sırası (her biri için onay beklenir):**

| # | Görev | Açıklama |
|---|---|---|
| 1 | `auth_interceptor.dart` güncellemesi | 401 alınca otomatik logout |
| 2 | `core/widgets/empty_state_widget.dart` | Boş liste için ortak widget |
| 3 | `core/widgets/error_state_widget.dart` | Hata + retry butonu |
| 4 | `core/widgets/loading_overlay.dart` | Global loading indicator |
| 5 | `core/jobs/job_queue_service.dart` güncellemesi | Failed job retry |
| 6 | Tüm list screen'lere pull-to-refresh eklenmesi | Her ekran ayrı onay |

**Faz tamamlandı kriteri:** Hata durumları graceful handle edilir, kullanıcı bilgilendirilir.

---

## Yapay Zekaya Kod Yazdırma Kuralları

### 🔴 En Önemli Kural: Tek Dosya — Onay — Devam

```
Yapay zeka her seferinde YALNIZCA bir dosya yazar.
Dosyayı yazdıktan sonra DURUR ve şunu söyler:

  ✅ [dosya_yolu] tamamlandı.
  Onaylarsanız sıradaki dosya olan [sonraki_dosya_yolu] ile devam edelim.

Kullanıcı onay vermeden bir sonraki dosyaya GEÇİLMEZ.
Kullanıcı onay vermeden klasör oluşturulmaz, boş dosya yaratılmaz.
```

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

BACKGROUND JOB KURALI:
- Kullanıcının görsel yüklediği her form ekranında JobQueueService.enqueue() kullanılır
- Görsel yükleme için API direkt çağrılmaz, WorkManager job'ı tetiklenir
- Job kuyruğa alındıktan sonra ekran kapanır, kullanıcı beklemez

RESULT TIPI: Result<T> = Success<T> | Failure — never throw

API standart yanıtı:
{ "success": bool, "message": string?, "data": any, "locale": string }

DOSYA KURALI:
- Sadece istenen tek dosyayı yaz
- Dosyayı yazdıktan sonra dur ve onay iste
- Başka dosyaya dokunma, başka klasör oluşturma
```

### Her İstek İçin Format

```
Şu fazı yazıyorum: [FAZ NUMARASI]
Şu dosyayı yazıyorum: [DOSYA YOLU]
Sıradaki dosya: [SONRAKİ DOSYA YOLU] — ama onu henüz yazma

Bağımlı dosyalar (context):
[Varsa bağımlı dosyaların içeriği buraya yapıştırılır]

Sadece [DOSYA YOLU] dosyasını yaz. Bitince dur ve onay iste.
```

### Önemli Notlar

- **Tek seferde tek dosya.** Çoklu dosya istersen yapay zeka katman kurallarını karıştırır.
- **Bağımlı dosyaları context olarak ver.** Örneğin `repository_impl` yazarken `repository abstract`'ı ve `datasource`'u yapıştır.
- **Code generation dosyalarını (`.g.dart`, `.freezed.dart`) elle yazma.** `build_runner` çalıştırır.
- **Her fazın sonunda `flutter run` yap.** Faz içinde biriken hataları sonda çözmek yerine anında yakala.
- **Job worker dosyasını verirken** `api_constants.dart` ve `secure_storage.dart` context olarak ekle.

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

*Son güncelleme: Faz planı v2.0 — Background job + tek dosya onay akışı*