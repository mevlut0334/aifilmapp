// lib/core/jobs/job_worker.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'job_model.dart';
import 'job_notification_service.dart';
import 'job_queue_service.dart';

// ─── Task Name ───────────────────────────────────────────────────────────────

const kProcessJobsTask = 'processUploadJobs';

// ─── Top-level callback (WorkManager isolate) ────────────────────────────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kProcessJobsTask) {
      await _processAllPendingJobs();
    }
    return true;
  });
}

// ─── Ana işlem ───────────────────────────────────────────────────────────────

Future<void> _processAllPendingJobs() async {
  final queueService = JobQueueService();
  final notifService = JobNotificationService.instance;

  await notifService.initialize();

  final pending = await queueService.getPending();

  for (final job in pending) {
    await queueService.updateStatus(job.id, JobStatus.running);

    try {
      await _processJob(job);
      await queueService.updateStatus(job.id, JobStatus.completed);

      await notifService.showSuccess(
        id: job.createdAt.hashCode,
        title: 'Generation Started',
        body: 'Your request has been submitted successfully.',
      );
    } catch (e) {
      await queueService.updateStatus(
        job.id,
        JobStatus.failed,
        errorMessage: e.toString(),
      );

      await notifService.showFailure(
        id: job.createdAt.hashCode,
        title: 'Generation Failed',
        body: 'Something went wrong. Please try again.',
      );
    }
  }
}

// ─── Tek bir job'ı işle ──────────────────────────────────────────────────────

Future<void> _processJob(UploadJob job) async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final token = await storage.read(key: AppConstants.tokenKey);
  if (token == null) throw Exception('Not authenticated');

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        ApiConstants.headerAppKey: ApiConstants.appKey,
        ApiConstants.headerSecretKey: ApiConstants.secretKey,
        ApiConstants.headerAuthorization: 'Bearer $token',
      },
    ),
  );

  final imageFile = File(job.imagePath);
  if (!imageFile.existsSync()) {
    throw Exception('Image file not found: ${job.imagePath}');
  }

  final formData = FormData.fromMap({
    'image': await MultipartFile.fromFile(
      job.imagePath,
      filename: imageFile.uri.pathSegments.last,
    ),
    if (job.templateId != null) 'template_uuid': job.templateId,
    if (job.orientation != null) 'orientation': job.orientation,
    if (job.description != null) 'description': job.description,
    if (job.prompt != null) 'prompt': job.prompt,
  });

  final endpoint = switch (job.type) {
    JobType.templateImage || JobType.templateVideo =>
      ApiConstants.generationRequests,
    JobType.customImage || JobType.customVideo =>
      ApiConstants.customVideoRequests,
  };

  final response = await dio.post(endpoint, data: formData);

  if (response.statusCode != 200 && response.statusCode != 201) {
    final msg = (response.data as Map<String, dynamic>?)?['message']
        ?? 'Unknown error';
    throw Exception(msg);
  }
}

// ─── WorkManager kayıt yardımcısı ────────────────────────────────────────────

class JobWorkerHelper {
  JobWorkerHelper._();

  /// Yeni bir job eklendiğinde çağır — WorkManager görevi tetikler.
  static Future<void> scheduleOnce() async {
    await Workmanager().registerOneOffTask(
      kProcessJobsTask,
      kProcessJobsTask,
      existingWorkPolicy: ExistingWorkPolicy.append,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}