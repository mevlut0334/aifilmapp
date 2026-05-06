// lib/core/jobs/job_queue_service.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'job_model.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final jobQueueServiceProvider = Provider<JobQueueService>((ref) {
  return JobQueueService();
});

// ─── Service ─────────────────────────────────────────────────────────────────

class JobQueueService {
  static const _kJobsKey = 'upload_jobs';
  static const _uuid = Uuid();

  // ─── Enqueue ───────────────────────────────────────────────────────────────

  /// Yeni bir iş kuyruğa ekler ve job id'sini döner.
  Future<String> enqueue({
    required JobType type,
    required String imagePath,
    String? templateId,
    String? orientation,
    String? description,
    String? prompt,
  }) async {
    final job = UploadJob(
      id: _uuid.v4(),
      type: type,
      status: JobStatus.pending,
      templateId: templateId,
      orientation: orientation,
      description: description,
      prompt: prompt,
      imagePath: imagePath,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final jobs = await _loadAll();
    jobs.add(job);
    await _saveAll(jobs);
    return job.id;
  }

  // ─── List ──────────────────────────────────────────────────────────────────

  Future<List<UploadJob>> getAll() => _loadAll();

  Future<List<UploadJob>> getPending() async {
    final jobs = await _loadAll();
    return jobs.where((j) => j.status == JobStatus.pending).toList();
  }

  Future<UploadJob?> getById(String id) async {
    final jobs = await _loadAll();
    try {
      return jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<void> updateStatus(
    String id,
    JobStatus status, {
    String? errorMessage,
  }) async {
    final jobs = await _loadAll();
    final index = jobs.indexWhere((j) => j.id == id);
    if (index == -1) return;

    jobs[index] = jobs[index].copyWith(
      status: status,
      errorMessage: errorMessage,
    );
    await _saveAll(jobs);
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> delete(String id) async {
    final jobs = await _loadAll();
    jobs.removeWhere((j) => j.id == id);
    await _saveAll(jobs);
  }

  Future<void> clearCompleted() async {
    final jobs = await _loadAll();
    jobs.removeWhere((j) => j.status == JobStatus.completed);
    await _saveAll(jobs);
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  Future<List<UploadJob>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kJobsKey) ?? [];
    return raw
        .map((e) => UploadJob.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<UploadJob> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jobs.map((j) => jsonEncode(j.toJson())).toList();
    await prefs.setStringList(_kJobsKey, raw);
  }
}